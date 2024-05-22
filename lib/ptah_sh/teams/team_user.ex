defmodule PtahSh.Teams.TeamUser do
  use Ecto.Schema
  import Ecto.Changeset

  require Logger

  schema "teams_users" do
    field :team_id, :integer
    field :user_id, :integer

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(teams_users, attrs) do
    teams_users
    |> cast(attrs, [:team_id, :user_id])
    |> validate_required([:team_id, :user_id])
  end
end
