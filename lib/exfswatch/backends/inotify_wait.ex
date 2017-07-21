alias ExFSWatch.Utils

defmodule ExFSWatch.Backends.InotifyWait do
  @behaviour ExFSWatch.Backend
  def find_executable do
    System.find_executable("sh") |> to_charlist
  end

  def start_port(path, listener_extra_args) do
    path = path |> Utils.format_path()
    args = [
      '-c', 'inotifywait $0 $@ & PID=$!; read a; kill $PID',
      '-m', '-e', 'modify', '-e', 'close_write', '-e', 'moved_to', '-e', 'create',
      '-r'] ++ listener_extra_args ++ path
    Port.open(
      {:spawn_executable, find_executable()},
      [:stream, :exit_status, {:line, 16384}, {:args, args}, {:cd, System.tmp_dir!()}]
    )
  end

  def known_events do
    [:created, :deleted, :renamed, :closed, :modified, :isdir, :attribute, :undefined]
  end

  def line_to_event(line) do
    line
    |> to_string
    |> scan1
    |> scan2(line)
  end

  defp scan1(line) do
    re = ~r/^(.*) ([A-Z_,]+) (.*)$/
    case Regex.scan re, line do
      [] -> {:error, :unknown}
      [[_, path, events, file]] ->
        {Path.join(path, file), parse_events(events)}
    end

  end

  defp scan2({:error, :unknown}, line) do
    re = ~r/^(.*) ([A-Z_,]+)$/
    case Regex.scan re, line do
      [] -> {:error, :unknown}
      [[_, path, events]] ->
        {path, parse_events(events)}
    end
  end

  defp scan2(res, _), do: res

  defp parse_events(events) do
    String.split(events, ",")
    |> Enum.map(&(convert_flag &1))
  end

  defp convert_flag("CREATE"),      do: :created
  defp convert_flag("DELETE"),      do: :deleted
  defp convert_flag("ISDIR"),       do: :isdir
  defp convert_flag("MODIFY"),      do: :modified
  defp convert_flag("CLOSE_WRITE"), do: :modified
  defp convert_flag("CLOSE"),       do: :closed
  defp convert_flag("MOVED_TO"),    do: :renamed
  defp convert_flag("ATTRIB"),      do: :attribute
  defp convert_flag(_),             do: :undefined
end
