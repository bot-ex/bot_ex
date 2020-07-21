defmodule BotEx.Behaviours.GroupingStrategy do
  @moduledoc """
  The behaviour for a module that implements a message buffering strategy
  """
  alias BotEx.Models.Message

  @doc """
  This function uses `BotEx.Routing.Router` for grouping messages by some parameters
  """
  @callback group_and_send(msgs :: [Message.t(), ...]) :: :ok
end
