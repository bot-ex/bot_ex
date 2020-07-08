defmodule TestBot.Handlers.Start do
  @moduledoc false

  use BotEx.Handlers.ModuleHandler

  alias BotEx.Models.Message

  def get_cmd_name, do: "start"

  def handle_message(%Message{text: "test", msg: {_, _, _, _, pid} = msg}) do
    send(pid, msg)
  end

  def handle_message(%Message{action: nil, msg: {_, _, _, _, pid} = msg}) do
    send(pid, msg)
  end
end
