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

#### Simple Example

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

#### Live Reload Example



In `lib/monitor.ex` of `MyModule` project:

```elixir
defmodule MyModule.Monitor do

  use ExFSWatch, dirs: ["#{System.cwd!}/lib"]

  def callback(:stop) do
    IO.puts "STOP"
  end

  def callback(file_path, _events) do
    file_path
    |> Path.relative_to_cwd
    |> reloading
    |> File.read!
    |> Code.compile_string
  end

  def reloading(path) do
    IO.puts("Reloading #{path}")
    path
  end
end
```

In `lib/my_module.ex` of `MyModule` project:

```elixir
defmodule MyModule do

  def start(_type, _opts) do
    case Mix.env do
      :dev ->
        MyModule.Monitor.start
        IO.puts "Starting ExFSWatch Live Reload..."
      _ ->
        IO.puts "ExFSWatch Live Reload Disabled"
    end
    {:ok, self()}
  end

end
```

In `mix.exs` of `MyModule` project:

```elixir

  def application do
    [
      applications: [:logger, :exfswatch],
      mod: {MyModule, []}
    ]
  end

  defp deps do
    [
      exfswatch: "0.0.2",
    ]
  end

```

To use the live reload/code hotswap run

```shell
$ iex -S mix
```

## List Events from Backend

```shell
iex > ExFSWatch.known_events
```

## TODO

- [ ] GenEvent mode
- [ ] Unit Testing
