defmodule BotEx.Routing.Router do
  alias BotEx.Models.Message

  require Logger
  alias BotEx.Config

  @doc """
  Send message to handler.
  ## Parameters:
  - msg: `BotEx.Models.Message` message
  """
  @spec send_to_handler(Message.t()) :: Message.t()
  def send_to_handler(%Message{module: m, from: bot} = msg) do
    routes = Map.get(get_routes(), bot)

    unless is_nil(routes[m]) do
      routes[m].send_message(msg)
    else
      Logger.error("No route found for \"#{m}\"\nAvailable routes:\n#{inspect(routes)}")
      msg
    end
  end

  # return list of routes
  defp get_routes() do
    case :persistent_term.get({:bot_ex_settings, :routes, :config}, []) do
      [] -> load_routes()
      routes -> routes
    end
  end

  # load routes from file
  defp load_routes() do
    base_routes =
      Enum.reduce(Config.get(:handlers), %{}, fn {bot, hs}, acc ->
        Map.put(
          acc,
          bot,
          Enum.reduce(hs, %{}, fn {h, _cnt}, acc ->
            Map.put(acc, h.get_cmd_name(), h)
          end)
        )
      end)

    path = Config.get(:routes_path)

    full_routes =
      if File.exists?(path) do
        {add_path, _} = Code.eval_file(path)
        DeepMerge.deep_merge(base_routes, add_path)
      else
        base_routes
      end

    :persistent_term.put({:bot_ex_settings, :routes, :config}, full_routes)

    full_routes
  end
end
