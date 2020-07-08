defmodule HandlerTest do
  use ExUnit.Case

  alias BotEx.Helpers.UserActions
  alias BotEx.Models.Message

  setup do
    on_exit(fn ->
      :ets.delete_all_objects(:last_call)
    end)
  end

  test "check send message with selected time" do
    msg = {"start", nil, nil, %{"id" => 1}, self()}

    TestBot.Updater.send_message(msg)
    assert_receive msg, 1100
  end

  test "check send message with default time" do
    msg = {"stop", nil, nil, %{"id" => 1}, self()}

    TestBot.Updater.send_message(msg)
    assert_receive msg, 600
  end

  test "check send text message" do
    msg = {"start", nil, nil, %{"id" => 1}, self()}

    TestBot.Updater.send_message(msg)
    assert_receive msg, 1100

    msg = {nil, nil, "test", %{"id" => 1}, self()}
    TestBot.Updater.send_message(msg)
    assert_receive msg, 1100
  end

  test "check change handler" do
    msg = {"start", nil, nil, %{"id" => 1}, self()}

    TestBot.Updater.send_message(msg)
    assert_receive msg, 1100

    old = UserActions.get_last_call(1)
    assert %Message{module: "start", action: nil, data: nil} = old

    TestBot.Handlers.Start.change_handler(%Message{old | module: "stop"})
    assert %Message{module: "stop", action: nil, data: nil} = UserActions.get_last_call(1)
  end

  test "check binary id" do
    msg = {"start", nil, nil, %{"id" => "1"}, self()}

    TestBot.Updater.send_message(msg)
    assert_receive msg, 1100
  end

  test "check not exists route" do
    msg = {"not exists", nil, nil, %{"id" => "1"}, self()}

    TestBot.Updater.send_message(msg)
    refute_receive _, 1100
  end
end
