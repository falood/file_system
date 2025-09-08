defmodule FileSystem.Backends.FSMacTest do
  use ExUnit.Case, async: true
  import FileSystem.Backends.FSMac

  @moduletag os_macos: true

  describe "options parse test" do
    @tag capture_log: true
    test "without :dirs" do
      assert {:error, _} = parse_options([])
      assert {:error, _} = parse_options(latency: 1)
    end

    test "supported options" do
      assert {:ok, [~c"--watch-root", ~c"--no-defer", ~c"--latency=0.0", ~c"-F", ~c"/tmp"]} ==
               parse_options(dirs: ["/tmp"], latency: 0, no_defer: true, watch_root: true)

      assert {:ok, [~c"--no-defer", ~c"--latency=1.1", ~c"-F", ~c"/tmp1", ~c"/tmp2"]} ==
               parse_options(dirs: ["/tmp1", "/tmp2"], latency: 1.1, no_defer: true)
    end

    test "ignore unsupported options" do
      assert {:ok, [~c"--latency=0.0", ~c"-F", ~c"/tmp"]} ==
               parse_options(dirs: ["/tmp"], latency: 0, unsuppported: :options)
    end
  end

  describe "port line parse test" do
    test "file modified" do
      assert {"/one/two/file", [:inodemetamod, :modified]} ==
               parse_line(~c"37425557\t0x00011400=[inodemetamod,modified]\t/one/two/file")
    end

    test "whitespace in path" do
      assert {"/one two/file", [:inodemetamod, :modified]} ==
               parse_line(~c"37425557\t0x00011400=[inodemetamod,modified]\t/one two/file")
    end

    test "equal character in file" do
      assert {"/one two/file=2", [:inodemetamod, :modified]} ==
               parse_line(~c"37425557\t0x00011400=[inodemetamod,modified]\t/one two/file=2")
    end
  end
end
