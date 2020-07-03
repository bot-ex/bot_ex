# BotEx

Bot development core for `Elixir`

# How it works
The core is built using three key concepts:
- updaters - the main task is to receive a message and send it to the handler
- middleware - receive a message and transform it in some way. The first in the chain should implement the behavior `BotEx.Behaviours.MiddlewareParser`, all next - `BotEx.Behaviours.Middleware`
- handlers - process the message and interact with the user. Each handler must implement a behavior `BotEx.Behaviours.Handler`

# Existing libs:
- [telegram](https://github.com/bot-ex/botex-telegram)

# How to start:
  
  ```elixir
  #mix.exs
  def deps do
    [
      {:botex, "~> 0.1"}
    ]
  end

 #full available config reference
 #this values set to default
 config :bot_ex,
    menu_path: "config/menu.exs",
    routes_path: "config/routes.exs",
    default_buffering_time: 3000,
    buffering_strategy: BotEx.Core.Messages.DefaultBufferingStrategy,
    after_start: [],
    show_msg_log: true,
    analytic_key: nil,
    middleware: [],
    handlers: [],
    bots: []
  ```

## Example `config`
```elixir
 config :bot_ex,
    middleware: [
      my_bot: [
        MyBot.Middleware.MessageTransformer,
        MyBot.Middleware.Auth
      ]
    ],
    handlers: [
      my_bot: [
        {MyBot.Handlers.Start, 1000} # {module, buffering time}
      ]
    ],
    bots: [:my_bot]
  ```

```bash
touch config/menu.exs
```

## Example `menu.exs`
```elixir
%{
   "main_menu" => %BotEx.Models.Menu{
     buttons: [
       [
         %BotEx.Models.Button{
           action: "some",
           data: "data",
           module: MyBot.Handlers.Start.get_cmd_name(),
           text: "This is button"
         }
       ]
     ]
   }
 }
```
# Routing
Routes create from defined in config handlers. Each handler have function `get_cmd_name/0` that return command name for this handler. When user call `/start` command, router find module for handle this message by answer `get_cmd_name/0` value.

Optionally you can create file `routes.exs` and redefine or add aliases for your commands

### Example `routes.exs`
```elixir
%{
  :my_bot:
    %{"s" => MyBot.Handlers.Start}
}
```

## Example `Updater`

```elixir
defmodule MyBot.Updaters.MySource do
  @moduledoc false

  use GenServer

  alias BotEx.Routing.MessageHandler

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]},
      type: :worker
    }
  end

  @spec start_link(any) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(state \\ []) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  @spec init(any) :: {:ok, :no_state}
  def init(_opts) do
    cycle()
    {:ok, :no_state}
  end

  defp cycle() do
    Process.send_after(self(), :get_updates, 1000)
  end

  @doc """
  Fetch any messages from your source
  """
  @spec handle_info(:get_updates, map()) :: {:noreply, map()}
  def handle_info(:get_updates, state) do
    # fetch any messages from your source
    msgs = []
    MessageHandler.handle(msgs, :my_bot)
    cycle()
    {:noreply, state}
  end
end
```

## Example `MessageTransformer`

```elixir
defmodule MyBot.Middleware.MessageTransformer do
  @behaviour BotEx.Behaviours.MiddlewareParser

  alias BotEx.Models.Message

  @spec transform({binary(), binary(), binary(), map()}) ::
          Message.t()
  def transform({command, action, text, _user} = msg) do
    %Message{
      msg: msg,
      text: text,
      date_time: Timex.local(),
      module: command,
      action: action,
      data: nil,
      from: :my_bot
    }
  end
end
```
## Example `Middleware`

```elixir
defmodule MyBot.Middleware.Auth do
  @behaviour BotEx.Behaviours.Middleware

  alias BotEx.Models.Message

  @spec transform(Message.t()) :: Message.t()
  def transform(%Message{msg: {__, _, _, %{"id" => id} = user}} = msg) do
    %Message{msg | user: user, user_id: id}
  end
end
```

## Example `Handler`
```elixir
defmodule MyBot.Handlers.Start do
  @moduledoc false

  use BotEx.Handlers.ModuleHandler
  use BotEx.Handlers.ModuleInit

  alias BotEx.Models.Message

  def get_cmd_name, do: "start"

  @doc """
  Message handler
  ## Parameters
  - msg: incoming `BotEx.Models.Message` message.
  """
  @spec handle_message(Message.t()) :: any()
  def handle_message(%Message{chat_id: ch_id}) do
    MyBotApi.send_message(ch_id, "Hello")

    nil
  end
end

```
