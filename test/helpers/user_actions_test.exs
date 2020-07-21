defmodule UserActionsTest do
  use ExUnit.Case

  alias BotEx.Helpers.UserActions
  alias BotEx.Models.Message

  test "user id is binary" do
    assert %Message{} == UserActions.get_last_call("1")
  end
end
