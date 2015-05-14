ExFSWatch
=========

A file change watcher wrapper based on [fs](https://github.com/synrc/fs)

## System Support

- Mac fsevent
- Linux inotify (untested)
- Windows inotify-win (untested)

NOTE: On Linux you need to install inotify-tools.

## Usage

```elixir
defmodule Monitor do
  use ExFSWatch, dirs: ["/tmp/fswatch"]

  def callback(:stop) do
    IO.puts "STOP"
  end

  def callback(file_path, events) do
    IO.inspect {file_path, events}
  end
end
```

```shell
iex > Monitor.start
```

## List Events from Backend

```shell
iex > ExFSWatch.known_events
```

## TODO

- [ ] GenEvent mode
- [ ] Unit Testing
