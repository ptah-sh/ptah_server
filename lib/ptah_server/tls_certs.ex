defmodule PtahServer.TlsCerts do
  @moduledoc """
  The TlsCerts context.
  """

  import Ecto.Query, warn: false
  alias PtahServer.Swarms
  alias PtahServerWeb.Presence
  alias PtahServer.Repo

  alias PtahServer.TlsCerts.TlsCert

  @doc """
  Returns the list of tls_certs.

  ## Examples

      iex> list_tls_certs()
      [%TlsCert{}, ...]

  """
  def list_tls_certs do
    Repo.all(TlsCert)
  end

  @doc """
  Gets a single tls_cert.

  Raises `Ecto.NoResultsError` if the Tls cert does not exist.

  ## Examples

      iex> get_tls_cert!(123)
      %TlsCert{}

      iex> get_tls_cert!(456)
      ** (Ecto.NoResultsError)

  """
  def get_tls_cert!(id), do: Repo.get!(TlsCert, id)

  @doc """
  Creates a tls_cert.

  ## Examples

      iex> create_tls_cert(%{field: value})
      {:ok, %TlsCert{}}

      iex> create_tls_cert(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_tls_cert(attrs \\ %{}) do
    {:ok, tls_cert} =
      %TlsCert{}
      |> TlsCert.changeset(attrs)
      |> Repo.insert()

    Presence.docker_config_create(tls_cert.cert_config)
    Presence.docker_secret_create(tls_cert.key_secret)

    Swarms.rebuild_caddy(Repo.preload(tls_cert, :swarm).swarm)

    {:ok, tls_cert}
  end

  @doc """
  Updates a tls_cert.

  ## Examples

      iex> update_tls_cert(tls_cert, %{field: new_value})
      {:ok, %TlsCert{}}

      iex> update_tls_cert(tls_cert, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_tls_cert(%TlsCert{} = tls_cert, attrs) do
    # TODO: trigger secrets and configs updates in Docker and Caddy rebuild
    raise "UPDATE NOT YET SUPPORTED"

    tls_cert
    |> TlsCert.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a tls_cert.

  ## Examples

      iex> delete_tls_cert(tls_cert)
      {:ok, %TlsCert{}}

      iex> delete_tls_cert(tls_cert)
      {:error, %Ecto.Changeset{}}

  """
  def delete_tls_cert(%TlsCert{} = tls_cert) do
    # TODO: delete related refs in caddy's service `.spec`
    raise "DELETE NOT YET SUPPORTED"

    Repo.delete(tls_cert)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking tls_cert changes.

  ## Examples

      iex> change_tls_cert(tls_cert)
      %Ecto.Changeset{data: %TlsCert{}}

  """
  def change_tls_cert(%TlsCert{} = tls_cert, attrs \\ %{}) do
    TlsCert.changeset(tls_cert, attrs)
  end
end
