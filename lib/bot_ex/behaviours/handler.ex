defmodule BotEx.Behaviours.Handler do
  @moduledoc """
  Basic behaviour for the Handler module
  """

  alias BotEx.Models.Message

  @doc """
  Sends a message to the handler

  ## Parameters
  - msg: instance of `BotEx.Models.Message`
  """
  @callback send_message(msg :: Message.t) :: Message.t()
end
