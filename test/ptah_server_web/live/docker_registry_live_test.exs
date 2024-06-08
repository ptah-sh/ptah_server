defmodule PtahServerWeb.DockerRegistryLiveTest do
  use PtahServerWeb.ConnCase

  import Phoenix.LiveViewTest
  import PtahServer.DockerRegistriesFixtures

  @create_attrs %{name: "some name"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}

  defp create_docker_registry(_) do
    docker_registry = docker_registry_fixture()
    %{docker_registry: docker_registry}
  end

  describe "Index" do
    setup [:create_docker_registry]

    test "lists all docker_registries", %{conn: conn, docker_registry: docker_registry} do
      {:ok, _index_live, html} = live(conn, ~p"/docker_registries")

      assert html =~ "Listing Docker registries"
      assert html =~ docker_registry.name
    end

    test "saves new docker_registry", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/docker_registries")

      assert index_live |> element("a", "New Docker registry") |> render_click() =~
               "New Docker registry"

      assert_patch(index_live, ~p"/docker_registries/new")

      assert index_live
             |> form("#docker_registry-form", docker_registry: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#docker_registry-form", docker_registry: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/docker_registries")

      html = render(index_live)
      assert html =~ "Docker registry created successfully"
      assert html =~ "some name"
    end

    test "updates docker_registry in listing", %{conn: conn, docker_registry: docker_registry} do
      {:ok, index_live, _html} = live(conn, ~p"/docker_registries")

      assert index_live |> element("#docker_registries-#{docker_registry.id} a", "Edit") |> render_click() =~
               "Edit Docker registry"

      assert_patch(index_live, ~p"/docker_registries/#{docker_registry}/edit")

      assert index_live
             |> form("#docker_registry-form", docker_registry: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#docker_registry-form", docker_registry: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/docker_registries")

      html = render(index_live)
      assert html =~ "Docker registry updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes docker_registry in listing", %{conn: conn, docker_registry: docker_registry} do
      {:ok, index_live, _html} = live(conn, ~p"/docker_registries")

      assert index_live |> element("#docker_registries-#{docker_registry.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#docker_registries-#{docker_registry.id}")
    end
  end

  describe "Show" do
    setup [:create_docker_registry]

    test "displays docker_registry", %{conn: conn, docker_registry: docker_registry} do
      {:ok, _show_live, html} = live(conn, ~p"/docker_registries/#{docker_registry}")

      assert html =~ "Show Docker registry"
      assert html =~ docker_registry.name
    end

    test "updates docker_registry within modal", %{conn: conn, docker_registry: docker_registry} do
      {:ok, show_live, _html} = live(conn, ~p"/docker_registries/#{docker_registry}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Docker registry"

      assert_patch(show_live, ~p"/docker_registries/#{docker_registry}/show/edit")

      assert show_live
             |> form("#docker_registry-form", docker_registry: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#docker_registry-form", docker_registry: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/docker_registries/#{docker_registry}")

      html = render(show_live)
      assert html =~ "Docker registry updated successfully"
      assert html =~ "some updated name"
    end
  end
end
