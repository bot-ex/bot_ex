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
    msgs
    |> Enum.group_by(fn %Message{user_id: user, module: module, from: bot} ->
      {user, module, bot}
    end)
    |> Enum.each(&handle_msgs/1)
  end

  @spec handle_msgs({{integer(), module(), atom()}, [Message.t(), ...]}) :: nil
  defp handle_msgs({{_user_id, m, bot}, msgs}) do
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
    case :persistent_term.get({:bot_ex_settings, :routes, :config}, []) do
      [] -> load_routes()
      routes -> routes
    end
  end

  # load routes from file
  @spec load_routes() :: map()
  defp load_routes() do
    base_routes =
      Config.get(:handlers)
      |> Enum.reduce(%{}, fn {bot, hs}, acc ->
        Map.put(acc, bot, Enum.reduce(hs, %{}, &put_route/2))
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

  @spec put_route({module(), integer()} | module() | any(), map()) :: map()
  defp put_route({h, _b_t}, acc), do: Map.put(acc, h.get_cmd_name(), h)
  defp put_route(h, acc) when is_atom(h), do: Map.put(acc, h.get_cmd_name(), h)

  defp put_route(error, acc) do
    # coveralls-ignore-start
    Logger.error("Not supported definition #{inspect(error)}")
    acc
    # coveralls-ignore-stop
  end
end
