require Logger

defmodule FileSystem.Backend do
  @callback bootstrap() :: :ok | {:error, atom()}
  @callback supported_systems() :: [{atom(), atom()}]
  @callback known_events() :: [atom()]

  def backend(backend) do
    with {:ok, module} <- backend_module(backend),
         :ok <- validate_os(backend, module),
         :ok <- module.bootstrap
    do
      {:ok, module}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  defp backend_module(nil) do
    case :os.type() do
      {:unix,  :darwin}  -> :fs_mac
      {:unix,  :linux}   -> :fs_inotify
      {:unix,  :freebsd} -> :fs_inotify
      {:win32, :nt}      -> :fs_windows
      system             -> {:unsupported_system, system}
    end |> backend_module
  end
  defp backend_module(:fs_mac),     do: {:ok, FileSystem.Backends.FSMac}
  defp backend_module(:fs_inotify), do: {:ok, FileSystem.Backends.FSInotify}
  defp backend_module(:fs_windows), do: {:ok, FileSystem.Backends.FSWindows}
  defp backend_module({:unsupported_system, system}) do
    Logger.error "I'm so sorry but `file_system` does NOT support your current system #{inspect system} for now."
    {:error, :unsupported_system}
  end
  defp backend_module(module) do
    functions = module.__info__(:functions)
    {:start_link, 1} in functions &&
    {:bootstrap, 0} in functions &&
    {:supported_systems, 0} in functions ||
      raise "illegal backend"
  rescue
    _ ->
      Logger.error "You are using custom backend `#{inspect module}`, make sure it's a legal file_system backend module."
      {:error, :illegal_backend}
  end

  defp validate_os(backend, module) do
    os_type = :os.type()
    if os_type in module.supported_systems() do
      :ok
    else
      Logger.error "The backend #{backend} you are using does NOT support your current system #{inspect os_type}."
      {:error, :unsupported_system}
    end
  end
end
