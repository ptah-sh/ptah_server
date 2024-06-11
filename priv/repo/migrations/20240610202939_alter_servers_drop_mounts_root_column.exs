defmodule PtahServer.Repo.Migrations.AlterServersDropMountsRootColumn do
  use Ecto.Migration

  def change do
    alter table(:servers) do
      remove :mounts_root
    end
  end
end
