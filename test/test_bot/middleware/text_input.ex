defmodule TestBot.Middleware.TextInput do
  @moduledoc """
    Refresh last calls table
  """

  @behaviour BotEx.Behaviours.Middleware

  alias BotEx.Models.Message
  alias BotEx.Helpers.UserActions

  @spec transform(Message.t()) :: Message.t()
  def transform(%Message{user_id: user_id, text: text, is_cmd: false, msg: msg}) do
    %Message{ UserActions.get_last_call(user_id) | text: text, is_cmd: false, msg: msg }
  end

  def transform(%Message{} = t_msg) do
    t_msg
  end
end
