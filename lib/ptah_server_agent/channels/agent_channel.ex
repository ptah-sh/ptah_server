defmodule PtahServerAgent.AgentChannel do
  alias PtahServer.Swarms.Swarm
  alias PtahServer.Repo
  alias PtahServerWeb.Presence
  require Logger
  use PtahServerAgent, :channel
  alias PtahServer.Servers.Server
  use PtahProto, :phx_channel
  alias PtahProto.Event

  @impl true
  def join("agent:daemon", payload, socket) do
    # TODO: check if the agent has already joined. Allow join only once - one agent per one server.

    {token, payload} = Map.pop(payload, "token")

    if token do
      server = Server.get_by_token(token)

      Repo.put_team_id(server.team_id)

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
    service = Repo.get_by(Server.Service, id: payload.service_id)

    {:ok, _} =
      service
      |> Ecto.Changeset.change(ext_id: payload.docker.service_id)
      |> Repo.update()

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
      |> Ecto.Changeset.change(swarm_id: swarm.id, role: :manager)
      |> Repo.update()

    Presence.swarm_created(server, %{})

    {:noreply, assign(socket, :server, server)}
  end

  @impl true
  def handle_info({:after_join, payload}, socket) do
    {:ok, _} =
      Presence.track_server(socket.assigns.server, %{
        socket: socket,
        docker: %{
          platform: payload["docker"]["platform"],
          version: payload["docker"]["version"]
        },
        agent: %{
          version: payload["agent"]["version"]
        },
        swarm: map_swarm(payload["swarm"])
      })

    {:noreply, socket}
  end

  @impl true
  def terminate(_reason, socket) do
    Presence.untrack_server(socket.assigns.server)

    {:noreply, socket}
  end

  defp map_swarm(swarm) do
    if swarm do
      %{}
    else
      nil
    end
  end
end
