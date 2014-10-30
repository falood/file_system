defmodule ExFSWatch.Worker do
  use GenServer

  defstruct [:port, :module]

  def start_link(module) do
    GenServer.start_link(__MODULE__, module, name: module)
  end

  def init(module) do
    dirs = module.__dirs__ |> Enum.join " "
    cmd = "fswatch -x #{dirs}"
    port = Port.open(
      {:spawn, cmd |> to_char_list},
      [:binary, {:line, 1024}, :exit_status, :use_stdio, :stderr_to_stdout, :eof]
    )
    {:ok, %__MODULE__{port: port, module: module}}
  end

  def handle_info({port, {:data, {:eol, data}}}, %__MODULE__{port: port, module: module}=sd) do
    [file_path | events] = data |> String.split
    module.callback(file_path, events)
    {:noreply, sd}
  end

  def handle_info({port, {:exit_status, 0}}, %__MODULE__{port: port, module: module}) do
    Port.close(port)
    module.callback(:stop)
    {:stop, :killed}
  end

  def handle_info(_, sd) do
    {:noreply, sd}
  end
end
