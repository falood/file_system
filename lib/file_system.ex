defmodule FileSystem do
  defmacro __using__(options) do
    quote do
      @file_system_module_options unquote(options)
      @before_compile FileSystem.ModuleApi
    end
  end

  def start_link(args) do
    FileSystem.Worker.start_link(args)
  end

  def subscribe(pid) do
    GenServer.call(pid, :subscribe)
  end

  @backend FileSystem.Backend.backend
  def backend, do: @backend
  def known_events, do: @backend.known_events()

end
