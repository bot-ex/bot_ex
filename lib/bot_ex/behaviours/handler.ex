defmodule BotEx.Behaviours.Handler do
  @moduledoc """
  Basic behaviour for the Handler module
  """
  # coveralls-ignore-start
  alias BotEx.Models.Message

  @doc """
  Returns a command is responsible for module processing
  """
  @callback get_cmd_name() :: any() | no_return()

  @doc """
  Message handler
  ## Parameters
  - msg: incoming `BotEx.Models.Message` message.
  - state: current state
  return new state
  """
  @callback handle_message(Message.t()) :: any() | no_return()
  # coveralls-ignore-stop
end
