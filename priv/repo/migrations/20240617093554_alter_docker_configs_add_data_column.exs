defmodule PtahServer.Repo.Migrations.AlterDockerConfigsAddDataColumn do
  use Ecto.Migration

  def change do
    alter table(:docker_configs) do
      add :data, :string
    end

    execute "UPDATE docker_configs SET data = '' WHERE data IS NULL", ""

    alter table(:docker_configs) do
      modify :data, :string, null: false
    end
  end
end
