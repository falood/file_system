defmodule FileSystem.Worker do
  use GenServer

  def start_link(args) do
    {args, opts} = Keyword.split(args, [:dirs, :listener_extra_args])
    GenServer.start_link(__MODULE__, args, opts)
  end

  def init(args) do
    {:ok, backend_pid} = FileSystem.backend.start_link([{:worker_pid, self()} | args])
    {:ok, %{backend_pid: backend_pid, subscribers: %{}}}
  end

  def handle_call(:subscribe, {pid, _}, state) do
    ref = Process.monitor(pid)
    state = put_in(state, [:subscribers, ref], pid)
    {:reply, :ok, state}
  end

  def handle_info({:backend_file_event, backend_pid, file_event}, %{backend_pid: backend_pid}=state) do
    state.subscribers |> Enum.each(fn {_ref, subscriber_pid} ->
      send(subscriber_pid, {:file_event, self(), file_event})
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
