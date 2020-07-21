defmodule TestBot.Middleware.Auth do
  @behaviour BotEx.Behaviours.Middleware

  alias BotEx.Models.Message

  @spec transform(Message.t()) :: Message.t()
  def transform(%Message{msg: {__, _, _, %{"id" => id} = user, _pid}} = msg) do
    %Message{msg | user: user, user_id: id}
  end
end
