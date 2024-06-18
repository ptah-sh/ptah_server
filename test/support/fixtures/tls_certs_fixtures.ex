defmodule PtahServer.TlsCertsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `PtahServer.TlsCerts` context.
  """

  @doc """
  Generate a tls_cert.
  """
  def tls_cert_fixture(attrs \\ %{}) do
    {:ok, tls_cert} =
      attrs
      |> Enum.into(%{
        cert: "some cert",
        name: "some name"
      })
      |> PtahServer.TlsCerts.create_tls_cert()

    tls_cert
  end
end
