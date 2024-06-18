defmodule PtahServer.Repo.Migrations.AlterDockerConfigsChangeDataColum do
  use Ecto.Migration

  def change do
    alter table(:docker_configs) do
      modify :data, :text, null: false
    end
  end
end
