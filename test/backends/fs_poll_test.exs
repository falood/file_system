defmodule FileSystem.Backends.FSPollTest do
  use ExUnit.Case, async: true
  import FileSystem.Backends.FSPoll

  @mtime1 {{2017, 11, 13}, {10, 14, 00}}
  @mtime2 {{2017, 11, 13}, {10, 15, 00}}

  @stale %{
    "modified" => @mtime1,
    "deleted" => @mtime1,
  }

  @fresh %{
    "created" => @mtime2,
    "modified" => @mtime2
  }

  describe "diff" do
    test "detect created file" do
      assert {["created"], _, _} = diff(@stale, @fresh)
    end

    test "detect deleted file" do
      assert {_, ["deleted"], _} = diff(@stale, @fresh)
    end

    test "detect modified file" do
      assert {_, _, ["modified"]} = diff(@stale, @fresh)
    end
  end
end
