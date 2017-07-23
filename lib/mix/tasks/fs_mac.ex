defmodule Mix.Tasks.FileSystem.FsMac do
  use Mix.Task

  @doc false
  def run(["init"]) do
    case FileSystem.Backends.FSMac.bootstrap do
      :ok ->
        IO.puts "Initialize fs_mac backend successfully."
      {:error, reason} ->
        IO.puts :stderr, "Initialize fs_mac backend error, reason: #{reason}."
    end
  end

  def run(args) do
    IO.puts :stderr, "unknown command `#{args}`"
  end
end
