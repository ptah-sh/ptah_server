defmodule PtahServer.Swarms.Swarm do
  use Ecto.Schema
  import Ecto.Changeset
  import PtahServer.Changeset

  schema "swarms" do
    field :name, :string
    field :team_id, :integer
    field :ext_id, :string

    has_many :stacks, PtahServer.Stacks.Stack

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(swarm, attrs) do
    swarm
    |> cast(attrs, [:name, :ext_id])
    |> validate_required([:name])
    |> maybe_put_team_id()
    |> validate_unique([:team_id, :name])
  end
end
