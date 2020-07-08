defmodule BotEx.Behaviours.Hook do
  @moduledoc """
  Basic behaviour for the Hook module
  """
  # coveralls-ignore-start
  @doc """
  Does something at a certain moment
  """
  @callback run() :: any()
  # coveralls-ignore-stop
end
