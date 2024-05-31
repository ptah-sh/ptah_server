defmodule PtahServer.Servers.Server do
  alias PtahServer.Repo
  use Ecto.Schema
  import Ecto.Changeset

  schema "servers" do
    field :name, :string
    field :agent_token, :string
    field :last_seen_at, :naive_datetime
    field :role, Ecto.Enum, values: [:manager, :worker]

    belongs_to :team, PtahServer.Teams.Team
    belongs_to :swarm, PtahServer.Swarms.Swarm

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(server, attrs) do
    server
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> ensure_team_id()
    |> ensure_agent_token()
    |> unsafe_validate_unique([:name], PtahServer.Repo)
    |> unique_constraint([:name])
  end

  defp ensure_team_id(changeset) do
    if get_field(changeset, :team_id) do
      changeset
    else
      put_change(changeset, :team_id, Repo.get_team_id())
    end
  end

  defp ensure_agent_token(changeset) do
    if get_field(changeset, :agent_token) do
      changeset
    else
      put_change(
        changeset,
        :agent_token,
        Phoenix.Token.sign(PtahServerWeb.Endpoint, "agent", get_field(changeset, :team_id))
      )
    end
  end

  def get_by_token(token) do
    Repo.get_by(__MODULE__, [agent_token: token], skip_team_id: true)
  end

  def update_last_seen(server) do
    change(server, %{last_seen_at: NaiveDateTime.utc_now(:second)})
    |> Repo.update()
  end
end
