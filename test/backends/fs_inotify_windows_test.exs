defmodule FileSystem.Backends.FSInotifyWindowsTest do
  use ExUnit.Case, async: true
  import FileSystem.Backends.FSInotify

  @moduletag os_windows: true

  describe "options parse test" do
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
                tmp_dir
              ]} = parse_options(dirs: ["/tmp"], recursive: true)

      assert tmp_dir |> to_string() |> String.ends_with?("/tmp")

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
                tmp_dir
              ]} = parse_options(dirs: ["/tmp"], recursive: false)

      assert tmp_dir |> to_string() |> String.ends_with?("/tmp")
    end

    @tag capture_log: true
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
                tmp_dir
              ]} = parse_options(dirs: ["/tmp"], recursive: false, unsupported: :options)

      assert tmp_dir |> to_string() |> String.ends_with?("/tmp")

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
                tmp_dir
              ]} = parse_options(dirs: ["/tmp"], recursive: :unknown_value)

      assert tmp_dir |> to_string() |> String.ends_with?("/tmp")
    end
  end
end
