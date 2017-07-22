defmodule FileSystem do
  def start_link(args) do
    FileSystem.Worker.start_link(args)
  end

  def subscribe(pid) do
    GenServer.call(pid, :subscribe)
  end

  @backend FileSystem.Utils.backend
  def backend, do: @backend
  def known_events, do: @backend.known_events()

end
