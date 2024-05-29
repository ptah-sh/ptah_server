defmodule PtahServer.Marketplace do
  def list_stacks() do
    stacks_dir = Application.app_dir(:ptah_server, "priv/stacks/**.stack.json")

    Path.wildcard(stacks_dir) |> Enum.map(&File.read!/1) |> Enum.map(&Jason.decode!/1)
  end

  def get_stack(stack_name) do
    list_stacks()
    |> Enum.find(&(&1["name"] == stack_name))
  end
end
