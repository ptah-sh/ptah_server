defmodule PtahServerWeb.TlsCertLiveTest do
  use PtahServerWeb.ConnCase

  import Phoenix.LiveViewTest
  import PtahServer.TlsCertsFixtures

  @create_attrs %{name: "some name", cert: "some cert"}
  @update_attrs %{name: "some updated name", cert: "some updated cert"}
  @invalid_attrs %{name: nil, cert: nil}

  defp create_tls_cert(_) do
    tls_cert = tls_cert_fixture()
    %{tls_cert: tls_cert}
  end

  describe "Index" do
    setup [:create_tls_cert]

    test "lists all tls_certs", %{conn: conn, tls_cert: tls_cert} do
      {:ok, _index_live, html} = live(conn, ~p"/tls_certs")

      assert html =~ "Listing Tls certs"
      assert html =~ tls_cert.name
    end

    test "saves new tls_cert", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/tls_certs")

      assert index_live |> element("a", "New Tls cert") |> render_click() =~
               "New Tls cert"

      assert_patch(index_live, ~p"/tls_certs/new")

      assert index_live
             |> form("#tls_cert-form", tls_cert: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#tls_cert-form", tls_cert: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/tls_certs")

      html = render(index_live)
      assert html =~ "Tls cert created successfully"
      assert html =~ "some name"
    end

    test "updates tls_cert in listing", %{conn: conn, tls_cert: tls_cert} do
      {:ok, index_live, _html} = live(conn, ~p"/tls_certs")

      assert index_live |> element("#tls_certs-#{tls_cert.id} a", "Edit") |> render_click() =~
               "Edit Tls cert"

      assert_patch(index_live, ~p"/tls_certs/#{tls_cert}/edit")

      assert index_live
             |> form("#tls_cert-form", tls_cert: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#tls_cert-form", tls_cert: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/tls_certs")

      html = render(index_live)
      assert html =~ "Tls cert updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes tls_cert in listing", %{conn: conn, tls_cert: tls_cert} do
      {:ok, index_live, _html} = live(conn, ~p"/tls_certs")

      assert index_live |> element("#tls_certs-#{tls_cert.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#tls_certs-#{tls_cert.id}")
    end
  end

  describe "Show" do
    setup [:create_tls_cert]

    test "displays tls_cert", %{conn: conn, tls_cert: tls_cert} do
      {:ok, _show_live, html} = live(conn, ~p"/tls_certs/#{tls_cert}")

      assert html =~ "Show Tls cert"
      assert html =~ tls_cert.name
    end

    test "updates tls_cert within modal", %{conn: conn, tls_cert: tls_cert} do
      {:ok, show_live, _html} = live(conn, ~p"/tls_certs/#{tls_cert}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Tls cert"

      assert_patch(show_live, ~p"/tls_certs/#{tls_cert}/show/edit")

      assert show_live
             |> form("#tls_cert-form", tls_cert: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#tls_cert-form", tls_cert: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/tls_certs/#{tls_cert}")

      html = render(show_live)
      assert html =~ "Tls cert updated successfully"
      assert html =~ "some updated name"
    end
  end
end
