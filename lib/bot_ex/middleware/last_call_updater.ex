defmodule BotEx.Middleware.LastCallUpdater do
  @moduledoc """
    Refresh last calls table
  """

  @behaviour BotEx.Behaviours.Middleware

  alias BotEx.Models.Message
  alias BotEx.Helpers.UserActions

  @spec transform(Message.t()) :: Message.t()
  def transform(%Message{is_cmd: false} = t_msg) do
    t_msg
  end
  
  @doc """
  Save last user message to ets table
  """
  @spec transform(Message.t()) :: Message.t()
  def transform(%Message{user_id: user_id} = t_msg) do
    UserActions.update_last_call(user_id, t_msg)

    t_msg
  end
end
