defmodule PtahServer.Repo.Migrations.AlterServersAddNetworksColumn do
  use Ecto.Migration

  def change do
    alter table(:servers) do
      add :networks, :jsonb
    end
  end
end
