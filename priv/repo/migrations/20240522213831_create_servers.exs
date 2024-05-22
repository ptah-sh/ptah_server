defmodule PtahSh.Repo.Migrations.CreateServers do
  use Ecto.Migration

  def change do
    create table(:servers) do
      add :team_id, references(:teams, on_delete: :delete_all), null: false
      add :name, :citext, null: false
      add :agent_token, :string, null: false
      add :last_seen_at, :naive_datetime

      timestamps(type: :utc_datetime)
    end

    create unique_index(:servers, [:team_id, :name])
    create unique_index(:servers, :agent_token)
  end
end
