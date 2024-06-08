defmodule PtahServer.Repo.Migrations.AlterDockerRegistriesAddUsernameColumn do
  use Ecto.Migration

  def change do
    alter table(:docker_registries) do
      add :username, :string, null: false
    end
  end
end
