defmodule PtahServer.Repo.Migrations.CreateServices do
  use Ecto.Migration

  def change do
    create table(:services) do
      add :team_id, references(:teams, on_delete: :delete_all), null: false
      add :name, :string, null: false
      add :ext_id, :string, null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:services, [:team_id, :name])
  end
end
