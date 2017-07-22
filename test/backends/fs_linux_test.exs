defmodule FileSystem.Backends.FSLinuxTest do
  use ExUnit.Case
  import FileSystem.Backends.FSLinux

  test "dir write close" do
    assert parse_line("/one/two/ CLOSE_WRITE,CLOSE file") ==
      {"/one/two/file", [:modified, :closed]}
  end

  test "dir create" do
    assert parse_line("/one/two/ CREATE file") ==
      {"/one/two/file", [:created]}
  end

  test "dir moved to" do
    assert parse_line("/one/two/ MOVED_TO file") ==
      {"/one/two/file", [:renamed]}
  end

  test "dir is_dir create" do
    assert parse_line("/one/two/ CREATE,ISDIR dir") ==
      {"/one/two/dir", [:created, :isdir]}
  end

  test "file write close" do
    assert parse_line("/one/two/file CLOSE_WRITE,CLOSE") ==
      {"/one/two/file", [:modified, :closed]}
  end

  test "file delete_self" do
    assert parse_line("/one/two/file DELETE_SELF") ==
      {"/one/two/file", [:undefined]}
  end
end
