defmodule PtahServer.Repo.Migrations.AlterServersAddSwarmIdColumn do
  use Ecto.Migration

  def change do
    alter table(:servers) do
      add :swarm_id, references(:swarms, on_delete: :delete_all), null: true
    end
  end
end
