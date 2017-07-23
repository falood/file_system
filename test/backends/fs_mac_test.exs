defmodule FileSystem.Backends.FSMacTest do
  use ExUnit.Case, async: true
  import FileSystem.Backends.FSMac

  test "file modified" do
    assert {"/one/two/file", [:inodemetamod, :modified]} ==
      parse_line('37425557\t0x00011400=[inodemetamod,modified]\t/one/two/file')
  end

  test "whitespace in path" do
    assert {"/one two/file", [:inodemetamod, :modified]} ==
      parse_line('37425557\t0x00011400=[inodemetamod,modified]\t/one two/file')
  end
end
