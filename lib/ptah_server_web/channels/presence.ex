# TODO: move this presence to ptah_server_agent
defmodule PtahServerWeb.Presence do
  defmodule State do
    alias PtahProto.Cmd
    defstruct server: %{}, join: %{}, socket: %{}

    @type t :: map()
  end

  @slug_re ~r/\W/

  @moduledoc """
  Provides presence tracking to channels and processes.

  See the [`Phoenix.Presence`](https://hexdocs.pm/phoenix/Phoenix.Presence.html)
  docs for more details.
  """
  use Phoenix.Presence,
    otp_app: :ptah_server,
    pubsub_server: PtahServer.PubSub

  alias PtahServer.Swarms
  alias PtahServer.Servers
  alias PtahServerAgent.AgentChannel
  alias PtahProto.Cmd
  alias PtahProto.ServiceSpec
  alias PtahServer.Repo
  alias PtahServer.Servers.Server

  alias PtahServerWeb.Presence.State

  require Logger

  def init(_opts) do
    {:ok, %{}}
  end

  def handle_metas("team:" <> team_id, %{joins: joins, leaves: leaves} = _diff, _presences, state) do
    for {server_id, %{metas: metas}} <- leaves do
      Phoenix.PubSub.broadcast(
        PtahServer.PubSub,
        team_live_topic(team_id),
        {__MODULE__, {:leave, server_id, metas}}
      )

      Phoenix.PubSub.broadcast(
        PtahServer.PubSub,
        server_live_topic(server_id),
        {__MODULE__, {:leave, metas}}
      )
    end

    for {server_id, %{metas: metas}} <- joins do
      Phoenix.PubSub.broadcast(
        PtahServer.PubSub,
        team_live_topic(team_id),
        {__MODULE__, {:join, server_id, metas}}
      )

      Phoenix.PubSub.broadcast(
        PtahServer.PubSub,
        server_live_topic(server_id),
        {__MODULE__, {:join, metas}}
      )
    end

    {:ok, state}
  end

  def track_server(server, state) do
    Server.update_last_seen(server)

    track(
      self(),
      team_topic(server.team_id),
      server.id,
      %State{
        socket: state.socket,
        join: state.join,
        server: server
      }
    )
  end

  def swarm_created(server, swarm) do
    state = get_state(server.id)

    Phoenix.PubSub.broadcast(
      PtahServer.PubSub,
      server_live_topic(server.id),
      {__MODULE__, {:swarm_created, server: server}}
    )

    update(self(), team_topic(server.team_id), server.id, %State{
      state
      | server: server,
        join: %Cmd.Join{state.join | swarm: swarm}
    })
  end

  def untrack_server(server) do
    Server.update_last_seen(server)

    untrack(self(), team_topic(server.team_id), server.id)
  end

  def list_online_agents(team_id) do
    list(team_topic(team_id))
    |> Enum.map(fn {_, %{metas: [meta]}} -> meta end)
  end

  def get_state(server_id) do
    # Not sure if this implicit dependency is any good
    team_id = PtahServer.Repo.get_team_id()

    meta = Enum.at(get_by_key(team_topic(team_id), server_id), 0)

    if meta do
      {_, [meta]} = meta

      meta
    end
  end

  def subscribe_team() do
    # Not sure if this implicit dependency is any good
    team_id = PtahServer.Repo.get_team_id()

    Phoenix.PubSub.subscribe(PtahServer.PubSub, team_live_topic(team_id))
  end

  def subscribe_server(server_id) do
    Phoenix.PubSub.subscribe(PtahServer.PubSub, server_live_topic(server_id))
  end

  def swarm_init(
        server,
        swarm,
        %{listen_addr: listen_addr, advertise_addr: advertise_addr} = _params
      ) do
    state = get_state(server.id)

    AgentChannel.push(state.socket, %Cmd.CreateSwarm{
      swarm_id: swarm.id,
      listen_addr: listen_addr,
      advertise_addr: advertise_addr
    })
  end

  def get_swarm_manager!(swarm) do
    manager =
      list_online_agents(swarm.team_id)
      |> Enum.find(fn agent ->
        agent.server.swarm_id == swarm.id and agent.server.role == :manager
      end)

    if manager == nil do
      raise "Manager not found"
    end

    manager
  end

  def load_caddy(swarm, config) do
    manager = get_swarm_manager!(swarm)

    AgentChannel.push(manager.socket, %Cmd.LoadCaddyConfig{
      config: config
    })
  end

  def stack_create(stack) do
    for service <- stack.services do
      service_create(service)
    end

    # TODO: remove this dependency. It is here just to record a demo. Fails when installing ptah-swarm itself,
    #   as there's no Caddy yet.
    #   This case should be handled elsewhere
    if stack.name != "ptah-swarm" do
      Swarms.rebuild_caddy(Repo.preload(stack, :swarm).swarm)
    end

    :ok
  end

  def service_create(service) do
    service = Repo.preload(service, :stack)

    manager = get_swarm_manager!(Repo.preload(service.stack, :swarm).swarm)

    AgentChannel.push(manager.socket, %Cmd.CreateService{
      service_id: service.id,
      service_spec: map_service_spec(service.stack, service)
    })
  end

  def service_update(service) do
    service = Repo.preload(service, :stack)

    manager = get_swarm_manager!(Repo.preload(service.stack, :swarm).swarm)

    AgentChannel.push(manager.socket, %Cmd.UpdateService{
      service_id: service.id,
      docker: %Cmd.UpdateService.Docker{
        service_id: service.ext_id
      },
      service_spec: map_service_spec(service.stack, service)
    })
  end

  def service_delete(swarm, service) do
    manager = get_swarm_manager!(swarm)

    AgentChannel.push(manager.socket, %Cmd.DeleteService{
      service_id: service.id,
      docker: %Cmd.DeleteService.Docker{
        service_id: service.ext_id
      }
    })
  end

  defp map_service_spec(stack, service) do
    %ServiceSpec{
      name: "#{stack.name}_#{service.name}",
      task_template: %ServiceSpec.TaskTemplate{
        container_spec: %ServiceSpec.TaskTemplate.ContainerSpec{
          name: service.name,
          image: service.spec.task_template.container_spec.image,
          hostname: "#{service.name}.#{stack.name}",
          env:
            Enum.map(service.spec.task_template.container_spec.env, fn env ->
              %ServiceSpec.TaskTemplate.ContainerSpec.Env{
                name: env.name,
                value: env.value
              }
            end),
          mounts:
            Enum.map(service.spec.task_template.container_spec.mounts, fn mount ->
              %ServiceSpec.TaskTemplate.ContainerSpec.Mount{
                type: "volume",
                source:
                  slugify([
                    stack.name,
                    service.name,
                    mount.name
                  ]),
                target: mount.target
              }
            end)
        },
        networks: [
          %ServiceSpec.TaskTemplate.Network{
            target: "ptah-net",
            aliases: [
              "#{service.service_name}.#{stack.name}"
            ]
          }
        ],
        placement: %ServiceSpec.TaskTemplate.Placement{
          constraints:
            if service.spec.placement_server_id do
              placement_server = Servers.get_server!(service.spec.placement_server_id)

              [
                "node.id == #{placement_server.ext_id}"
              ]
            else
              []
            end
        }
      },
      mode: %ServiceSpec.Mode{
        replicated: %ServiceSpec.Mode.Replicated{
          replicas: 1
        }
      },
      endpoint_spec: %ServiceSpec.EndpointSpec{
        ports:
          service.spec.endpoint_spec.ports
          |> Enum.map(fn port ->
            %ServiceSpec.EndpointSpec.Port{
              protocol: "tcp",
              target_port: port.target_port,
              published_port: port.published_port,
              published_mode: "ingress"
            }
          end)
      }
    }
  end

  def docker_config_create(config, data) do
    manager = get_swarm_manager!(Repo.preload(config, :swarm).swarm)

    AgentChannel.push(manager.socket, %Cmd.CreateConfig{
      config_id: config.id,
      name: config.name,
      data: data
    })
  end

  defp slugify(name) do
    name
    |> Enum.join("_")
    |> String.downcase()
    |> String.replace(@slug_re, "_")
  end

  defp team_topic(team_id) do
    "team:#{team_id}"
  end

  defp team_live_topic(team_id) do
    "live:#{team_topic(team_id)}"
  end

  defp server_live_topic(server_id) do
    "live:server:#{server_id}"
  end
end
