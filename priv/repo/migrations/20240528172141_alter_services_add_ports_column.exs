defmodule PtahServer.Repo.Migrations.AlterServicesAddPortsColumn do
  use Ecto.Migration

  def change do
    alter table(:services) do
      add :published_ports, :jsonb, null: false
    end
  end
end
