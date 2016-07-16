defmodule ExfswatchTest do
  use ExUnit.Case
  import :fsevents

  test "file modified" do
    assert line_to_event('37425557\t0x00011400=[inodemetamod,modified]\t/one/two/file') ==
      {'/one/two/file', [:inodemetamod, :modified]}
  end
end
