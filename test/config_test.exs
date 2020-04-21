defmodule Test.Middleware.ShortCmdTest do
  use ExUnit.Case

  alias BotEx.Middleware.ShortCmd
  alias BotEx.Models.Message
  alias BotEx.Config
  
  doctest BotEx.Middleware.ShortCmd
  
  setup do
    Config.put(:shorts, %{:telegram => %{"txt" => {"module", "action"}}})
  end


  test "correct msg transform" do
    in_msg = %Message{text: "txt", from: :telegram, is_cmd: false}
    out_msg = %Message{text: "txt", from: :telegram, module: "module", action: "action", is_cmd: true}

    assert ShortCmd.transform(in_msg) == out_msg
  end

  test "no msg transform" do
    in_msg = %Message{text: "no_match", from: :telegram}
    out_msg = %Message{text: "no_match", from: :telegram}

    assert ShortCmd.transform(in_msg) == out_msg
  end
end
