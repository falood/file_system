alias ExFSWatch.Utils

defmodule ExFSWatch.Backends.Fsevents do

  def find_executable do
    :code.priv_dir(:exfswatch) ++ '/mac_listener'
  end

  def start_port(path, listener_extra_args) do
    path = path |> Utils.format_path()
    args = listener_extra_args ++ ['-F' | path]
    Port.open(
      {:spawn_executable, find_executable()},
      [:stream, :exit_status, {:line, 16384}, {:args, args}, {:cd, System.tmp_dir!()}]
    )
  end

  def known_events do
    [ :mustscansubdirs, :userdropped, :kerneldropped, :eventidswrapped, :historydone,
      :rootchanged, :mount, :unmount, :created, :removed, :inodemetamod, :renamed, :modified,
      :finderinfomod, :changeowner, :xattrmod, :isfile, :isdir, :issymlink, :ownevent,
    ]
  end

  def line_to_event(line) do
    [_event_id, flags, path] = :string.tokens(line, [?\t])
    [_, flags] = :string.tokens(flags, [?=])
    {:ok, t, _} = :erl_scan.string(flags ++ '.')
    {:ok, flags} = :erl_parse.parse_term(t)
    {path, flags}
  end

end
