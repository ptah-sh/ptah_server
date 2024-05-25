defmodule PtahServerWeb.ServerLiveTest do
  use PtahServerWeb.ConnCase

  import Phoenix.LiveViewTest
  import PtahServer.ServersFixtures

  @create_attrs %{name: "some name", agent_token: "some agent_token"}
  @update_attrs %{name: "some updated name", agent_token: "some updated agent_token"}
  @invalid_attrs %{name: nil, agent_token: nil}

  defp create_server(_) do
    server = server_fixture()
    %{server: server}
  end

  describe "Index" do
    setup [:create_server]

    test "lists all servers", %{conn: conn, server: server} do
      {:ok, _index_live, html} = live(conn, ~p"/servers")

      assert html =~ "Listing Servers"
      assert html =~ server.name
    end

    test "saves new server", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/servers")

      assert index_live |> element("a", "New Server") |> render_click() =~
               "New Server"

      assert_patch(index_live, ~p"/servers/new")

      assert index_live
             |> form("#server-form", server: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#server-form", server: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/servers")

      html = render(index_live)
      assert html =~ "Server created successfully"
      assert html =~ "some name"
    end

    test "updates server in listing", %{conn: conn, server: server} do
      {:ok, index_live, _html} = live(conn, ~p"/servers")

      assert index_live |> element("#servers-#{server.id} a", "Edit") |> render_click() =~
               "Edit Server"

      assert_patch(index_live, ~p"/servers/#{server}/edit")

      assert index_live
             |> form("#server-form", server: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#server-form", server: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/servers")

      html = render(index_live)
      assert html =~ "Server updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes server in listing", %{conn: conn, server: server} do
      {:ok, index_live, _html} = live(conn, ~p"/servers")

      assert index_live |> element("#servers-#{server.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#servers-#{server.id}")
    end
  end

  describe "Show" do
    setup [:create_server]

    test "displays server", %{conn: conn, server: server} do
      {:ok, _show_live, html} = live(conn, ~p"/servers/#{server}")

      assert html =~ "Show Server"
      assert html =~ server.name
    end

    test "updates server within modal", %{conn: conn, server: server} do
      {:ok, show_live, _html} = live(conn, ~p"/servers/#{server}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Server"

      assert_patch(show_live, ~p"/servers/#{server}/show/edit")

      assert show_live
             |> form("#server-form", server: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#server-form", server: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/servers/#{server}")

      html = render(show_live)
      assert html =~ "Server updated successfully"
      assert html =~ "some updated name"
    end
  end
end
