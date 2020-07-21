defmodule BotEx.Routing.Router do
  alias BotEx.Models.Message

  require Logger
  alias BotEx.Config
  import BotEx.Helpers.Debug, only: [print_debug: 1]

  @doc """
  Send messages to handlers.
  ## Parameters:
  - msgs: list of `BotEx.Models.Message`
  """
  @spec send_to_handler([Message.t(), ...]) :: :ok
  def send_to_handler(msgs) when is_list(msgs) do
    grouping_strategy = Config.get(:grouping_strategy)
    grouping_strategy.group_and_send(msgs)
  end

  @spec handle_msgs(module(), atom(), [Message.t(), ...]) :: nil
  def handle_msgs(m, bot, msgs) do
    routes = Map.get(get_routes(), bot)

    unless is_nil(routes[m]) do
      send_message(routes[m], msgs)
    else
      # coveralls-ignore-start
      Logger.error("No route found for \"#{m}\"\nAvailable routes:\n#{inspect(routes)}")
      msgs
      # coveralls-ignore-stop
    end

    nil
  end

  # Send message to the worker
  # ## Parameters
  # - info: message `BotEx.Models.Message` for sending
  # return `BotEx.Models.Message`
  @spec send_message(atom(), [Message.t(), ...]) :: [Message.t(), ...]
  defp send_message(module, msgs) do
    print_debug("Send messages to #{module}")

    Task.start_link(fn ->
      Enum.each(msgs, fn msg ->
        module.handle_message(msg)
      end)
    end)

    msgs
  end

  # return list of routes
  @spec get_routes() :: map()
  defp get_routes() do
    case Config.get(:routes, []) do
      [] -> load_routes()
      routes -> routes
    end
  end

  # load routes from file
  @spec load_routes() :: map()
  defp load_routes() do
    base_routes =
      Config.get(:handlers)
      |> Map.new(fn {bot, hs} ->
        {bot, Map.new(hs, &put_route/1)}
      end)

    path = Config.get(:routes_path)

    full_routes =
      if File.exists?(path) do
        {add_path, _} = Code.eval_file(path)
        DeepMerge.deep_merge(base_routes, add_path)
      else
        base_routes
      end

    Config.put(:routes, full_routes)

    full_routes
  end

  @spec put_route({module(), integer()} | module() | any()) :: tuple()
  defp put_route({h, _b_t}), do: {h.get_cmd_name(), h}
  defp put_route(h) when is_atom(h), do: {h.get_cmd_name(), h}

  defp put_route(error) do
    # coveralls-ignore-start
    Logger.error("Not supported definition #{inspect(error)}")
    # coveralls-ignore-stop
  end
end
