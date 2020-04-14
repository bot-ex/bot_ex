defmodule BotEx.Behaviours.Handler do
  @moduledoc """
  Basic behaviour for the Handler module
  """

  alias BotEx.Models.Message

  @doc """
  Send message to the worker
  ## Parameters
  - info: message `BotEx.Models.Message` for sending
  return `BotEx.Models.Message`
  """
  @callback send_message(msg :: Message.t) :: Message.t()

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
  @callback handle_message(msg :: Message.t(), state :: any()) :: any() | no_return()
end
