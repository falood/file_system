defmodule FileSystem.Utils do
  def format_path(path) when is_list(path) do
    for i <- path do
      i |> Path.absname |> to_charlist
    end
  end

  def format_path(path) do
    [path] |> format_path
  end

  def format_args(nil), do: []
  def format_args(str) when is_binary(str) do
    str |> String.split |> format_args
  end
  def format_args(list) when is_list(list) do
    list |> Enum.map(&to_charlist/1)
  end

end
