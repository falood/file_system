defmodule FileSystem.Utils do
  def backend do
    case :os.type() do
      {:unix,  :darwin}  -> FileSystem.Backends.Fsevents
      {:unix,  :freebsd} -> FileSystem.Backends.Kqueue
      {:unix,  :linux}   -> FileSystem.Backends.InotifyWait
      {:win32, :nt}      -> FileSystem.Backends.InotifyWaitWin32
      _                  -> nil
    end
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
