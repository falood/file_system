defmodule FileSystem.Backends.FSInotifyTest do
  use ExUnit.Case, async: true
  import FileSystem.Backends.FSInotify

  test "dir write close" do
    assert {"/one/two/file", [:modified, :closed]} ==
      ~w|/one/two/ CLOSE_WRITE,CLOSE file| |> to_port_line |> parse_line
  end

  test "dir create" do
    assert {"/one/two/file", [:created]} ==
      ~w|/one/two/ CREATE file| |> to_port_line |> parse_line
  end

  test "dir moved to" do
    assert {"/one/two/file", [:renamed]} ==
      ~w|/one/two/ MOVED_TO file| |> to_port_line |> parse_line
  end

  test "dir is_dir create" do
    assert {"/one/two/dir", [:created, :isdir]} ==
      ~w|/one/two/ CREATE,ISDIR dir| |> to_port_line |> parse_line
  end

  test "file write close" do
    assert {"/one/two/file", [:modified, :closed]} ==
      ~w|/one/two/file CLOSE_WRITE,CLOSE| |> to_port_line |> parse_line
  end

  test "file delete_self" do
    assert {"/one/two/file", [:undefined]} ==
      ~w|/one/two/file DELETE_SELF| |> to_port_line |> parse_line
  end

  test "whitespace in path" do
    assert {"/one two/file", [:modified, :closed]} ==
      ["/one two", "CLOSE_WRITE,CLOSE", "file"] |> to_port_line |> parse_line

    assert {"/one/two/file 1", [:modified, :closed]} ==
      ["/one/two", "CLOSE_WRITE,CLOSE", "file 1"] |> to_port_line |> parse_line

    assert {"/one two/file 1", [:modified, :closed]} ==
      ["/one two", "CLOSE_WRITE,CLOSE", "file 1"] |> to_port_line |> parse_line
  end

  defp to_port_line(list), do: list |> Enum.join(<<1>>) |> to_charlist

end
