defmodule PtahServer.Repo.Migrations.CreateTlsCerts do
  use Ecto.Migration

  def change do
    create table(:tls_certs) do
      add :name, :string, null: false
      add :team_id, references(:teams, on_delete: :delete_all), null: false
      add :swarm_id, references(:swarms, on_delete: :delete_all), null: false
      add :cert_config_id, references(:docker_configs, on_delete: :delete_all), null: false
      add :key_secret_id, references(:docker_secrets, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:tls_certs, [:team_id])
  end
end
