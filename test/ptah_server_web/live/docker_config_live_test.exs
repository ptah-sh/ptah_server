defmodule PtahServerWeb.DockerConfigLiveTest do
  use PtahServerWeb.ConnCase

  import Phoenix.LiveViewTest
  import PtahServer.DockerConfigsFixtures

  @create_attrs %{name: "some name", ext_id: "some ext_id"}
  @update_attrs %{name: "some updated name", ext_id: "some updated ext_id"}
  @invalid_attrs %{name: nil, ext_id: nil}

  defp create_docker_config(_) do
    docker_config = docker_config_fixture()
    %{docker_config: docker_config}
  end

  describe "Index" do
    setup [:create_docker_config]

    test "lists all docker_configs", %{conn: conn, docker_config: docker_config} do
      {:ok, _index_live, html} = live(conn, ~p"/docker_configs")

      assert html =~ "Listing Docker configs"
      assert html =~ docker_config.name
    end

    test "saves new docker_config", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/docker_configs")

      assert index_live |> element("a", "New Docker config") |> render_click() =~
               "New Docker config"

      assert_patch(index_live, ~p"/docker_configs/new")

      assert index_live
             |> form("#docker_config-form", docker_config: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#docker_config-form", docker_config: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/docker_configs")

      html = render(index_live)
      assert html =~ "Docker config created successfully"
      assert html =~ "some name"
    end

    test "updates docker_config in listing", %{conn: conn, docker_config: docker_config} do
      {:ok, index_live, _html} = live(conn, ~p"/docker_configs")

      assert index_live |> element("#docker_configs-#{docker_config.id} a", "Edit") |> render_click() =~
               "Edit Docker config"

      assert_patch(index_live, ~p"/docker_configs/#{docker_config}/edit")

      assert index_live
             |> form("#docker_config-form", docker_config: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#docker_config-form", docker_config: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/docker_configs")

      html = render(index_live)
      assert html =~ "Docker config updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes docker_config in listing", %{conn: conn, docker_config: docker_config} do
      {:ok, index_live, _html} = live(conn, ~p"/docker_configs")

      assert index_live |> element("#docker_configs-#{docker_config.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#docker_configs-#{docker_config.id}")
    end
  end

  describe "Show" do
    setup [:create_docker_config]

    test "displays docker_config", %{conn: conn, docker_config: docker_config} do
      {:ok, _show_live, html} = live(conn, ~p"/docker_configs/#{docker_config}")

      assert html =~ "Show Docker config"
      assert html =~ docker_config.name
    end

    test "updates docker_config within modal", %{conn: conn, docker_config: docker_config} do
      {:ok, show_live, _html} = live(conn, ~p"/docker_configs/#{docker_config}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Docker config"

      assert_patch(show_live, ~p"/docker_configs/#{docker_config}/show/edit")

      assert show_live
             |> form("#docker_config-form", docker_config: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#docker_config-form", docker_config: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/docker_configs/#{docker_config}")

      html = render(show_live)
      assert html =~ "Docker config updated successfully"
      assert html =~ "some updated name"
    end
  end
end
