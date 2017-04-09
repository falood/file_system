defmodule ExFSWatch.Worker do
  use GenServer

  defstruct [:port, :backend, :module]

  def start_link(module) do
    GenServer.start_link(__MODULE__, module, name: module)
  end

  def init(module) do
    backend = ExFSWatch.backend
    port = backend.start_port(module.__dirs__, module.__listener_extra_args__)
    {:ok, %__MODULE__{port: port, backend: backend, module: module}}
  end

  def handle_info({port, {:data, {:eol, line}}}, %__MODULE__{port: port, backend: backend, module: module}=sd) do
    {file_path, events} = backend.line_to_event(line)
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
end
