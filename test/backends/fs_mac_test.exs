defmodule FileSystem.Backends.FSMacTest do
  use ExUnit.Case
  import FileSystem.Backends.FSMac

  test "file modified" do
    assert parse_line('37425557\t0x00011400=[inodemetamod,modified]\t/one/two/file') ==
      {"/one/two/file", [:inodemetamod, :modified]}
  end
end
