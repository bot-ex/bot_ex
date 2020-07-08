defmodule TestBot.TestHook do
  @moduledoc false

  @behaviour BotEx.Behaviours.Hook
  import BotEx.Helpers.Debug, only: [print_debug: 1]

  def run() do
    print_debug("run hook")
  end
end
