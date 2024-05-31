defmodule PtahServer.Repo.Migrations.AlterServersAddRoleColumn do
  use Ecto.Migration

  def change do
    execute "CREATE TYPE server_role AS ENUM ('manager', 'worker')", "DROP TYPE server_role"

    alter table(:servers) do
      add :role, :server_role, null: true
    end
  end
end
