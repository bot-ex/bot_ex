defmodule BotEx.Core.Messages.DefaultGroupingStrategy do
  @moduledoc """
    Module grouping messages by fields: user, module and bot
  """

  @behaviour BotEx.Behaviours.GroupingStrategy

  alias BotEx.Models.Message
  alias BotEx.Routing.Router

  @impl true
  def group_and_send(msgs) do
    msgs
    |> Enum.group_by(fn %Message{user_id: user, module: module, from: bot} ->
      {user, module, bot}
    end)
    |> Enum.each(fn {{_user, module, bot}, list} ->
      Router.handle_msgs(module, bot, list)
    end)
  end
end
