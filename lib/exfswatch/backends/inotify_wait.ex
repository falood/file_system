alias ExFSWatch.Utils

defmodule ExFSWatch.Backends.InotifyWait do

  def find_executable do
    System.find_executable("sh") |> to_charlist
  end

  def start_port(path, listener_extra_args) do
    path = path |> Utils.format_path()
    args = listener_extra_args ++ [
      '-c', 'inotifywait $0 $@ & PID=$!; read a; kill $PID',
      '-m', '-e', 'modify', '-e', 'close_write', '-e', 'moved_to', '-e', 'create',
      '-r' | path]
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

  def scan1(line) do
    re = ~r/^(.*) ([A-Z_,]+) (.*)$/
    case Regex.scan re, line do
      [] -> {:error, :unknown}
      [[_, path, events, file]] ->
        {Path.join(path, file), parse_events(events)}
    end

  end
  def scan2({:error, :unknown}, line) do
    re = ~r/^(.*) ([A-Z_,]+)$/
    case Regex.scan re, line do
      [] -> {:error, :unknown}
      [[_, path, events]] ->
        {path, parse_events(events)}
    end
  end
  def scan2(res, _), do: res

  def parse_events(events) do
    String.split(events, ",")
    |> Enum.map(&(convert_flag &1))
  end

  def convert_flag("CREATE"),      do: :created
  def convert_flag("DELETE"),      do: :deleted
  def convert_flag("ISDIR"),       do: :isdir
  def convert_flag("MODIFY"),      do: :modified
  def convert_flag("CLOSE_WRITE"), do: :modified
  def convert_flag("CLOSE"),       do: :closed
  def convert_flag("MOVED_TO"),    do: :renamed
  def convert_flag("ATTRIB"),      do: :attribute
  def convert_flag(_),             do: :undefined
end
