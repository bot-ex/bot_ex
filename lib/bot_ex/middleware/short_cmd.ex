defmodule BotEx.Middleware.ShortCmd do
  @moduledoc """
  Middlware that checks if a user message matches short commands
  """

  @behaviour BotEx.Behaviours.Middleware

  alias BotEx.Models.Message
  alias BotEx.Config

  @doc """
  Check user message
  """
  @spec transform(Message.t()) :: Message.t()
  def transform(%Message{module: m, action: a, data: d, text: "", from: bot} = t_msg) do
    check_on_short(m, a, d, bot)
    |> fill_command_data(t_msg)
  end

  def transform(%Message{action: a, data: d, text: t, from: bot} = t_msg) do
    check_on_short(t, a, d, bot)
    |> fill_command_data(t_msg)
    
    %Message{t_msg | is_cmd: false}
  end

  defp fill_command_data({new_m, new_a, new_d}, t_msg),
    do: %Message{t_msg | module: new_m, action: new_a, data: new_d, is_cmd: true}

  defp fill_command_data(_, t_msg), do: t_msg

  # checks the command on the list of abbreviations
  # and modifies the final call
  # ## Parameters:
  # - cmd: string command
  # - action: action
  # - data: data
  @spec check_on_short(binary() | nil, nil | binary(), nil | binary(), atom()) ::
          {binary(), nil | binary(), nil | binary()} | nil
  defp check_on_short(nil, _action, _data, _bot), do: nil
  defp check_on_short("", _action, _data, _bot), do: nil

  defp check_on_short(cmd, action, data, bot) do
    shorts = Map.get(get_shorts(), bot, %{})

    case String.split(cmd, "_", parts: 2) do
      [cm, dd] ->
        case Map.get(shorts, cm) do
          nil -> {cmd, action, data}
          {module, act} -> {module, act, dd}
        end

      _ ->
        case Map.get(shorts, cmd) do
          nil -> {cmd, action, data}
          {module, act} -> {module, act, data}
        end
    end
  end

  # return list short commands
  defp get_shorts() do
    case :persistent_term.get({:bot_ex_settings, :shorts, :config}, []) do
      [] -> load_shorts()
      data -> data
    end
  end

  # load shorts from file on first call
  defp load_shorts() do
    path = Config.get(:short_map_path)

    shorts_cmd =
      if File.exists?(path) do
        {cmd, _} = Code.eval_file(path)
        cmd
      else
        %{}
      end

    :persistent_term.put({:bot_ex_settings, :shorts, :config}, shorts_cmd)

    shorts_cmd
  end
end
