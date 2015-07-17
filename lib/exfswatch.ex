require Logger

defmodule ExFSWatch do
  defmacro __using__([dirs: dirs]) do
    quote do
      def __dirs__, do: unquote(dirs)
      def start,    do: ExFSWatch.Supervisor.start_child __MODULE__
    end
  end

  @backend (case :os.type() do
    {:unix,    :darwin} -> :fsevents
    {:unix,    :linux}  -> :inotifywait
    {:"win32", :nt}     -> :"inotifywait_win32"
     _                  -> nil
  end)

  def start(_, _) do
    if os_supported? and port_found? do
      ExFSWatch.Supervisor.start_link
    else
      Logger.error "ExFSWatch start failed"
      if os_supported? do
        Logger.error "backend port not found: #{@backend}"
      else
        Logger.error "fs does not support the current operating system"
      end
      {:ok, self}
    end
  end

  def os_supported? do
    not is_nil @backend
  end

  def port_found? do
    @backend.find_executable
  end

  def known_events do
    @backend.known_events
  end

  def backend do
    @backend
  end
end
