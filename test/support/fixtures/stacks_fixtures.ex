defmodule PtahServer.StacksFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `PtahServer.Stacks` context.
  """

  @doc """
  Generate a stack.
  """
  def stack_fixture(attrs \\ %{}) do
    {:ok, stack} =
      attrs
      |> Enum.into(%{
        name: "some name",
        stack_name: "some stack_name",
        stack_version: "some stack_version",
        team_id: 42
      })
      |> PtahServer.Stacks.create_stack()

    stack
  end
end
