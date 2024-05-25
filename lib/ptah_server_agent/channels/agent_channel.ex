defmodule PtahServerAgent.AgentChannel do
  alias PtahServer.Repo
  require Logger
  use PtahServerAgent, :channel

  @impl true
  def join("agent:daemon", payload, socket) do
    Logger.info("daemon join: #{inspect(payload)}")

    if authorized?(Map.get(payload, "token")) do
      # TODO: update agent state in persistence.

      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  @impl true
  def handle_in("ping", payload, socket) do
    Logger.info("ping")

    {:reply, {:ok, payload}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (agent:lobby).
  @impl true
  def handle_in("shout", payload, socket) do
    broadcast(socket, "shout", payload)
    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(token) do
    Logger.info("AUTHORIZED: #{inspect(token)}")

    # TODO: Repo.get by token false if not exists
    true
  end
end
