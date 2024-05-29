defmodule PtahServer.Stacks.Stack do
  alias PtahServer.Services.Service
  use Ecto.Schema
  import Ecto.Changeset

  schema "stacks" do
    field :name, :string
    # field :team_id, :integer
    field :stack_name, :string
    field :stack_version, :string

    belongs_to :team, PtahServer.Teams.Team

    has_many :services, Service

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(stack, attrs) do
    stack
    |> cast(attrs, [:name, :stack_name, :stack_version])
    |> cast_assoc(:services, required: true, with: &Service.changeset/2)
    |> validate_required([:name, :stack_name, :stack_version])
  end
end
