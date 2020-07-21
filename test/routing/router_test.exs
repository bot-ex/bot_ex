defmodule RouterTest do
  use ExUnit.Case

  alias BotEx.Config

  test "test reset routes" do
    old_routes = Config.get(:routes)
    old_path = Config.get(:routes_path)

    Application.stop(:bot_ex)
    Application.start(:bot_ex)

    Config.put(:routes, [])
    Config.put(:routes_path, "/not/exists")

    msg = {"start", nil, nil, %{"id" => 1}, self()}

    TestBot.Updater.send_message(msg)
    assert_receive msg, 1100

    Application.stop(:bot_ex)
    Application.start(:bot_ex)

    Config.put(:routes, old_routes)
    Config.put(:routes_path, old_path)
  end
end
