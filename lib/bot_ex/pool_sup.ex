defmodule BotEx.PoolSup do
  @moduledoc false

  use Supervisor
  alias BotEx.Config

  defp poolboy_config(module, w_count) do
    [
      {:name, {:local, module}},
      {:worker_module, module},
      {:size, w_count},
      {:max_overflow, w_count * 5}
    ]
  end

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]},
      type: :supervisor
    }
  end

  def start_link(_args) do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  @spec init(any()) :: {:ok, {:supervisor.sup_flags(), [:supervisor.child_spec()]}} | :ignore
  def init(_init_arg) do
    handlers = Config.get_handlers()

    children =
      Config.get_bots()
      |> Enum.map(fn key -> Keyword.get(handlers, key, []) end)
      |> List.flatten()
      |> Enum.map(fn
        {module, cnt}               -> :poolboy.child_spec(module, poolboy_config(module, cnt))
        module when is_atom(module) -> :poolboy.child_spec(module, poolboy_config(module, 1))
      end)

    opts = [strategy: :one_for_one]
    Supervisor.init(children, opts)
  end
end
