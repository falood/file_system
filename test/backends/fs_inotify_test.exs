defmodule FileSystem.Backends.FSInotifyTest do
  use ExUnit.Case, async: true
  import FileSystem.Backends.FSInotify

  describe "options parse test" do
    test "without :dirs" do
      assert {:error, _} = parse_options([])
      assert {:error, _} = parse_options(recursive: 1)
    end

    test "supported options" do
      assert {:ok,
              [
                ~c"-e",
                ~c"modify",
                ~c"-e",
                ~c"close_write",
                ~c"-e",
                ~c"moved_to",
                ~c"-e",
                ~c"moved_from",
                ~c"-e",
                ~c"create",
                ~c"-e",
                ~c"delete",
                ~c"-e",
                ~c"attrib",
                ~c"--format",
                [37, 119, 1, 37, 101, 1, 37, 102],
                ~c"--quiet",
                ~c"-m",
                ~c"-r",
                ~c"/tmp"
              ]} ==
               parse_options(dirs: ["/tmp"], recursive: true)

      assert {:ok,
              [
                ~c"-e",
                ~c"modify",
                ~c"-e",
                ~c"close_write",
                ~c"-e",
                ~c"moved_to",
                ~c"-e",
                ~c"moved_from",
                ~c"-e",
                ~c"create",
                ~c"-e",
                ~c"delete",
                ~c"-e",
                ~c"attrib",
                ~c"--format",
                [37, 119, 1, 37, 101, 1, 37, 102],
                ~c"--quiet",
                ~c"-m",
                ~c"/tmp"
              ]} ==
               parse_options(dirs: ["/tmp"], recursive: false)
    end

    test "ignore unsupported options" do
      assert {:ok,
              [
                ~c"-e",
                ~c"modify",
                ~c"-e",
                ~c"close_write",
                ~c"-e",
                ~c"moved_to",
                ~c"-e",
                ~c"moved_from",
                ~c"-e",
                ~c"create",
                ~c"-e",
                ~c"delete",
                ~c"-e",
                ~c"attrib",
                ~c"--format",
                [37, 119, 1, 37, 101, 1, 37, 102],
                ~c"--quiet",
                ~c"-m",
                ~c"/tmp"
              ]} ==
               parse_options(dirs: ["/tmp"], recursive: false, unsupported: :options)

      assert {:ok,
              [
                ~c"-e",
                ~c"modify",
                ~c"-e",
                ~c"close_write",
                ~c"-e",
                ~c"moved_to",
                ~c"-e",
                ~c"moved_from",
                ~c"-e",
                ~c"create",
                ~c"-e",
                ~c"delete",
                ~c"-e",
                ~c"attrib",
                ~c"--format",
                [37, 119, 1, 37, 101, 1, 37, 102],
                ~c"--quiet",
                ~c"-m",
                ~c"-r",
                ~c"/tmp"
              ]} ==
               parse_options(dirs: ["/tmp"], recursive: :unknown_value)
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
