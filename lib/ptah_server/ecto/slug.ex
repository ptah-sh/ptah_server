defmodule PtahServer.Ecto.Slug do
  @slug_re ~r/\W/
  @start_re ~r/(^[0-9])/

  use Ecto.Type

  def type, do: :string

  def cast(term) when is_binary(term) do
    {:ok,
     term
     |> String.downcase()
     |> String.replace(@slug_re, "_")
     |> String.replace(@start_re, "s_\\1")}
  end

  def cast(_), do: :error

  def load(term), do: {:ok, term}

  # TODO: limit length to 63. Set last 5 characters to a hash
  def dump(term) do
    {:ok, term}
  end
end
