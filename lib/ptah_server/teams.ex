defmodule PtahServer.Teams do
  alias PtahServer.Teams.Team
  alias PtahServer.Teams.TeamUser

  alias PtahServer.Repo

  import Ecto.Query

  def list_by_user_id(user_id) do
    query = from tu in TeamUser, where: tu.user_id == ^user_id, preload: [:team]
    # dbg()

    Repo.all(query, skip_team_id: true)
    |> Enum.map(& &1.team)
  end

  def get_team!(id), do: Repo.get!(Team, id, skip_team_id: true)

  def change_team(%Team{} = team, attrs \\ %{}) do
    Team.changeset(team, attrs)
  end

  def create_team(owner, attrs \\ %{}) do
    %Team{}
    |> Team.changeset(attrs)
    |> Ecto.Changeset.put_change(:members, [owner])
    |> Ecto.Changeset.put_change(
      :api_key,
      Phoenix.Token.sign(PtahServerWeb.Endpoint, "team_api_key", owner.email)
    )
    |> Repo.insert()
  end
end
