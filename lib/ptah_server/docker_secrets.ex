defmodule PtahServer.DockerSecrets do
  @moduledoc """
  The DockerSecrets context.
  """

  import Ecto.Query, warn: false
  alias PtahServer.Repo

  alias PtahServer.DockerSecrets.DockerSecret

  @doc """
  Returns the list of docker_secrets.

  ## Examples

      iex> list_docker_secrets()
      [%DockerSecret{}, ...]

  """
  def list_docker_secrets do
    Repo.all(DockerSecret)
  end

  @doc """
  Gets a single docker_secret.

  Raises `Ecto.NoResultsError` if the Docker secret does not exist.

  ## Examples

      iex> get_docker_secret!(123)
      %DockerSecret{}

      iex> get_docker_secret!(456)
      ** (Ecto.NoResultsError)

  """
  def get_docker_secret!(id), do: Repo.get!(DockerSecret, id)

  @doc """
  Creates a docker_secret.

  ## Examples

      iex> create_docker_secret(%{field: value})
      {:ok, %DockerSecret{}}

      iex> create_docker_secret(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_docker_secret(attrs \\ %{}) do
    %DockerSecret{}
    |> DockerSecret.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a docker_secret.

  ## Examples

      iex> update_docker_secret(docker_secret, %{field: new_value})
      {:ok, %DockerSecret{}}

      iex> update_docker_secret(docker_secret, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_docker_secret(%DockerSecret{} = docker_secret, attrs) do
    docker_secret
    |> DockerSecret.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a docker_secret.

  ## Examples

      iex> delete_docker_secret(docker_secret)
      {:ok, %DockerSecret{}}

      iex> delete_docker_secret(docker_secret)
      {:error, %Ecto.Changeset{}}

  """
  def delete_docker_secret(%DockerSecret{} = docker_secret) do
    Repo.delete(docker_secret)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking docker_secret changes.

  ## Examples

      iex> change_docker_secret(docker_secret)
      %Ecto.Changeset{data: %DockerSecret{}}

  """
  def change_docker_secret(%DockerSecret{} = docker_secret, attrs \\ %{}) do
    DockerSecret.changeset(docker_secret, attrs)
  end
end
