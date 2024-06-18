defmodule PtahServer.Repo.Migrations.AlterServicesAddSwarmIdColumn do
  use Ecto.Migration

  def change do
    alter table(:services) do
      add :swarm_id, :integer
    end

    execute "UPDATE services SET swarm_id = stacks.swarm_id FROM stacks WHERE stacks.id = services.stack_id"

    alter table(:services) do
      modify :swarm_id, references(:swarms, on_delete: :delete_all), null: false
    end
  end
end
