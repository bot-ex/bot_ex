defmodule BotEx.Behaviours.Middleware do
  @moduledoc """
  Behaviour for a module that changes the contents of `BotEx.Models.Message`
  """
  # coveralls-ignore-start
  alias BotEx.Models.Message

  @doc """
  Changes the contents of `BotEx.Models.Message`
  ## Parameters
  - msg: `BotEx.Models.Message` from `MiddlewareParser` or other `Middleware`
  """
  @callback transform(Message.t()) :: Message.t() | atom()
  # coveralls-ignore-stop
end
