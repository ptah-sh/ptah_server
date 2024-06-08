defmodule PtahServer.Repo.Migrations.AlterDockerRegistriesAddEndpointColumn do
  use Ecto.Migration

  def change do
    alter table(:docker_registries) do
      add :endpoint, :string, null: false
    end
  end
end
