defmodule PtahServer.DockerConfigs.DockerConfig do
  use Ecto.Schema
  import Ecto.Changeset
  import PtahServer.Changeset

  schema "docker_configs" do
    field :name, PtahServer.Ecto.Slug
    field :ext_id, :string
    field :data, :string, redact: true

    belongs_to :team, PtahServer.Teams.Team
    belongs_to :swarm, PtahServer.Swarms.Swarm

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(docker_config, attrs) do
    docker_config
    |> cast(attrs, [:swarm_id, :name, :data])
    |> validate_required([:swarm_id, :name, :data])
    |> maybe_put_team_id()
  end
end
