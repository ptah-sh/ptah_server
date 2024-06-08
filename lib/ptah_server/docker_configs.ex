defmodule PtahServer.DockerConfigs do
  @moduledoc """
  The DockerConfigs context.
  """

  import Ecto.Query, warn: false
  alias PtahServer.Repo

  alias PtahServer.DockerConfigs.DockerConfig

  @doc """
  Returns the list of docker_configs.

  ## Examples

      iex> list_docker_configs()
      [%DockerConfig{}, ...]

  """
  def list_docker_configs do
    Repo.all(DockerConfig)
  end

  @doc """
  Gets a single docker_config.

  Raises `Ecto.NoResultsError` if the Docker config does not exist.

  ## Examples

      iex> get_docker_config!(123)
      %DockerConfig{}

      iex> get_docker_config!(456)
      ** (Ecto.NoResultsError)

  """
  def get_docker_config!(id), do: Repo.get!(DockerConfig, id)

  @doc """
  Creates a docker_config.

  ## Examples

      iex> create_docker_config(%{field: value})
      {:ok, %DockerConfig{}}

      iex> create_docker_config(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_docker_config(attrs \\ %{}) do
    %DockerConfig{}
    |> DockerConfig.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a docker_config.

  ## Examples

      iex> update_docker_config(docker_config, %{field: new_value})
      {:ok, %DockerConfig{}}

      iex> update_docker_config(docker_config, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_docker_config(%DockerConfig{} = docker_config, attrs) do
    docker_config
    |> DockerConfig.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a docker_config.

  ## Examples

      iex> delete_docker_config(docker_config)
      {:ok, %DockerConfig{}}

      iex> delete_docker_config(docker_config)
      {:error, %Ecto.Changeset{}}

  """
  def delete_docker_config(%DockerConfig{} = docker_config) do
    Repo.delete(docker_config)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking docker_config changes.

  ## Examples

      iex> change_docker_config(docker_config)
      %Ecto.Changeset{data: %DockerConfig{}}

  """
  def change_docker_config(%DockerConfig{} = docker_config, attrs \\ %{}) do
    DockerConfig.changeset(docker_config, attrs)
  end
end
