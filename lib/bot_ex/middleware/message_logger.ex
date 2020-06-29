defmodule BotEx.Middleware.MessageLogger do
  @moduledoc """
  Logs messages
  """
  @behaviour BotEx.Behaviours.Middleware

  alias BotEx.Models.Message
  import BotEx.Helpers.Debug, only: [print_debug: 1]

  @doc """
  Debug messages in terminal
  """
  @spec transform(Message.t()) :: Message.t()
  def transform(%Message{} = t_msg) do
    debug(t_msg)

    t_msg
  end

  defp debug(t_msg) do
    t_msg
    |> info_to_string
    |> print_debug()

    print_debug("==========")
  end

  @doc """
  Create debug message from `BotEx.Models.Message`
  """
  @spec info_to_string(Message.t()) :: String.t()
  def info_to_string(%Message{
        action: action,
        module: module,
        data: data
      }) do
    "Route to:\n" <>
      " - module: #{inspect(module)} \n - action: #{action}\n - data: #{inspect(data)}"
  end
end
