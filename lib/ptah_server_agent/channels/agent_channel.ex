defmodule PtahServerAgent.AgentChannel do
  alias PtahServer.DockerConfigs.DockerConfig
  alias PtahServer.Servers
  alias PtahServer.Services.Service
  alias PtahServer.Swarms.Swarm
  alias PtahServer.Repo
  alias PtahServerWeb.Presence
  require Logger
  use PtahServerAgent, :channel
  alias PtahServer.Servers.Server
  use PtahProto, phx_topic: "agent:daemon"
  alias PtahProto.Event
  alias PtahProto.Cmd

  def join(%Cmd.Join{} = payload, socket) do
    # TODO: check if the agent has already joined. Allow join only once - one agent per one server.

    if payload.token do
      server = Server.get_by_token(payload.token)

      Repo.put_team_id(server.team_id)

      {:ok, server} =
        Servers.update_server(server, %{
          networks:
            payload.networks
            |> Enum.map(fn network ->
              %{
                name: network.name,
                ips:
                  network.ips
                  |> Enum.map(fn ip -> %{version: ip.version, address: ip.address} end)
              }
            end)
        })

      send(self(), {:after_join, payload})

      {:ok, assign(socket, server: server)}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  @impl true
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (agent:lobby).
  @impl true
  def handle_in("shout", payload, socket) do
    broadcast(socket, "shout", payload)

    {:noreply, socket}
  end

  @impl PtahProto
  def handle_packet(%Event.ServiceCreated{} = payload, socket) do
    service = Repo.get_by(Service, id: payload.service_id)

    {:ok, _} =
      service
      |> Ecto.Changeset.change(ext_id: payload.docker.service_id)
      |> Repo.update()

    {:noreply, socket}
  end

  @impl PtahProto
  def handle_packet(%Event.ServiceUpdated{} = _payload, socket) do
    {:noreply, socket}
  end

  @impl PtahProto
  def handle_packet(%Event.ServiceDeleted{} = _payload, socket) do
    {:noreply, socket}
  end

  @impl PtahProto
  def handle_packet(%Event.SwarmCreated{} = packet, socket) do
    swarm = Repo.get_by(Swarm, id: packet.swarm_id)

    {:ok, _} =
      swarm
      |> Ecto.Changeset.change(ext_id: packet.docker.swarm_id)
      |> Repo.update()

    {:ok, server} =
      socket.assigns.server
      # TODO: apply correct role here
      |> Ecto.Changeset.change(swarm_id: swarm.id, role: :manager, ext_id: packet.docker.node_id)
      |> Repo.update()

    Presence.swarm_created(server, %{})

    {:noreply, assign(socket, :server, server)}
  end

  @impl PtahProto
  def handle_packet(%Event.ConfigCreated{} = packet, socket) do
    config = Repo.get_by(DockerConfig, id: packet.config_id)

    {:ok, _} =
      config
      |> Ecto.Changeset.change(ext_id: packet.docker.config_id)
      |> Repo.update()

    {:noreply, socket}
  end

  @impl true
  def handle_info({:after_join, %Cmd.Join{} = payload}, socket) do
    {:ok, _} =
      Presence.track_server(socket.assigns.server, %{
        socket: socket,
        join: payload
      })

    {:noreply, socket}
  end

  @impl true
  def terminate(_reason, socket) do
    Presence.untrack_server(socket.assigns.server)

    {:noreply, socket}
  end
end
