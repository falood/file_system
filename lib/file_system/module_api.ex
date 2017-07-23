defmodule FileSystem.ModuleApi do
  defmacro __before_compile__(%Macro.Env{module: module}) do
    options = Module.get_attribute(module, :file_system_module_options)
    quote do
      def start do
        {:ok, worker_pid} = FileSystem.start_link(unquote(options))
        pid = spawn_link(fn ->
          FileSystem.subscribe(worker_pid)
          await_events(worker_pid)
        end)
        {:ok, pid}
      end

      defp await_events(pid) do
        receive do
          {:file_event, ^pid, :stop} ->
            callback(:stop)
          {:file_event, ^pid, {file_path, events}} ->
            callback(file_path, events)
            await_events(pid)
        end
      end
    end
  end
end
