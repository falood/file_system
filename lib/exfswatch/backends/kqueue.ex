alias ExFSWatch.Utils

defmodule ExFSWatch.Backends.Kqueue do

  def known_events do
    [:created, :deleted, :renamed, :closed, :modified, :isdir, :undefined]
  end

  def find_executable do
    :code.priv_dir(:exfswatch) ++ '/kqueue'
  end

  def start_port(path, listener_extra_args) do
    path = path |> Utils.format_path()
    args = listener_extra_args ++ [path]
    Port.open(
      {:spawn_executable, find_executable()},
      [:stream, :exit_status, {:line, 16384}, {:args, args}, {:cd, System.tmp_dir!()}]
    )
  end

  def line_to_event(line) do
    {'.', line}
  end

end
