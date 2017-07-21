require Logger

defmodule ExFSWatch do
  defmacro __using__(options) do
    extra_args =
      options
      |> Keyword.get(:listener_extra_args, "")
      |> String.split
      |> Enum.map(&to_char_list/1)
    quote do
      def start do
        {:ok, worker_pid} = ExFSWatch.Supervisor.start_child(dirs: unquote(options[:dirs]), listener_extra_args: unquote(extra_args), name: __MODULE__)
        pid = spawn_link(fn ->
          ExFSWatch.Worker.subscribe(worker_pid)
          await_events(worker_pid)
        end)
        {:ok, pid}
      end

      defp await_events(pid) do
        receive do
          {:file_event, ^pid, file_path, events} ->
            callback(file_path, events)
            await_events(pid)
          {:file_event, ^pid, :stop} ->
            callback(:stop)
        end
      end
    end
  end

  @backend (case :os.type() do
    {:unix,  :darwin}  -> ExFSWatch.Backends.Fsevents
    {:unix,  :freebsd} -> ExFSWatch.Backends.Kqueue
    {:unix,  :linux}   -> ExFSWatch.Backends.InotifyWait
    {:win32, :nt}      -> ExFSWatch.Backends.InotifyWaitWin32
    _                  -> nil
  end)

  def start(_, _) do
    if os_supported?() and port_found?() do
      ExFSWatch.Supervisor.start_link
    else
      Logger.error "ExFSWatch start failed"
      if os_supported?() do
        Logger.error "backend port not found: #{@backend}"
      else
        Logger.error "fs does not support the current operating system"
      end
      {:ok, self()}
    end
  end

  def os_supported? do
    not is_nil @backend
  end

  def port_found? do
    @backend.find_executable()
  end

  def known_events do
    @backend.known_events()
  end

  def backend do
    @backend
  end
end
