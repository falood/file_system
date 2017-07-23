defmodule FileSystem.ModuleApiTest do
  use ExUnit.Case

  test "module api" do
    tmp_dir = System.cmd("mktemp", ["-d"]) |> elem(0) |> String.trim
    Process.register(self(), :module_api_test)
    ref = System.unique_integer

    defmodule MyMonitor do
      use FileSystem, dirs: [tmp_dir]
      @ref ref

      def callback(:stop), do: :stop
      def callback(path, events), do: send(:module_api_test, {@ref, path, events})
    end

    MyMonitor.start
    File.touch("#{tmp_dir}/a")
    assert_receive {^ref, _path, _events}, 5000
    File.rm_rf!(tmp_dir)
  end
end
