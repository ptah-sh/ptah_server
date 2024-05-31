defmodule PtahServer.Repo.Migrations.AlterServicesAddServiceNameColumn do
  use Ecto.Migration

  def change do
    alter table(:services) do
      add :service_name, :string, null: false
    end
  end
end
