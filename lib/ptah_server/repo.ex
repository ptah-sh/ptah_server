defmodule PtahServer.Repo do
  require Ecto.Query
  require Logger

  use Ecto.Repo,
    otp_app: :ptah_server,
    adapter: Ecto.Adapters.Postgres

  @tenant_key {__MODULE__, :team_id}

  @impl true
  def prepare_query(_operation, query, opts) do
    cond do
      opts[:skip_team_id] || opts[:schema_migration] ->
        {query, opts}

      team_id = opts[:team_id] ->
        {Ecto.Query.where(query, team_id: ^team_id), opts}

      true ->
        raise %ArgumentError{message: "Missing required option :team_id or :skip_team_id"}
    end
  end

  @impl true
  def default_options(_operation) do
    [team_id: get_team_id()]
  end

  def put_team_id(team_id) do
    Process.put(@tenant_key, team_id)
  end

  def get_team_id() do
    Process.get(@tenant_key)
  end
end
