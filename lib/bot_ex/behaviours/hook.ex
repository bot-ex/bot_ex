defmodule BotEx.Behaviours.Hook do
  @moduledoc """
  Basic behaviour for the Hook module
  """

  @doc """
  Does something at a certain moment
  """
  @callback run() :: any()
end
