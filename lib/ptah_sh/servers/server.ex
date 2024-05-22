defmodule PtahSh.Servers.Server do
  alias PtahSh.Repo
  use Ecto.Schema
  import Ecto.Changeset

  schema "servers" do
    field :name, :string
    field :agent_token, :string
    field :last_seen_at, :naive_datetime

    belongs_to :team, PtahSh.Teams.Team

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(server, attrs) do
    server
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> ensure_team_id()
    |> ensure_agent_token()
    |> unsafe_validate_unique([:name], PtahSh.Repo)
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
        Phoenix.Token.sign(PtahShWeb.Endpoint, "agent", get_field(changeset, :team_id))
      )
    end
  end
end
