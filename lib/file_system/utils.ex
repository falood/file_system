defmodule FileSystem.Utils do
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

  def format_path(path) when is_list(path) do
    for i <- path do
      i |> Path.absname |> to_charlist
    end
  end

  def format_path(path) do
    [path] |> format_path
  end

  def format_args(nil), do: []
  def format_args(str) when is_binary(str) do
    str |> String.split |> format_args
  end
  def format_args(list) when is_list(list) do
    list |> Enum.map(&to_charlist/1)
  end

end
