defmodule FileSystemTest do
  use ExUnit.Case, async: true

  # TODO: windows-latest runtime by github action won't pass the test below
  # will do a manual debug on a physical machine once have a chance
  # add @moduletag os_windows: true to make suer the test be run on windows after fix this
  @moduletag os_linux: true, os_macos: true

  test "file event api" do
    tmp_dir = System.cmd("mktemp", ["-d"]) |> elem(0) |> String.trim()
    {:ok, pid} = FileSystem.start_link(dirs: [tmp_dir])
    FileSystem.subscribe(pid)

    :timer.sleep(200)
    File.touch("#{tmp_dir}/a")
    assert_receive {:file_event, ^pid, {_path, _events}}, 5000

    new_subscriber =
      spawn(fn ->
        FileSystem.subscribe(pid)
        :timer.sleep(10000)
      end)

    assert Process.alive?(new_subscriber)
    Process.exit(new_subscriber, :kill)
    refute Process.alive?(new_subscriber)

    :timer.sleep(200)
    File.touch("#{tmp_dir}/b")
    assert_receive {:file_event, ^pid, {_path, _events}}, 5000

    Port.list()
    |> Enum.reject(fn port ->
      :undefined == port |> Port.info() |> Access.get(:os_pid)
    end)
    |> Enum.each(&Port.close/1)

    assert_receive {:file_event, ^pid, :stop}, 5000

    File.rm_rf!(tmp_dir)
  end
end
