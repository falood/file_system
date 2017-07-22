defmodule FileSystem.Backend do
  @callback find_executable() :: Sting.t
  @callback start_port(String.t, keyword()) :: port()
  @callback known_events() :: [atom()]
  @callback line_to_event(String.t) :: {String.t, [atom()]}
end
