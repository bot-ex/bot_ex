defmodule BotEx.Config do
  alias BotEx.Core.Messages.DefaultBufferingStrategy

  @moduledoc """
  Configurations module

  # Example:
  ```elixir
  config :bot_ex,
    middleware: [
      my_bot: [
        MyBot.Middleware.MessageTransformer,
        MyBot.Middleware.Auth
      ]
    ],
    handlers: [
      my_bot: [
        {MyBot.Handlers.Start, 1000} # {module, bufering time}
      ]
    ],
    bots: [:my_bot]
  ```
  """

  @defaults [
    menu_path: "config/menu.exs",
    routes_path: "config/routes.exs",
    default_buffering_time: 3000,
    buffering_strategy: DefaultBufferingStrategy,
    after_start: [],
    show_msg_log: true,
    analytic_key: nil,
    middleware: [],
    bots: [],
    handlers: []
  ]

  @spec init :: :ok
  def init() do
    @defaults
    |> DeepMerge.deep_merge(Application.get_all_env(:bot_ex))
    |> Enum.each(fn {name, value} ->
      :persistent_term.put({:bot_ex_settings, name, :config}, value)
    end)
  end

  @doc """
  Return config value by name
  """
  @spec get(atom()) :: any()
  def get(param_key) do
    :persistent_term.get({:bot_ex_settings, param_key, :config})
  end

  @spec put(atom(), any()) :: any()
  def put(param_key, value) do
    :persistent_term.put({:bot_ex_settings, param_key, :config}, value)
  end
end
