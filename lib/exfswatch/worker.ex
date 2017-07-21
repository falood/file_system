defmodule ExFSWatch.Worker do
  use GenServer

  def start_link(args) do
    {args, opts} = Keyword.split(args, [:dirs, :backend, :listener_extra_args])
    GenServer.start_link(__MODULE__, args, opts)
  end

  def subscribe(pid) do
    GenServer.call(pid, :subscribe)
  end

  def init(args) do
    dirs = args[:dirs]
    backend = args[:backend] || ExFSWatch.backend
    listener_extra_args = args[:listener_extra_args] || []
    port = backend.start_port(dirs, listener_extra_args)
    {:ok, %{port: port, backend: backend, subscribers: %{}}}
  end

  def handle_call(:subscribe, {pid, _}, state) do
    ref = Process.monitor(pid)
    state = put_in(state, [:subscribers, ref], pid)
    {:reply, :ok, state}
  end

  def handle_info({_port, {:data, {:eol, line}}}, state) do
    {file_path, events} = state.backend.line_to_event(line)
    state.subscribers |> Enum.each(fn {_ref, pid} ->
      send pid, {:file_event, self(), file_path, events}
    end)

    {:noreply, state}
  end

  def handle_info({_port, {:exit_status, 0}}, state) do
    state.subscribers |> Enum.each(fn {_ref, pid} ->
      send pid, {:file_event, self(), :stop}
    end)

    {:noreply, state}
  end

  def handle_info({:DOWN, _pid, _, ref, _reason}, state) do
    {:noreply, pop_in(state.subscribers[ref])}
  end

  def handle_info(_, state) do
    {:noreply, state}
  end
end
