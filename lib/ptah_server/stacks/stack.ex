defmodule PtahServer.Stacks.Stack do
  alias PtahServer.Services.Service
  use Ecto.Schema
  import Ecto.Changeset
  import PtahServer.Changeset

  schema "stacks" do
    field :name, :string
    # field :team_id, :integer
    field :stack_name, :string
    field :stack_version, :string

    belongs_to :swarm, PtahServer.Swarms.Swarm
    belongs_to :team, PtahServer.Teams.Team

    has_many :services, Service, on_replace: :delete

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(stack, attrs) do
    stack
    |> cast(attrs, [:swarm_id, :name, :stack_name, :stack_version])
    |> cast_assoc(:services,
      required: true,
      with: &Service.changeset/2,
      sort_param: :services_sort,
      drop_param: :services_drop
    )
    |> validate_required([:swarm_id, :name, :stack_name, :stack_version])
    |> validate_unique_in_team([:name])
  end
end
