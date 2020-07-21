defmodule ConfigTest do
  use ExUnit.Case
  alias BotEx.Config


  test "get from config" do
    assert "test/menu.exs" == Config.get(:menu_path)
  end

  test "put in config" do
    Config.put(:test_key, "test value")
    assert "test value" == Config.get(:test_key)
  end
end
