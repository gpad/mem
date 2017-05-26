defmodule Mem.Supervisor do

  defmacro __using__(opts) do
    storages  = opts |> Keyword.fetch!(:storages)
    processes = opts |> Keyword.fetch!(:processes)
    nodes = opts |> Keyword.fetch!(:nodes)
    quote do
      @storages  unquote(storages)
      @processes unquote(processes)
      @nodes     unquote(nodes)

      use Supervisor

      def start_link do
        for {_, module} <- @storages do
          module.create(@nodes)
        end
        Supervisor.start_link(__MODULE__, [], name: __MODULE__)
      end

      def init([]) do
        for {_, module} <- @processes do
          worker(module, [])
        end |> supervise(strategy: :one_for_one)
      end
    end
  end

end
