require Logger

defmodule FileSystem.Backend do
  @callback bootstrap() :: :ok | {:error, atom()}
  @callback supported_systems() :: [{atom(), atom()}]
  @callback known_events() :: [atom()]

  def backend(backend) do
    with {:ok, backend_module} <- backend_module(backend),
         :ok <- validate_os(backend_module),
         :ok <- backend_module.bootstrap
    do
      {:ok, backend_module}
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
    {:start_link, 1} in functions && {:validate!, 0} in functions || raise "illegal backend"
  rescue
    _ ->
      Logger.error "It seems you are using custom backend `#{inspect module}`, make sure it's a legal file_system backend module."
      {:error, :illegal_backend}
  end

  defp validate_os(backend) do
    :os.type() in backend.supported_systems() && :ok || {:error, :unsupported_system}
  end
end
