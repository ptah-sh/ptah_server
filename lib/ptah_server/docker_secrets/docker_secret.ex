defmodule PtahServer.DockerSecrets.DockerSecret do
  use Ecto.Schema
  import Ecto.Changeset
  import PtahServer.Changeset

  schema "docker_secrets" do
    field :name, PtahServer.Ecto.Slug
    field :ext_id, :string

    belongs_to :team, PtahServer.Teams.Team
    belongs_to :swarm, PtahServer.Swarms.Swarm

    field :data, :string, virtual: true, redact: true

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(docker_secret, attrs) do
    docker_secret
    |> cast(attrs, [:name, :swarm_id, :data])
    |> validate_required([:name, :swarm_id, :data])
    |> maybe_put_team_id()
  end
end
