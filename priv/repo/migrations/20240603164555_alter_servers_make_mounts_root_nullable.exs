defmodule PtahServer.Repo.Migrations.AlterServersMakeMountsRootNullable do
  use Ecto.Migration

  def change do
    alter table(:servers) do
      modify :mounts_root, :string, null: true
    end
  end
end
