defmodule PtahServer.Repo.Migrations.AlterSwarmsSetExtIdNullable do
  use Ecto.Migration

  def change do
    alter table(:swarms) do
      modify :ext_id, :string, null: true
    end
  end
end
