defmodule FileSystem.Backend do
  @callback bootstrap() :: any()
  @callback supported_systems() :: [{atom(), atom()}]
  @callback known_events() :: [atom()]
  @callback find_executable() :: Sting.t
end
