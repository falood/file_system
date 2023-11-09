defmodule FileSystem.Backends.FSInotifyLinuxTest do
  use ExUnit.Case, async: true
  import FileSystem.Backends.FSInotify

  @moduletag os_inux: true

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
end
