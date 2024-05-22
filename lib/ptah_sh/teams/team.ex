defmodule PtahSh.Teams.Team do
  use Ecto.Schema
  import Ecto.Changeset

  # @primary_key {:team_id, :id, autogenerate: true}

  schema "teams" do
    field :name, :string

    many_to_many :members, PtahSh.Accounts.User, join_through: PtahSh.Teams.TeamUser

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(team, attrs) do
    team
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end

  def get_default_team() do
    %PtahSh.Teams.Team{name: "My Team"}
  end
end
