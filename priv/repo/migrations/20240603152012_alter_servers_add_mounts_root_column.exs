defmodule PtahServer.Repo.Migrations.AlterServersAddMountsRootColumn do
  use Ecto.Migration

  def change do
    alter table(:servers) do
      add :mounts_root, :string
    end

    execute "UPDATE servers SET mounts_root = '/home/ptah/mounts' WHERE mounts_root IS NULL", ""

    alter table(:servers) do
      modify :mounts_root, :string, null: false
    end
  end
end
