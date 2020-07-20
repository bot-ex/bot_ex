defmodule BotEx.Application do
  use Application

  alias BotEx.Helpers.Tools
  alias BotEx.Behaviours.Hook
  alias BotEx.Config
  alias BotEx.Exceptions.BehaviourError

  @spec start(any(), any()) :: {:error, any()} | {:ok, pid()}
  def start(_type, _args) do
    :ets.new(:last_call, [:set, :public, :named_table])

    Config.init()

    Config.get(:grouping_strategy)
    |> Tools.is_behaviours?(BotEx.Behaviours.GroupingStrategy)

    opts = [strategy: :one_for_one, name: BotEx.Supervisor]
    {:ok, pid} = Supervisor.start_link([BotEx.Routing.MessageHandler], opts)

    run_hooks()

    {:ok, pid}
  end

  defp run_hooks() do
    Config.get(:after_start)
    |> Enum.each(fn hook ->
      unless Tools.is_behaviours?(hook, Hook) do
        # coveralls-ignore-start
        raise(BehaviourError,
          message: "Module #{hook} must implement behaviour BotEx.Behaviours.Hook"
        )
        # coveralls-ignore-stop
      end

      hook.run()
    end)
  end
end
