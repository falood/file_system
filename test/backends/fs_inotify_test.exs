defmodule FileSystem.Backends.FSInotifyTest do
  use ExUnit.Case, async: true
  import FileSystem.Backends.FSInotify

  describe "options parse test" do
    test "without :dirs" do
      assert {:error, _} = parse_options([])
      assert {:error, _} = parse_options([recursive: 1])
    end

    test "supported options" do
      assert {:ok, ['-e', 'modify', '-e', 'close_write', '-e', 'moved_to', '-e', 'moved_from', '-e', 'create',
                    '-e', 'delete', '-e', 'attrib', '--format', [37, 119, 1, 37, 101, 1, 37, 102],
                    '--quiet', '-m', '-r', '/tmp']} ==
        parse_options(dirs: ["/tmp"], recursive: true)

      assert {:ok, ['-e', 'modify', '-e', 'close_write', '-e', 'moved_to', '-e', 'moved_from', '-e', 'create',
                    '-e', 'delete', '-e', 'attrib', '--format', [37, 119, 1, 37, 101, 1, 37, 102],
                    '--quiet', '-m', '/tmp']} ==
        parse_options(dirs: ["/tmp"], recursive: false)
    end

    test "ignore unsupported options" do
      assert {:ok, ['-e', 'modify', '-e', 'close_write', '-e', 'moved_to', '-e', 'moved_from', '-e', 'create',
                    '-e', 'delete', '-e', 'attrib', '--format', [37, 119, 1, 37, 101, 1, 37, 102],
                    '--quiet', '-m', '/tmp']} ==
        parse_options(dirs: ["/tmp"], recursive: false, unsupported: :options)
    end
  end

  describe "port line parse test" do
    defp to_port_line(list), do: list |> Enum.join(<<1>>) |> to_charlist

    test "dir write close" do
      assert {"/one/two/file", [:modified, :closed]} ==
        ~w|/one/two/ CLOSE_WRITE,CLOSE file| |> to_port_line |> parse_line
    end

    test "dir create" do
      assert {"/one/two/file", [:created]} ==
        ~w|/one/two/ CREATE file| |> to_port_line |> parse_line
    end

    test "dir moved to" do
      assert {"/one/two/file", [:created]} ==
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
  end

end
