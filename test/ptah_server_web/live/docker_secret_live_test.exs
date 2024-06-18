defmodule PtahServerWeb.DockerSecretLiveTest do
  use PtahServerWeb.ConnCase

  import Phoenix.LiveViewTest
  import PtahServer.DockerSecretsFixtures

  @create_attrs %{name: "some name", ext_id: "some ext_id"}
  @update_attrs %{name: "some updated name", ext_id: "some updated ext_id"}
  @invalid_attrs %{name: nil, ext_id: nil}

  defp create_docker_secret(_) do
    docker_secret = docker_secret_fixture()
    %{docker_secret: docker_secret}
  end

  describe "Index" do
    setup [:create_docker_secret]

    test "lists all docker_secrets", %{conn: conn, docker_secret: docker_secret} do
      {:ok, _index_live, html} = live(conn, ~p"/docker_secrets")

      assert html =~ "Listing Docker secrets"
      assert html =~ docker_secret.name
    end

    test "saves new docker_secret", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/docker_secrets")

      assert index_live |> element("a", "New Docker secret") |> render_click() =~
               "New Docker secret"

      assert_patch(index_live, ~p"/docker_secrets/new")

      assert index_live
             |> form("#docker_secret-form", docker_secret: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#docker_secret-form", docker_secret: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/docker_secrets")

      html = render(index_live)
      assert html =~ "Docker secret created successfully"
      assert html =~ "some name"
    end

    test "updates docker_secret in listing", %{conn: conn, docker_secret: docker_secret} do
      {:ok, index_live, _html} = live(conn, ~p"/docker_secrets")

      assert index_live |> element("#docker_secrets-#{docker_secret.id} a", "Edit") |> render_click() =~
               "Edit Docker secret"

      assert_patch(index_live, ~p"/docker_secrets/#{docker_secret}/edit")

      assert index_live
             |> form("#docker_secret-form", docker_secret: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#docker_secret-form", docker_secret: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/docker_secrets")

      html = render(index_live)
      assert html =~ "Docker secret updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes docker_secret in listing", %{conn: conn, docker_secret: docker_secret} do
      {:ok, index_live, _html} = live(conn, ~p"/docker_secrets")

      assert index_live |> element("#docker_secrets-#{docker_secret.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#docker_secrets-#{docker_secret.id}")
    end
  end

  describe "Show" do
    setup [:create_docker_secret]

    test "displays docker_secret", %{conn: conn, docker_secret: docker_secret} do
      {:ok, _show_live, html} = live(conn, ~p"/docker_secrets/#{docker_secret}")

      assert html =~ "Show Docker secret"
      assert html =~ docker_secret.name
    end

    test "updates docker_secret within modal", %{conn: conn, docker_secret: docker_secret} do
      {:ok, show_live, _html} = live(conn, ~p"/docker_secrets/#{docker_secret}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Docker secret"

      assert_patch(show_live, ~p"/docker_secrets/#{docker_secret}/show/edit")

      assert show_live
             |> form("#docker_secret-form", docker_secret: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#docker_secret-form", docker_secret: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/docker_secrets/#{docker_secret}")

      html = render(show_live)
      assert html =~ "Docker secret updated successfully"
      assert html =~ "some updated name"
    end
  end
end
