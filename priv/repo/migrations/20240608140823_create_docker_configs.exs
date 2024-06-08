defmodule PtahServer.Repo.Migrations.CreateDockerConfigs do
  use Ecto.Migration

  def change do
    create table(:docker_configs) do
      add :name, :string, null: false
      add :ext_id, :string, null: false, default: ""
      add :team_id, references(:teams, on_delete: :delete_all), null: false
      add :swarm_id, references(:swarms, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:docker_configs, [:team_id])
    create index(:docker_configs, [:swarm_id])

    create unique_index(:docker_configs, [:swarm_id, :name])
  end
end
