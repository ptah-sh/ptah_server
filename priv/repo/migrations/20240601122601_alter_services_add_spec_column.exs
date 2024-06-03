defmodule PtahServer.Repo.Migrations.AlterServicesAddSpecColumn do
  use Ecto.Migration

  def change do
    alter table(:services) do
      add :spec, :jsonb, null: false
      remove :published_ports
    end
  end
end
