defmodule PtahServer.DockerRegistriesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `PtahServer.DockerRegistries` context.
  """

  @doc """
  Generate a docker_registry.
  """
  def docker_registry_fixture(attrs \\ %{}) do
    {:ok, docker_registry} =
      attrs
      |> Enum.into(%{
        name: "some name"
      })
      |> PtahServer.DockerRegistries.create_docker_registry()

    docker_registry
  end
end
