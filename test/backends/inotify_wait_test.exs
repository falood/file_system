defmodule ExFSWatch.Backends.InotifyWaitTest do
  use ExUnit.Case
  import ExFSWatch.Backends.InotifyWait

  test "dir write close" do
    assert line_to_event("/one/two/ CLOSE_WRITE,CLOSE file") ==
      {"/one/two/file", [:modified, :closed]}
  end

  test "dir create" do
    assert line_to_event("/one/two/ CREATE file") ==
      {"/one/two/file", [:created]}
  end

  test "dir moved to" do
    assert line_to_event("/one/two/ MOVED_TO file") ==
      {"/one/two/file", [:renamed]}
  end

  test "dir is_dir create" do
    assert line_to_event("/one/two/ CREATE,ISDIR dir") ==
      {"/one/two/dir", [:created, :isdir]}
  end

  test "file write close" do
    assert line_to_event("/one/two/file CLOSE_WRITE,CLOSE") ==
      {"/one/two/file", [:modified, :closed]}
  end

  test "file delete_self" do
    assert line_to_event("/one/two/file DELETE_SELF") ==
      {"/one/two/file", [:undefined]}
  end
end
