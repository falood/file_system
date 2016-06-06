defmodule ExFSWatch.Sys.InotifyWait do

  def line_to_event(line) do
    line
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

  def convert_flag("CLOSE_WRITE"), do: :modified
  def convert_flag("CLOSE"), do: :closed
  def convert_flag("CREATE"), do: :create
  def convert_flag("MOVED_TO"), do: :renamed
  def convert_flag("ISDIR"), do: :isdir
  def convert_flag("DELETE_SELF"), do: :delete_self
  def convert_flag("DELETE"), do: :deleted

  def convert_flag(_), do: :unknown
end
