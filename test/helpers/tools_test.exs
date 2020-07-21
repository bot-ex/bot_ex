defmodule ToolsTest do
  use ExUnit.Case

  alias BotEx.Helpers.Tools
  alias BotEx.Exceptions.{BehaviourError, ConfigError}

  test "not implemented behaviour" do
    assert_raise BehaviourError, fn ->
      Tools.check_behaviours!(TestBot.Handlers.Start, BotEx.Behaviours.Hook)
    end
  end

  test "not exists path" do
    assert_raise ConfigError, fn ->
      Tools.check_path!("/not/exists")
    end
  end

  test "path is nil" do
    assert_raise ConfigError, fn ->
      Tools.check_path!(nil)
    end
  end

  test "exists path" do
    assert Tools.check_path!("test") == "test"
  end
end
