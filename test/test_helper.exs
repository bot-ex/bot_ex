config = [
  {:bot_ex,
   show_msg_log: true,
   default_buffering_time: 500,
   menu_path: "test/menu.exs",
   routes_path: "test/routes.exs",
   bots: [:test_bot],
   middleware: [
     test_bot: [
       TestBot.Middleware.MessaegTransformer,
       TestBot.Middleware.Auth,
       TestBot.Middleware.TextInput,
       BotEx.Middleware.MessageLogger
     ]
   ],
   after_start: [TestBot.TestHook],
   handlers: [
     test_bot: [
       {TestBot.Handlers.Start, 100},
       TestBot.Handlers.Stop
     ]
   ]}
]

Application.put_all_env(config)
Application.ensure_all_started(:bot_ex)

TestBot.Updater.start_link()

ExUnit.start()
