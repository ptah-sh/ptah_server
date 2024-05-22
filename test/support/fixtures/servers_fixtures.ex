defmodule PtahSh.ServersFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `PtahSh.Servers` context.
  """

  @doc """
  Generate a server.
  """
  def server_fixture(attrs \\ %{}) do
    {:ok, server} =
      attrs
      |> Enum.into(%{
        agent_token: "some agent_token",
        name: "some name"
      })
      |> PtahSh.Servers.create_server()

    server
  end
end
