defmodule PtahServer.Repo.Migrations.AlterTeamsAddApiKeyColumn do
  use Ecto.Migration

  def change do
    alter table(:teams) do
      add :api_key, :string
    end

    execute "UPDATE teams SET api_key = 'ptah' WHERE api_key IS NULL", ""

    alter table(:teams) do
      modify :api_key, :string, null: false
    end

    create unique_index(:teams, [:api_key])
  end
end
