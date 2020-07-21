%{
  "main_menu" => %BotEx.Models.Menu{
    buttons: [
      [
        %BotEx.Models.Button{
          action: "some",
          data: "data",
          module: TestBot.Handlers.Start.get_cmd_name(),
          text: "This is button"
        }
      ]
    ]
  }
}
