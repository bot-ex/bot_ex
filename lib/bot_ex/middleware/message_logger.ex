defmodule BotEx.Middleware.MessageLogger do
  @moduledoc """
  Logs messages
  """
  @behaviour BotEx.Behaviours.Middleware

  alias BotEx.Models.Message
  alias BotEx.Config

  require Logger

  @doc """
  Debug messages in terminal
  """
  @spec transform(Message.t()) :: Message.t()
  def transform(%Message{} = t_msg) do
    Config.get(:show_msg_log)
    |> Kernel.if do
      Logger.info(t_msg |> info_to_string)
      Logger.info("==================================================================")
    end

    t_msg
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
