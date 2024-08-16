defmodule FileSystem.Backends.FSInotifyTest do
  use ExUnit.Case, async: true
  import FileSystem.Backends.FSInotify

  @moduletag os_linux: true, os_windows: true

  describe "options parse test" do
    @tag capture_log: true
    test "without :dirs" do
      assert {:error, _} = parse_options([])
      assert {:error, _} = parse_options(recursive: 1)
    end
  end

  describe "port line parse test" do
    defp to_port_line(list), do: list |> Enum.join(<<1>>)

    test "dir write close" do
      assert {"/one/two/file", [:modified, :closed]} ==
               ~w|/one/two/ CLOSE_WRITE,CLOSE file| |> to_port_line |> parse_line
    end

    test "dir create" do
      assert {"/one/two/file", [:created]} ==
               ~w|/one/two/ CREATE file| |> to_port_line |> parse_line
    end

    test "dir moved to" do
      assert {"/one/two/file", [:moved_to]} ==
               ~w|/one/two/ MOVED_TO file| |> to_port_line |> parse_line
    end

    test "dir moved from" do
      assert {"/one/two/file", [:moved_from]} ==
               ~w|/one/two/ MOVED_FROM file| |> to_port_line |> parse_line
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
  end
end
