defmodule PtahServer.Repo.Migrations.AlterAllTablesRemoveUniqueIndexes do
  use Ecto.Migration

  def change do
    drop index(:docker_configs, [:swarm_id, :name])
    drop index(:docker_registries, [:team_id, :name])
    drop index(:servers, [:team_id, :name])
    drop index(:services, [:team_id, :name])
    drop index(:stacks, [:team_id, :name])
    drop index(:swarms, [:team_id, :name])
  end
end
