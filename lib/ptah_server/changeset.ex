defmodule PtahServer.Changeset do
  alias PtahServer.Repo
  import Ecto.Changeset

  def maybe_put_team_id(changeset) do
    if get_change(changeset, :team_id) do
      changeset
    else
      put_change(changeset, :team_id, Repo.get_team_id())
    end
  end

  def validate_unique(changeset, fields) do
    changeset
    |> unsafe_validate_unique(fields, PtahServer.Repo)
    |> unique_constraint(fields)
  end

  def validate_unique_in_team(changeset, fields) do
    changeset
    |> validate_unique(fields ++ [:team_id])
  end
end
