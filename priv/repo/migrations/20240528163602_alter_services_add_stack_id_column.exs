defmodule PtahServer.Repo.Migrations.AlterServicesAddStackIdColumn do
  use Ecto.Migration

  def change do
    alter table(:services) do
      add :stack_id, references(:stacks, on_delete: :delete_all), null: false
    end
  end
end
