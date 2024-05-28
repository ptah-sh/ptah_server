defmodule PtahServerWeb.StackLiveTest do
  use PtahServerWeb.ConnCase

  import Phoenix.LiveViewTest
  import PtahServer.StacksFixtures

  @create_attrs %{name: "some name", team_id: 42, stack_name: "some stack_name", stack_version: "some stack_version"}
  @update_attrs %{name: "some updated name", team_id: 43, stack_name: "some updated stack_name", stack_version: "some updated stack_version"}
  @invalid_attrs %{name: nil, team_id: nil, stack_name: nil, stack_version: nil}

  defp create_stack(_) do
    stack = stack_fixture()
    %{stack: stack}
  end

  describe "Index" do
    setup [:create_stack]

    test "lists all stacks", %{conn: conn, stack: stack} do
      {:ok, _index_live, html} = live(conn, ~p"/stacks")

      assert html =~ "Listing Stacks"
      assert html =~ stack.name
    end

    test "saves new stack", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/stacks")

      assert index_live |> element("a", "New Stack") |> render_click() =~
               "New Stack"

      assert_patch(index_live, ~p"/stacks/new")

      assert index_live
             |> form("#stack-form", stack: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#stack-form", stack: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/stacks")

      html = render(index_live)
      assert html =~ "Stack created successfully"
      assert html =~ "some name"
    end

    test "updates stack in listing", %{conn: conn, stack: stack} do
      {:ok, index_live, _html} = live(conn, ~p"/stacks")

      assert index_live |> element("#stacks-#{stack.id} a", "Edit") |> render_click() =~
               "Edit Stack"

      assert_patch(index_live, ~p"/stacks/#{stack}/edit")

      assert index_live
             |> form("#stack-form", stack: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#stack-form", stack: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/stacks")

      html = render(index_live)
      assert html =~ "Stack updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes stack in listing", %{conn: conn, stack: stack} do
      {:ok, index_live, _html} = live(conn, ~p"/stacks")

      assert index_live |> element("#stacks-#{stack.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#stacks-#{stack.id}")
    end
  end

  describe "Show" do
    setup [:create_stack]

    test "displays stack", %{conn: conn, stack: stack} do
      {:ok, _show_live, html} = live(conn, ~p"/stacks/#{stack}")

      assert html =~ "Show Stack"
      assert html =~ stack.name
    end

    test "updates stack within modal", %{conn: conn, stack: stack} do
      {:ok, show_live, _html} = live(conn, ~p"/stacks/#{stack}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Stack"

      assert_patch(show_live, ~p"/stacks/#{stack}/show/edit")

      assert show_live
             |> form("#stack-form", stack: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#stack-form", stack: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/stacks/#{stack}")

      html = render(show_live)
      assert html =~ "Stack updated successfully"
      assert html =~ "some updated name"
    end
  end
end
