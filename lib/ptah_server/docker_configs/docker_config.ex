defmodule PtahServer.DockerConfigs.DockerConfig do
  use Ecto.Schema
  import Ecto.Changeset
  import PtahServer.Changeset

  schema "docker_configs" do
    field :name, :string
    field :ext_id, :string

    belongs_to :team, PtahServer.Teams.Team
    belongs_to :swarm, PtahServer.Swarms.Swarm

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(docker_config, attrs) do
    docker_config
    |> cast(attrs, [:swarm_id, :name, :ext_id])
    |> validate_required([:swarm_id, :name])
    |> maybe_put_team_id()
  end
end
