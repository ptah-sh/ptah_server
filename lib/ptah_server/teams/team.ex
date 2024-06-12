defmodule PtahServer.Teams.Team do
  use Ecto.Schema
  import Ecto.Changeset

  # @primary_key {:team_id, :id, autogenerate: true}

  schema "teams" do
    field :name, :string
    field :api_key, :string

    many_to_many :members, PtahServer.Accounts.User, join_through: PtahServer.Teams.TeamUser

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(team, attrs) do
    team
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end

  def get_default_team_attrs(email) do
    %{
      name: "My Team",
      api_key:
        Phoenix.Token.sign(
          PtahServerWeb.Endpoint,
          "team_api_key",
          email
        )
    }
  end
end
