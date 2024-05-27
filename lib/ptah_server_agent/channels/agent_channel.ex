defmodule PtahServerAgent.AgentChannel do
  alias PtahServerWeb.Presence
  require Logger
  use PtahServerAgent, :channel
  alias PtahServer.Servers.Server

  @impl true
  def join("agent:daemon", payload, socket) do
    Logger.info("daemon join: #{inspect(payload)}")

    token = Map.get(payload, "token")

    if token do
      server = Server.get_by_token(token)
      Logger.info("server: #{inspect(server)}")

      send(self(), :after_join)

      {:ok, _} = Presence.track_server(server)

      {:ok, assign(socket, server: server)}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  @impl true
  def handle_in("ping", payload, socket) do
    # Logger.info("ping")

    {:reply, {:ok, payload}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (agent:lobby).
  @impl true
  def handle_in("shout", payload, socket) do
    broadcast(socket, "shout", payload)
    {:noreply, socket}
  end

  @impl true
  def handle_info(:after_join, socket) do
    Logger.info("AFTER JOIN !!!!!")

    {:noreply, socket}
  end

  @impl true
  def terminate(reason, socket) do
    Logger.info("terminate: #{inspect(reason)}")

    # server = socket.assigns.server

    Presence.untrack_server(socket.assigns.server)

    {:noreply, socket}
  end
end
