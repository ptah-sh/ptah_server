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

  alias PtahServer.Repo
  alias PtahServer.Servers.Server

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

      Logger.debug("METASMETASMETAS, #{inspect(metas)}")
    end

    {:ok, state}
  end

  def track_server(server, agent) do
    Server.update_last_seen(server)

    track(self(), team_topic(server.team_id), server.id, agent)
  end

  def update_server(server, agent) do
    current = get_agent(server.id)

    update(self(), team_topic(server.team_id), server.id, Map.merge(current, agent))
  end

  def untrack_server(server) do
    Server.update_last_seen(server)

    untrack(self(), team_topic(server.team_id), server.id)
  end

  def list_online_servers(team_id) do
    list(team_topic(team_id))
  end

  def get_agent(server_id) do
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

    %{metas: [%{socket: socket}]} = get_by_key(team_topic(server.team_id), server.id)

    Phoenix.Channel.push(socket, "swarm:create", %{
      meta: %{
        swarm_id: swarm.id
      }
    })
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
