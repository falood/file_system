ExFSWatch
=========

A file change watcher wrapper based on [fs](https://github.com/synrc/fs)

## System Support

Just like [fs](https://github.com/synrc/fs#backends)

- Mac fsevent
- Linux inotify
- Windows inotify-win (untested)

NOTE: On Linux you need to install inotify-tools.

## Usage

Put `exfswatch` in the `deps` and `application` part of your mix.exs

``` elixir
defmodule Excellent.Mixfile do
  use Mix.Project

  def project do
  ...
  end

  def application do
    [applications: [:exfswatch, :logger]]
  end

  defp deps do
    [
      { :exfswatch, "~> 0.1.0", only: :test },
    ]
  end
  ...
end
```

write `lib/monitor.ex`

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

Execute in iex

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
