defmodule TestBot.Handlers.Stop do
  @moduledoc false

  use BotEx.Handlers.ModuleHandler

  alias BotEx.Models.Message

  def get_cmd_name, do: "stop"

  def handle_message(%Message{msg: {_, _, _, _, pid} = msg}) do
    send(pid, msg)
  end
end
