defmodule PtahServer.Changeset do
  import Ecto.Changeset

  def validate_unique(changeset, fields) do
    changeset
    |> unsafe_validate_unique(fields, PtahServer.Repo)
    |> unique_constraint(fields)
  end
end
