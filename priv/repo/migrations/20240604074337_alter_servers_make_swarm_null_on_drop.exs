defmodule PtahServer.Repo.Migrations.AlterServersMakeSwarmNullOnDrop do
  use Ecto.Migration

  def up do
    execute "ALTER TABLE servers DROP CONSTRAINT servers_swarm_id_fkey"

    alter table(:servers) do
      modify :swarm_id, references(:swarms, on_delete: :nilify_all), null: true
    end
  end

  def down do
    execute "ALTER TABLE servers DROP CONSTRAINT servers_swarm_id_fkey"

    alter table(:servers) do
      modify :swarm_id, references(:swarms, on_delete: :delete_all), null: true
    end
  end
end
