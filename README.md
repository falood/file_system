ExFSWatch
=========

Elixir version of fswatch base on [fswatch](https://github.com/emcrisostomo/fswatch)

C_drive version is developing.

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
