defmodule ExFSWatch.Worker do
  use GenServer

  defstruct [:port, :backend, :module]

  def start_link(module) do
    GenServer.start_link(__MODULE__, module, name: module)
  end

  def init(module) do
    backend = ExFSWatch.backend
    port = start_port(backend, module.__dirs__)
    {:ok, %__MODULE__{port: port, backend: backend, module: module}}
  end

  def handle_info({port, {:data, {:eol, line}}}, %__MODULE__{port: port, backend: backend, module: module}=sd) do
    {file_path, events} = backend(backend).line_to_event(to_string line)
    module.callback(file_path |> to_string, events)
    {:noreply, sd}
  end

  def handle_info({port, {:exit_status, 0}}, %__MODULE__{port: port, module: module}) do
    module.callback(:stop)
    {:stop, :killed}
  end

  def handle_info(_, sd) do
    {:noreply, sd}
  end


  defp start_port(:fsevents, path) do
    path = path |> format_path
    Port.open({:spawn_executable, :fsevents.find_executable()},
              [:stream, :exit_status, {:line, 16384}, {:args, ['-F' | path]}, {:cd, System.tmp_dir!}]
    )
  end
  defp start_port(:inotifywait, path) do
    path = path |> format_path
    args = [ '-c', 'inotifywait $0 $@ & PID=$!; read a; kill $PID',
             '-m', '-e', 'close_write', '-e', 'moved_to', '-e', 'create', '-e',
             'delete_self', '-e', 'delete', '-r' | path
           ]
    Port.open({:spawn_executable, :os.find_executable('sh')},
              [:stream, :exit_status, {:line, 16384}, {:args, args}, {:cd, System.tmp_dir!}]
    )
  end
  defp start_port(:"inotifywait_win32", path) do
    path = path |> format_path
    args = ['-m', '-r' | path]
    Port.open({:spawn_executable, :"inotifywait_win32".find_executable()},
              [:stream, :exit_status, {:line, 16384}, {:args, args}, {:cd, System.tmp_dir!}]
    )
  end

  defp format_path(path) when is_list(path) do
    for i <- path do
      i |> Path.absname |> to_char_list
    end
  end
  defp format_path(path) do
    [path] |> format_path
  end

  defp backend(:inotifywait), do: ExFSWatch.Sys.InotifyWait
  defp backend(be), do: be
end
