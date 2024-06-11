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
    |> ensure_api_key()
  end

  def get_default_team() do
    %PtahServer.Teams.Team{name: "My Team"}
  end

  defp ensure_api_key(changeset) do
    api_key = get_field(changeset, :api_key)

    if api_key == nil or api_key == "" do
      put_change(
        changeset,
        :api_key,
        Phoenix.Token.sign(
          PtahServerWeb.Endpoint,
          "team_api_key",
          get_field(changeset, :name)
        )
      )
    else
      changeset
    end
  end
end
