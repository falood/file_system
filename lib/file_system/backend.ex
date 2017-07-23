defmodule FileSystem.Backend do
  @callback bootstrap() :: any()
  @callback supported_systems() :: [{atom(), atom()}]
  @callback known_events() :: [atom()]
  @callback find_executable() :: Sting.t

  def backend do
    os_type = :os.type()
    backend =
      Application.get_env(:file_system, :backend,
        case os_type do
          {:unix,  :darwin}  -> :fs_mac
          {:unix,  :linux}   -> :fs_inotify
          {:unix,  :freebsd} -> :fs_inotify
          {:win32, :nt}      -> :fs_windows
          _                  -> nil
        end
      ) |> case do
        nil         -> raise "undefined backend"
        :fs_mac     -> FileSystem.Backends.FSMac
        :fs_inotify -> FileSystem.Backends.FSInotify
        :fs_windows -> FileSystem.Backends.FSWindows
        any         -> any
      end
    os_type in backend.supported_systems || raise "unsupported system for current backend"
    backend
  end
end
