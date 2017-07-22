defmodule FileSystem.Utils do
  def backend do
    os_type = :os.type()
    backend =
      Application.get_env(:file_system, :backend,
        case os_type do
          {:unix,  :darwin}  -> :fs_mac
          _                  -> nil
        end
      ) |> case do
        nil     -> raise "undefined backend"
        :fs_mac -> FileSystem.Backends.FSMac
        any     -> any
      end
    os_type in backend.supported_systems || raise "unsupported system for current backend"
    backend.bootstrap
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

end
