defmodule PtahServer.DockerRegistries.DockerRegistry do
  use Ecto.Schema
  import Ecto.Changeset
  import PtahServer.Changeset

  schema "docker_registries" do
    field :name, :string
    field :username, :string
    field :endpoint, :string
    field :password, :string, virtual: true, redact: true

    # field :team_id, :id
    # field :swarm_id, :id
    # field :config_id, :id

    belongs_to :team, PtahServer.Teams.Team
    belongs_to :swarm, PtahServer.Swarms.Swarm
    belongs_to :config, PtahServer.DockerConfigs.DockerConfig

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(docker_registry, attrs) do
    # TODO: add validate_belongs_to_team(...) for swarms, configs and all other data.
    docker_registry
    |> cast(attrs, [
      :team_id,
      :swarm_id,
      :config_id,
      :name,
      :endpoint,
      :username,
      :password
    ])
    |> validate_required([
      :swarm_id,
      :config_id,
      :name,
      :endpoint,
      :username,
      :password
    ])
    |> maybe_put_team_id()
  end
end
