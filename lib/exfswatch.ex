defmodule ExFSWatch do
  defmacro __using__([dirs: dirs]) do
    quote do
      def __dirs__, do: unquote(dirs)
      def start,    do: ExFSWatch.Supervisor.start_child __MODULE__
    end
  end

  def start(_, _) do
    ExFSWatch.Supervisor.start_link
  end
end
