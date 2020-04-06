defmodule BotEx.Config do
  @doc """
  Configurations module
  """

  @defaults [
    menu_path: "config/menu.exs",
    routes_path: "config/routes.exs",
    short_map_path: "config/short_map.exs",
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
    |> DeepMerge.deep_merge(Application.get_all_env(:botex))
    |> Enum.each(fn {name, value} ->
      :ets.insert(:botex_settings, {{name, :config}, value})
    end)
  end

  Enum.each(@defaults, fn {name, _value} ->
    def unquote(:"get_#{name}")() do
      [{_, value}] = :ets.lookup(:botex_settings, {unquote(name), :config})
      value
    end
  end)
end
