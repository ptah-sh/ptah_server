defmodule PtahServer.Repo.Migrations.CreateDockerRegistries do
  use Ecto.Migration

  def change do
    create table(:docker_registries) do
      add :name, :string, null: false
      add :team_id, references(:teams, on_delete: :delete_all), null: false
      add :swarm_id, references(:swarms, on_delete: :delete_all), null: false
      add :config_id, references(:docker_configs, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:docker_registries, [:team_id])
    create index(:docker_registries, [:swarm_id])
    create index(:docker_registries, [:config_id])

    create unique_index(:docker_registries, [:team_id, :name])
  end
end
