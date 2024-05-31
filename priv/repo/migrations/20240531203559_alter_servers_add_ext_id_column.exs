defmodule PtahServer.Repo.Migrations.AlterServersAddExtIdColumn do
  use Ecto.Migration

  def change do
    alter table(:servers) do
      add :ext_id, :string, null: false, default: ""
    end
  end
end
