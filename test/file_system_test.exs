defmodule FileSystemTest do
  use ExUnit.Case, async: true

  test "subscribe api" do
    tmp_dir = System.cmd("mktemp", ["-d"]) |> elem(0) |> String.trim
    {:ok, pid} = FileSystem.start_link(dirs: [tmp_dir])
    FileSystem.subscribe(pid)
    :timer.sleep(200)
    File.touch("#{tmp_dir}/a")
    assert_receive {:file_event, ^pid, {_path, _events}}, 5000
    File.rm_rf!(tmp_dir)
  end
end
