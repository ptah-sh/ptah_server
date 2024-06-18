defmodule PtahServer.DockerSecretsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `PtahServer.DockerSecrets` context.
  """

  @doc """
  Generate a docker_secret.
  """
  def docker_secret_fixture(attrs \\ %{}) do
    {:ok, docker_secret} =
      attrs
      |> Enum.into(%{
        ext_id: "some ext_id",
        name: "some name"
      })
      |> PtahServer.DockerSecrets.create_docker_secret()

    docker_secret
  end
end
