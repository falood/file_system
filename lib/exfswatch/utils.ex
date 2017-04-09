defmodule ExFSWatch.Utils do

  def format_path(path) when is_list(path) do
    for i <- path do
      i |> Path.absname |> to_char_list
    end
  end

  def format_path(path) do
    [path] |> format_path
  end

end
