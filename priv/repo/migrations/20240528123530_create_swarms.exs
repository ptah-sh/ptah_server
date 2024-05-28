defmodule PtahServer.Repo.Migrations.CreateSwarms do
  use Ecto.Migration

  def change do
    create table(:swarms) do
      add :team_id, references(:teams, on_delete: :delete_all), null: false
      add :name, :string, null: false
      add :ext_id, :string, null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:swarms, [:team_id, :name])
  end
end
