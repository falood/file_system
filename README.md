# FileSystem

[![Module Version](https://img.shields.io/hexpm/v/file_system.svg)](https://hex.pm/packages/file_system)
[![Hex Docs](https://img.shields.io/badge/hex-docs-lightgreen.svg)](https://hexdocs.pm/file_system/)
[![Total Download](https://img.shields.io/hexpm/dt/file_system.svg)](https://hex.pm/packages/file_system)
[![License](https://img.shields.io/hexpm/l/file_system.svg)](https://github.com/falood/file_system/blob/master/LICENSE)
[![Last Updated](https://img.shields.io/github/last-commit/falood/file_system.svg)](https://github.com/falood/file_system/commits/master)

An Elixir file change watcher wrapper based on
[FS](https://github.com/synrc/fs), the native file system listener.

## System Support

- MacOS - [fsevent](https://github.com/thibaudgg/rb-fsevent)
- GNU/Linux, FreeBSD and OpenBSD - [inotify](https://github.com/rvoicilas/inotify-tools/wiki)
- Windows - [inotify-win](https://github.com/thekid/inotify-win)

On MacOS 10.14, to compile `mac_listener`, run:

```console
open /Library/Developer/CommandLineTools/Packages/macOS_SDK_headers_for_macOS_10.14.pkg
```

## Usage

Put `:file_system` in the `deps` and `application` part of your `mix.exs`:

``` elixir
defmodule Excellent.Mixfile do
  use Mix.Project

  def project do
  ...
  end

  defp deps do
    [
      { :file_system, "~> 0.2", only: :test },
    ]
  end
  ...
end
```

### Subscription API

You can spawn a worker and subscribe to events from it:

```elixir
{:ok, pid} = FileSystem.start_link(dirs: ["/path/to/some/files"])
FileSystem.subscribe(pid)
```

or

```elixir
{:ok, pid} = FileSystem.start_link(dirs: ["/path/to/some/files"], name: :my_monitor_name)
FileSystem.subscribe(:my_monitor_name)
```

The `pid` you subscribed from will now receive messages like:

```
{:file_event, worker_pid, {file_path, events}}
```
and

```
{:file_event, worker_pid, :stop}
```

### Example Using GenServer

```elixir
defmodule Watcher do
  use GenServer

  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end

  def init(args) do
    {:ok, watcher_pid} = FileSystem.start_link(args)
    FileSystem.subscribe(watcher_pid)
    {:ok, %{watcher_pid: watcher_pid}}
  end

  def handle_info({:file_event, watcher_pid, {path, events}}, %{watcher_pid: watcher_pid} = state) do
    # Your own logic for path and events
    {:noreply, state}
  end

  def handle_info({:file_event, watcher_pid, :stop}, %{watcher_pid: watcher_pid} = state) do
    # Your own logic when monitor stop
    {:noreply, state}
  end
end
```

## Backend Options

For each platform, you can pass extra options to the underlying listener
process.

Each backend supports different extra options, check backend module
documentation for more details.

Here is an example to get instant notifications on file changes for MacOS:

```elixir
FileSystem.start_link(dirs: ["/path/to/some/files"], latency: 0, watch_root: true)
```

## License

Copyright (C) 2016 Xiangrong Hao

Everyone is permitted to copy and distribute verbatim or modified
copies of this license document, and changing it is allowed as long
as the name is changed.

           DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
  TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION

 0. You just DO WHAT THE FUCK YOU WANT TO.
