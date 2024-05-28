defmodule PtahServer.ServicesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `PtahServer.Services` context.
  """

  @doc """
  Generate a service.
  """
  def service_fixture(attrs \\ %{}) do
    {:ok, service} =
      attrs
      |> Enum.into(%{
        ext_id: "some ext_id",
        name: "some name",
        team_id: 42
      })
      |> PtahServer.Services.create_service()

    service
  end
end
