defmodule PtahServer.DockerConfigsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `PtahServer.DockerConfigs` context.
  """

  @doc """
  Generate a docker_config.
  """
  def docker_config_fixture(attrs \\ %{}) do
    {:ok, docker_config} =
      attrs
      |> Enum.into(%{
        ext_id: "some ext_id",
        name: "some name"
      })
      |> PtahServer.DockerConfigs.create_docker_config()

    docker_config
  end
end
