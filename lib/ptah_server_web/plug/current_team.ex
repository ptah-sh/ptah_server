defmodule PtahServerWeb.Plug.CurrentTeam do
  use PtahServerWeb, :verified_routes

  alias PtahServer.Teams
  alias PtahServer.Teams.TeamUser
  alias PtahServer.Repo
  require Logger

  import Plug.Conn
  # import Phoenix.Controller
  import Ecto.Query

  def on_mount(:assign_nil_team, _params, _session, socket) do
    {:cont, Phoenix.Component.assign(socket, :current_team, nil)}
  end

  def on_mount(:ensure_team_selection, _params, _session, socket) do
    if Map.has_key?(socket.assigns, :current_team) do
      {:cont, socket, :current_team, nil}
    else
      # TODO: select the last picked team instead of the first one.
      team = get_default_team(socket)

      socket =
        Phoenix.Component.assign(socket, :current_team, team)

      {:cont, socket}
    end
  end

  def on_mount(:ensure_team_access, params, _session, socket) do
    team = Repo.get!(Teams.Team, params["team_id"], skip_team_id: true)

    exists =
      from tu in TeamUser,
        where: tu.team_id == ^team.id and tu.user_id == ^socket.assigns.current_user.id

    assigned_to_team =
      Repo.exists?(
        exists,
        skip_team_id: true
      )

    if assigned_to_team do
      Repo.put_team_id(team.id)

      socket =
        socket
        |> Phoenix.Component.assign(:current_team, team)
        |> Phoenix.Component.assign(
          :user_teams,
          Teams.list_by_user_id(socket.assigns.current_user.id)
        )

      {:cont, Phoenix.Component.assign(socket, :current_team, team)}
    else
      socket =
        socket
        |> Phoenix.LiveView.put_flash(:error, "You don't have access to this team.")
        |> Phoenix.LiveView.redirect(to: ~p"/")

      {:halt, socket}
    end
  end

  def fetch_default_team(conn, _opts) do
    conn
    |> assign(:current_team, get_default_team(conn))
    |> assign(:user_teams, Teams.list_by_user_id(conn.assigns.current_user.id))
  end

  defp get_default_team(socket) do
    current_user = socket.assigns.current_user

    if current_user do
      team_query =
        from t in Teams.TeamUser,
          where: t.user_id == ^socket.assigns.current_user.id,
          limit: 1,
          preload: [:team]

      team = Repo.one!(team_query, skip_team_id: true).team

      Repo.put_team_id(team.id)

      team
    else
      nil
    end
  end
end
