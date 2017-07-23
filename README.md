FileSystem
=========

A file change watcher wrapper based on [fs](https://github.com/synrc/fs)

## System Support

Just like [fs](https://github.com/synrc/fs#backends)

- Mac fsevent
- Linux inotify
- Windows inotify-win (untested)

NOTE: On Linux you need to install inotify-tools.

## Usage

Put `file_system` in the `deps` and `application` part of your mix.exs

``` elixir
defmodule Excellent.Mixfile do
  use Mix.Project

  def project do
  ...
  end

  defp deps do
    [
      { :file_system, "~> 0.1.0", only: :test },
    ]
  end
  ...
end
```


### Subscription API

You can spawn a worker and subscribe to events from it:

```elixir
{:ok, pid} = FileSystem.Worker.start_link(dirs: ["/path/to/some/files"])
FileSystem.Worker.subscribe(pid)
```

The pid you subscribed from will now receive messages like

```
{:file_event, worker_pid, {file_path, events}}
```
and
```
{:file_event, worker_pid, :stop}
```

### Callback API

You can also `use FileSystem` to define a module with a callback that will be called when filesystem events occur. This requires you to specify directories to watch at compile-time.

write `lib/monitor.ex`

```elixir
defmodule Monitor do
  use FileSystem, dirs: ["/tmp/test"]

  def callback(:stop) do
    IO.puts "STOP"
  end

  def callback(file_path, events) do
    IO.inspect {file_path, events}
  end
end
```

Execute in iex

```shell
iex > Monitor.start
```

## Tweaking behaviour via listener extra arguments

For each platform, you can pass extra arguments to the underlying listener process via the `listener_extra_args` option.

Here is an example to get instant notifications on file changes for Mac OS X:

```elixir
use FileSystem, dirs: ["/tmp/test"], listener_extra_args: "--latency=0.0"
```

See the [fs source](https://github.com/synrc/fs/tree/master/c_src) for more details.

## List Events from Backend

```shell
iex > FileSystem.known_events
```
