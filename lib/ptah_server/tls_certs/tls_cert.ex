defmodule PtahServer.TlsCerts.TlsCert do
  use Ecto.Schema
  import Ecto.Changeset
  import PtahServer.Changeset

  schema "tls_certs" do
    field :name, PtahServer.Ecto.Slug

    belongs_to :team, PtahServer.Teams.Team
    belongs_to :swarm, PtahServer.Swarms.Swarm
    belongs_to :cert_config, PtahServer.DockerConfigs.DockerConfig
    belongs_to :key_secret, PtahServer.DockerSecrets.DockerSecret

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(tls_cert, attrs) do
    tls_cert
    |> cast(attrs, [:name, :swarm_id])
    |> cast_assoc(:cert_config,
      with: &PtahServer.DockerConfigs.DockerConfig.changeset/2,
      required: true
    )
    |> cast_assoc(:key_secret,
      with: &PtahServer.DockerSecrets.DockerSecret.changeset/2,
      required: true
    )
    |> validate_required([:name, :swarm_id])
    |> maybe_put_team_id()
  end
end
