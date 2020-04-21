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
  @spec get(atom()) :: any()
  def get(param_key) do
    :persistent_term.get({:bot_ex_settings, param_key, :config})
  end

  @doc """
    use with aware! it can be a bit slower. For test mostly
  """
  @spec put_unsafe(atom(), any()) :: any()
  def put(param_key, value) do
    :persistent_term.put({:bot_ex_settings, param_key, :config}, value)
  end

  @spec put_new!(atom(), any()) :: any()
  def put_once!(param_key, value, default) do
    if is_update?(param_key, value, default) do
      raise "you are trying to replace an existing value! in storage: #{inspect(current)}\n
      your value: #{inspect(value)}"
    end

    :persistent_term.put({:bot_ex_settings, param_key, :config}, value)
  end
  
  defp is_update?(param_key, value, default) do
    
    current = :persistent_term.get({:bot_ex_settings, param_key, :config})
    
    current != default and current != value 
  end
end
