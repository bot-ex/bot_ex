defmodule BotEx.Behaviours.MiddlewareParser do
  @moduledoc """
  The behaviour for the inbox transformation module
  """
  # coveralls-ignore-start
  alias BotEx.Models.Message

  @doc """
  Transforms the original message into `BotEx.Models.Message`
  ## Parameters
  - msg: any message from outer service
  """
  @callback transform(msg :: any()) :: Message.t()
  # coveralls-ignore-stop
end
