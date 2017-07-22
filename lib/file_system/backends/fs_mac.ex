defmodule FileSystem.Backends.FSMac do
  use GenServer
  @behaviour FileSystem.Backend

  def bootstrap do
    # check whether binary file existed
    # compile
    Mix.shell.cmd("clang -framework CoreFoundation -framework CoreServices -Wno-deprecated-declarations c_src/mac/*.c -o #{find_executable()}")
    # compile failed warning
  end

  def supported_systems do
    [{:unix, :darwin}]
  end

  def known_events do
    [ :mustscansubdirs, :userdropped, :kerneldropped, :eventidswrapped, :historydone,
      :rootchanged, :mount, :unmount, :created, :removed, :inodemetamod, :renamed, :modified,
      :finderinfomod, :changeowner, :xattrmod, :isfile, :isdir, :issymlink, :ownevent,
    ]
  end

  def find_executable do
    :code.priv_dir(:file_system) ++ '/mac_listener'
  end

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, [])
  end

  def init(args) do
    port_path = FileSystem.Utils.format_path(args[:dirs])
    port_args = (args[:listener_extra_args] || []) ++ ['-F' | port_path]
    port = Port.open(
      {:spawn_executable, find_executable()},
      [:stream, :exit_status, {:line, 16384}, {:args, port_args}, {:cd, System.tmp_dir!()}]
    )
    {:ok, %{port: port, worker_pid: args[:worker_pid]}}
  end

  def handle_info({port, {:data, {:eol, line}}}, %{port: port}=state) do
    {file_path, events} = line |> parse_line
    send(state.worker_pid, {:backend_file_event, self(), {file_path, events}})
    {:noreply, state}
  end

  def handle_info({port, {:exit_status, _}}, %{port: port}=state) do
    send(state.worker_pid, {:backend_file_event, self(), :stop})
    {:stop, :normal, state}
  end

  def handle_info(_, state) do
    {:noreply, state}
  end

  def parse_line(line) do
    [_, _, events, path] = line |> to_string |> String.split(["\t", "="])
    {path, events |> String.split(~w|[ , ]|, trim: true) |> Enum.map(&String.to_existing_atom/1)}
  end

end
