defmodule PtahServer.SwarmsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `PtahServer.Swarms` context.
  """

  @doc """
  Generate a swarm.
  """
  def swarm_fixture(attrs \\ %{}) do
    {:ok, swarm} =
      attrs
      |> Enum.into(%{
        ext_id: "some ext_id",
        name: "some name",
        team_id: 42
      })
      |> PtahServer.Swarms.create_swarm()

    swarm
  end
end
