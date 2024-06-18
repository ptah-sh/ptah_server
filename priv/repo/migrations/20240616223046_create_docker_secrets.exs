defmodule PtahServer.Repo.Migrations.CreateDockerSecrets do
  use Ecto.Migration

  def change do
    create table(:docker_secrets) do
      add :name, :string, null: false

      add :ext_id, :string

      add :team_id, references(:teams, on_delete: :delete_all), null: false
      add :swarm_id, references(:swarms, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:docker_secrets, [:swarm_id])
    create index(:docker_secrets, [:team_id])
  end
end
