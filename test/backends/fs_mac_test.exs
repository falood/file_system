defmodule FileSystem.Backends.FSMacTest do
  use ExUnit.Case, async: true
  import FileSystem.Backends.FSMac

  describe "options parse test" do
    test "without :dirs" do
      assert {:error, _} = parse_options([])
      assert {:error, _} = parse_options([latency: 1])
    end

    test "supported options" do
      assert {:ok, ['--with-root', '--no-defer', '--latency=0.0', '-F', '/tmp']} ==
        parse_options(dirs: ["/tmp"], latency: 0, no_defer: true, with_root: true)

      assert {:ok, ['--no-defer', '--latency=1.1', '-F', '/tmp1', '/tmp2']} ==
        parse_options(dirs: ["/tmp1", "/tmp2"], latency: 1.1, no_defer: true)
    end

    test "ignore unsupported options" do
      assert {:ok, ['--latency=0.0', '-F', '/tmp']} ==
        parse_options(dirs: ["/tmp"], latency: 0, unsuppported: :options)
    end
  end

  describe "port line parse test" do
    test "file modified" do
      assert {"/one/two/file", [:inodemetamod, :modified]} ==
        parse_line('37425557\t0x00011400=[inodemetamod,modified]\t/one/two/file')
    end

    test "whitespace in path" do
      assert {"/one two/file", [:inodemetamod, :modified]} ==
        parse_line('37425557\t0x00011400=[inodemetamod,modified]\t/one two/file')
    end
  end
end
