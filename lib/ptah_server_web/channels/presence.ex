# TODO: move this presence to ptah_server_agent
defmodule PtahServerWeb.Presence do
  @moduledoc """
  Provides presence tracking to channels and processes.

  See the [`Phoenix.Presence`](https://hexdocs.pm/phoenix/Phoenix.Presence.html)
  docs for more details.
  """
  use Phoenix.Presence,
    otp_app: :ptah_server,
    pubsub_server: PtahServer.PubSub

  alias PtahServer.Servers.Server

  require Logger

  def init(_opts) do
    {:ok, %{}}
  end

  def handle_metas(topic, %{joins: joins, leaves: leaves} = _diff, presences, state) do
    for {server_id, %{metas: metas}} <- joins do
      Phoenix.PubSub.broadcast(
        PtahServer.PubSub,
        "proxy:team:14",
        {__MODULE__, {:join, server_id, metas}}
      )
    end

    for {server_id, %{metas: metas}} <- leaves do
      Phoenix.PubSub.broadcast(
        PtahServer.PubSub,
        "proxy:team:14",
        {__MODULE__, {:leave, server_id, metas}}
      )
    end

    {:ok, state}
  end

  def track_server(server) do
    Server.update_last_seen(server)

    track(self(), "team:14", server.id, %{})
  end

  def untrack_server(server) do
    Server.update_last_seen(server)

    untrack(self(), "team:14", server.id)
  end

  def list_online_servers(team_id) do
    list("team:#{team_id}")
  end

  def subscribe() do
    Phoenix.PubSub.subscribe(PtahServer.PubSub, "proxy:team:14")
  end
end
