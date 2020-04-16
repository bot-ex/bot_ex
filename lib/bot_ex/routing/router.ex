defmodule BotEx.Routing.Router do
  alias BotEx.Models.Message

  require Logger
  alias BotEx.Config

  @doc """
  Send messages to handlers.
  ## Parameters:
  - msgs: list of `BotEx.Models.Message`
  """
  @spec send_to_handler([Message.t(), ...] | Message.t()) :: [Message.t(), ...]
  def send_to_handler(msgs) when is_list(msgs) do
    msgs
    |> Enum.group_by(fn %Message{user_id: user, module: module, from: bot} ->
      {user, module, bot}
    end)
    |> Enum.each(&handle_msgs/1)
  end

  @deprecated "use send_to_handler/1 with the first argument as a list of messages"
  def send_to_handler(%Message{user_id: user_id} = msg), do: handle_msgs({user_id, [msg]})

  defp handle_msgs({{_user_id, m, bot}, msgs}) do
    routes = Map.get(get_routes(), bot)

    unless is_nil(routes[m]) do
      routes[m].send_message(msgs)
    else
      Logger.error("No route found for \"#{m}\"\nAvailable routes:\n#{inspect(routes)}")
      msgs
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
          Enum.reduce(hs, %{}, fn
            {h, _cnt}, acc ->
              Map.put(acc, h.get_cmd_name(), h)

            {h, _cnt, _b_t}, acc ->
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
