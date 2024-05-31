defmodule PtahServer.Repo.Migrations.AlterStacksAddSwarmIdColumn do
  use Ecto.Migration

  def change do
    alter table(:stacks) do
      add :swarm_id, references(:swarms, on_delete: :delete_all), null: false
    end
  end
end
