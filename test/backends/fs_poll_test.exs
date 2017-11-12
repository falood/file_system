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
      {created, _, _} = diff(@stale, @fresh)
      created = ["created"]
    end

    test "detect modified file" do
      {_, modified, _} = diff(@stale, @fresh)
      modified = ["modified"]
    end

    test "detect deleted file" do
      {_, _, deleted} = diff(@stale, @fresh)
      deleted = ["deleted"]
    end
  end
end
