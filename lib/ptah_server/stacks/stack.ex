defmodule PtahServer.Stacks.Stack do
  use Ecto.Schema
  import Ecto.Changeset

  schema "stacks" do
    field :name, :string
    field :team_id, :integer
    field :stack_name, :string
    field :stack_version, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(stack, attrs) do
    stack
    |> cast(attrs, [:team_id, :name, :stack_name, :stack_version])
    |> validate_required([:team_id, :name, :stack_name, :stack_version])
  end
end
