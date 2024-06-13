defmodule PtahServer.DockerRegistries do
  @moduledoc """
  The DockerRegistries context.
  """

  import Ecto.Query, warn: false
  alias PtahServer.Repo

  alias PtahServer.DockerRegistries.DockerRegistry

  @doc """
  Returns the list of docker_registries.

  ## Examples

      iex> list_docker_registries()
      [%DockerRegistry{}, ...]

  """
  def list_docker_registries do
    Repo.all(DockerRegistry)
  end

  def list_by_swarm_id(swarm_id) do
    Repo.all(from s in DockerRegistry, where: s.swarm_id == ^swarm_id, order_by: [asc: s.name])
  end

  @doc """
  Gets a single docker_registry.

  Raises `Ecto.NoResultsError` if the Docker registry does not exist.

  ## Examples

      iex> get_docker_registry!(123)
      %DockerRegistry{}

      iex> get_docker_registry!(456)
      ** (Ecto.NoResultsError)

  """
  def get_docker_registry!(id), do: Repo.get!(DockerRegistry, id)

  @doc """
  Creates a docker_registry.

  ## Examples

      iex> create_docker_registry(%{field: value})
      {:ok, %DockerRegistry{}}

      iex> create_docker_registry(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_docker_registry(attrs \\ %{}, config_attrs \\ %{}) do
    %DockerRegistry{}
    |> DockerRegistry.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:config, config_attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a docker_registry.

  ## Examples

      iex> update_docker_registry(docker_registry, %{field: new_value})
      {:ok, %DockerRegistry{}}

      iex> update_docker_registry(docker_registry, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_docker_registry(%DockerRegistry{} = docker_registry, attrs) do
    docker_registry
    |> DockerRegistry.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a docker_registry.

  ## Examples

      iex> delete_docker_registry(docker_registry)
      {:ok, %DockerRegistry{}}

      iex> delete_docker_registry(docker_registry)
      {:error, %Ecto.Changeset{}}

  """
  def delete_docker_registry(%DockerRegistry{} = docker_registry) do
    Repo.delete(docker_registry)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking docker_registry changes.

  ## Examples

      iex> change_docker_registry(docker_registry)
      %Ecto.Changeset{data: %DockerRegistry{}}

  """
  def change_docker_registry(%DockerRegistry{} = docker_registry, attrs \\ %{}) do
    DockerRegistry.changeset(docker_registry, attrs)
  end
end
