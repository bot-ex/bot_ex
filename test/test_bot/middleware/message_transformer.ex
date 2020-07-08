defmodule TestBot.Middleware.MessaegTransformer do
  @moduledoc """
  Convert telegram message to `BotEx.Models.Message`
  """
  @behaviour BotEx.Behaviours.MiddlewareParser

  alias BotEx.Models.Message

  @spec transform({binary(), binary(), binary(), map()}) ::
          Message.t()
  def transform({command, action, text, _user, _pid} = msg) do
    %Message{
      msg: msg,
      text: text,
      date_time: Timex.local(),
      module: command,
      action: action,
      data: nil,
      from: :test_bot,
      is_cmd: not is_nil(command)
    }
  end
end
