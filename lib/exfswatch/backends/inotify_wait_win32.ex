alias ExFSWatch.Utils

defmodule ExFSWatch.Backends.InotifyWaitWin32 do

  @re :re.compile('^(.*\\\\.*) ([A-Z_,]+) (.*)$', [:unicode]) |> elem(1)

  def find_executable do
    :code.priv_dir(:exfswatch) ++ '/inotifywait.exe'
  end

  def start_port(path, listener_extra_args) do
    path = path |> Utils.format_path()
    args = listener_extra_args ++ ['-m', '-r' | path]
    Port.open(
      {:spawn_executable, find_executable()},
      [:stream, :exit_status, {:line, 16384}, {:args, args}, {:cd, System.tmp_dir!()}]
    )
  end

  def known_events do
    [:created, :modified, :removed, :renamed, :undefined]
  end

  def line_to_event(line) do
    {:match, [dir, flags, dir_entry]} = :re.run(line, @re, [{:capture, :all_but_first, :list}])
    flags = for f <- :string.tokens(flags, ','), do: convert_flag(f)
    path = :filename.join(dir, dir_entry)
    {path, flags}
  end

  defp convert_flag('CREATE'),   do: :created
  defp convert_flag('MODIFY'),   do: :modified
  defp convert_flag('DELETE'),   do: :removed
  defp convert_flag('MOVED_TO'), do: :renamed
  defp convert_flag(_),          do: :undefined

end
