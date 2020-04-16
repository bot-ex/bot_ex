defmodule BotEx.Config do
  @moduledoc """
  Configurations module

  # Example:
  ```elixir
  config :bot_ex,
    middlware: [
      my_bot: [
        MyBot.Middleware.MessageTransformer,
        MyBot.Middleware.Auth
      ]
    ],
    handlers: [
      my_bot: [
        {MyBot.Handlers.Start, 1} # {module, count worker processes in pool}
      ]
    ],
    bots: [:my_bot]
  ```
  """

  @defaults [
    menu_path: "config/menu.exs",
    routes_path: "config/routes.exs",
    short_map_path: "config/short_map.exs",
    default_buffer_time: 3000,
    after_start: [],
    show_msg_log: true,
    analytic_key: nil,
    middlware: [],
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
  @spec get(atom()) :: any
  def get(parameter) do
    :persistent_term.get({:bot_ex_settings, parameter, :config})
  end
end
