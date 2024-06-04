# TODO: move this presence to ptah_server_agent
defmodule PtahServerWeb.Presence do
  defmodule State do
    alias PtahProto.Cmd
    defstruct server: %{}, join: %{}, socket: %{}

    @type t :: map()
  end

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
  alias PtahServer.Marketplace
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

  def swarm_create(server) do
    {:ok, swarm} =
      Repo.insert(%PtahServer.Swarms.Swarm{
        name: "auto created via #{server.id}",
        team_id: server.team_id,
        ext_id: ""
      })

    state = get_state(server.id)

    AgentChannel.push(state.socket, %Cmd.CreateSwarm{
      swarm_id: swarm.id
    })
  end

  def stack_create(stack) do
    manager =
      list_online_agents(stack.team_id)
      |> Enum.find(fn agent ->
        agent.server.swarm_id == stack.swarm_id and agent.server.role == :manager
      end)

    if manager == nil do
      raise "Manager not found"
    end

    stack_spec = Marketplace.get_stack(stack.stack_name)

    AgentChannel.push(manager.socket, %Cmd.CreateStack{
      name: stack.name,
      services:
        Enum.map(stack.services, fn service ->
          spec = Marketplace.Stack.get_service(stack_spec, service.service_name)

          %Cmd.CreateStack.Service{
            service_id: service.id,
            service_spec: %Cmd.CreateStack.Service.ServiceSpec{
              name: "#{stack.name}_#{service.service_name}",
              task_template: %Cmd.CreateStack.Service.ServiceSpec.TaskTemplate{
                container_spec: %Cmd.CreateStack.Service.ServiceSpec.TaskTemplate.ContainerSpec{
                  name: service.name,
                  image: spec["image"],
                  hostname: "#{service.service_name}.#{stack.name}",
                  env:
                    Enum.map(spec["env"], fn env ->
                      %Cmd.CreateStack.Service.ServiceSpec.TaskTemplate.ContainerSpec.Env{
                        name: env["name"],
                        value: env["value"]
                      }
                    end),
                  mounts:
                    Enum.map(spec["mounts"], fn mount ->
                      %Cmd.CreateStack.Service.ServiceSpec.TaskTemplate.ContainerSpec.Mount{
                        type: "bind",
                        source:
                          Path.join([
                            manager.server.mounts_root,
                            stack.name,
                            service.service_name,
                            mount["name"]
                          ]),
                        target: mount["target"],
                        bind_options:
                          %Cmd.CreateStack.Service.ServiceSpec.TaskTemplate.ContainerSpec.Mount.BindOptions{
                            create_mountpoint: true
                          }
                      }
                    end)
                },
                networks: [
                  %Cmd.CreateStack.Service.ServiceSpec.TaskTemplate.Network{
                    target: "ptah-net",
                    aliases: [
                      "#{service.service_name}.#{stack.name}"
                    ]
                  }
                ],
                placement: %Cmd.CreateStack.Service.ServiceSpec.TaskTemplate.Placement{
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
              mode: %Cmd.CreateStack.Service.ServiceSpec.Mode{
                replicated: %Cmd.CreateStack.Service.ServiceSpec.Mode.Replicated{
                  replicas: 1
                }
              },
              endpoint_spec: %Cmd.CreateStack.Service.ServiceSpec.EndpointSpec{
                ports:
                  service.spec.endpoint_spec.ports
                  |> Enum.filter(& &1.docker.exposed)
                  |> Enum.map(fn port ->
                    %Cmd.CreateStack.Service.ServiceSpec.EndpointSpec.Port{
                      protocol: "tcp",
                      target_port: Marketplace.Stack.Service.get_port(spec, port.name)["target"],
                      published_port: port.docker.published_port,
                      published_mode: "ingress"
                    }
                  end)
              }
            }
          }
        end)
    })

    # TODO: remove this dependency. It is here just to record a demo. Fails when installing ptah-swarm itself,
    #   as there's no Caddy yet.
    #   This case should be handled elsewhere
    if stack.name != "ptah-swarm" do
      AgentChannel.push(manager.socket, %Cmd.LoadCaddyConfig{
        config: Swarms.rebuild_caddy(Repo.preload(manager.server, :swarm).swarm)
      })
    end

    :ok
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
