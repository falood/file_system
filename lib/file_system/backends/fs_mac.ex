require Logger

defmodule FileSystem.Backends.FSMac do
  @moduledoc """
  This file is a fork from https://github.com/synrc/fs.
  FileSysetm backend for macos, a GenServer receive data from Port, parse event
  and send it to the worker process.
  Will compile executable the buildin executable file when file the first time it is used.

  ## Backend Options

    * `:latency` (float, default: 0.5), latency period.

    * `:no_defer` (bool, default: false), enable no-defer latency modifier.
      Works with latency parameter, Also check apple `FSEvent` api documents
      https://developer.apple.com/documentation/coreservices/kfseventstreamcreateflagnodefer

    * `:watch_root` (bool, default: false), watch for when the root path has changed.
      Set the flag `true` to monitor events when watching `/tmp/fs/dir` and run
      `mv /tmp/fs /tmp/fx`. Also check apple `FSEvent` api documents
      https://developer.apple.com/documentation/coreservices/kfseventstreamcreateflagwatchroot

    * recursive is enabled by default, no option to disable it for now.
  """

  use GenServer
  @behaviour FileSystem.Backend

  def bootstrap do
    exec_file = find_executable()
    unless File.exists?(exec_file) do
      Logger.info "Compiling executable file..."
      src_dir =
        case Mix.Project.config[:app] do
          :file_system ->
            "."
          _ ->
            Mix.Project.deps_paths[:file_system]
        end
      cmd = "clang -framework CoreFoundation -framework CoreServices -Wno-deprecated-declarations #{src_dir}/c_src/mac/*.c -o #{exec_file}"
      if Mix.shell.cmd(cmd) > 0 do
        Logger.error "Compile executable file error, try to run `#{cmd}` manually."
        raise "compile backend error"
      else
        Logger.info "Compile executable file, Done."
      end
    end
    :ok
  rescue
    _ -> {:error, :fs_mac_bootstrap_error}
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

  defp find_executable do
    (:code.priv_dir(:file_system) ++ '/mac_listener') |> to_string
  end

  def parse_options(options) do
    case Keyword.pop(options, :dirs) do
      {nil, _} ->
        Logger.error "required argument `dirs` is missing"
        {:error, :missing_dirs_argument}
      {dirs, rest} ->
        args = ['-F' | dirs |> Enum.map(&Path.absname/1) |> Enum.map(&to_charlist/1)]
        parse_options(rest, args)
    end
  end

  defp parse_options([], result), do: {:ok, result}
  defp parse_options([{:latency, latency} | t], result) do
    result =
      if is_float(latency) or is_integer(latency) do
        ['--latency=#{latency / 1}' | result]
      else
        Logger.error "latency should be integer or float, got `#{inspect latency}, ignore"
        result
      end
    parse_options(t, result)
  end
  defp parse_options([{:no_defer, true} | t], result) do
    parse_options(t, ['--no-defer' | result])
  end
  defp parse_options([{:no_defer, false} | t], result) do
    parse_options(t, result)
  end
  defp parse_options([{:no_defer, value} | t], result) do
    Logger.error "unknown value `#{inspect value}` for no_defer, ignore"
    parse_options(t, result)
  end
  defp parse_options([{:with_root, true} | t], result) do
    parse_options(t, ['--with-root' | result])
  end
  defp parse_options([{:with_root, value} | t], result) do
    Logger.error "unknown value `#{inspect value}` for with_root, ignore"
    parse_options(t, result)
  end
  defp parse_options([h | t], result) do
    Logger.error "unknown option `#{inspect h}`, ignore"
    parse_options(t, result)
  end

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, [])
  end

  def init(args) do
    {worker_pid, rest} = Keyword.pop(args, :worker_pid)
    case parse_options(rest) do
      {:ok, port_args} ->
        port = Port.open(
          {:spawn_executable, to_charlist(find_executable())},
          [:stream, :exit_status, {:line, 16384}, {:args, port_args}, {:cd, System.tmp_dir!()}]
        )
        Process.link(port)
        Process.flag(:trap_exit, true)
        {:ok, %{port: port, worker_pid: worker_pid}}
      {:error, _} ->
        :ignore
    end
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

  def handle_info({:EXIT, port, _reason}, %{port: port}=state) do
    send(state.worker_pid, {:backend_file_event, self(), :stop})
    {:noreply, state}
  end

  def handle_info(_, state) do
    {:noreply, state}
  end

  def parse_line(line) do
    [_, _, events, path] = line |> to_string |> String.split(["\t", "="])
    {path, events |> String.split(~w|[ , ]|, trim: true) |> Enum.map(&String.to_existing_atom/1)}
  end

end
