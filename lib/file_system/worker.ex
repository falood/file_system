defmodule FileSystem.Worker do
  @moduledoc """
  FileSystem Worker Process with the backend GenServer, receive events from Port Process
  and forward it to subscribers.
  """

  use GenServer

  @doc false
  def start_link(args) do
    {args, opts} = Keyword.split(args, [:backend, :dirs, :listener_extra_args])
    GenServer.start_link(__MODULE__, args, opts)
  end

  @doc false
  def init(args) do
    case FileSystem.Backend.backend(args[:backend]) do
      {:ok, backend} ->
        {:ok, backend_pid} = backend.start_link([{:worker_pid, self()} | Keyword.drop(args, [:backend])])
        {:ok, %{backend_pid: backend_pid, subscribers: %{}}}
      {:error, reason} ->
        {:stop, reason}
    end
  end

  @doc false
  def handle_call(:subscribe, {pid, _}, state) do
    ref = Process.monitor(pid)
    state = put_in(state, [:subscribers, ref], pid)
    {:reply, :ok, state}
  end

  @doc false
  def handle_info({:backend_file_event, backend_pid, file_event}, %{backend_pid: backend_pid}=state) do
    state.subscribers |> Enum.each(fn {_ref, subscriber_pid} ->
      send(subscriber_pid, {:file_event, self(), file_event})
    end)
    {:noreply, state}
  end

  def handle_info({:DOWN, _pid, _, ref, _reason}, state) do
    subscribers = Map.drop(state.subscribers, [ref]) |> IO.inspect
    {:noreply, %{state | subscribers: subscribers}}
  end

  def handle_info(_, state) do
    {:noreply, state}
  end
end
