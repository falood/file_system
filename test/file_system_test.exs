defmodule FileSystemTest do
  use ExUnit.Case, async: true

  @moduletag os_linux: true, os_macos: true, os_windows: true

  test "file event api" do
    tmp_dir = mktemp_d!()
    on_exit(fn -> File.rm_rf!(tmp_dir) end)

    {:ok, pid} = FileSystem.start_link(dirs: [tmp_dir], watch_root: true)
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
  end

  defp mktemp_d!() do
    name = for _ <- 1..10, into: "", do: <<Enum.random(~c'0123456789abcdef')>>
    path = Path.join([System.tmp_dir!(), name])
    File.mkdir_p!(path)
    path
  end
end
