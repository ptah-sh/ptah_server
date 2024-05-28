defmodule PtahServer.Repo.Migrations.CreateStacks do
  use Ecto.Migration

  def change do
    create table(:stacks) do
      add :team_id, references(:teams, on_delete: :delete_all), null: false
      add :name, :string, null: false
      add :stack_name, :string, null: false
      add :stack_version, :string, null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:stacks, [:team_id, :name])
  end
end
