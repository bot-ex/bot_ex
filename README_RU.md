# BotEx

Ядро для разработки ботов на `Elixir`

# Существующие библиотеки:
  - [telegram](https://github.com/bot-ex/botex-telegram) 

# Как это работает
Ядро построено с использованием трёх ключевых концепций:
- updaters - основная задача получить сообщение и, отправить его обработчику
- middleware - получают сообщение и каким-либо образом трансформируют его. Первый в цепочке должен реализовывать поведение `BotEx.Behaviours.MiddlewareParser`, последующие - `BotEx.Behaviours.Middleware`
- handlers - обрабатывают сообщение и взаимодействуют с пользователем. Каждый обработчик должен реализовывать поведение `BotEx.Behaviours.Handler`

# Быстрый старт:
  
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
    bots: [],
    handlers: []
  ```

## Пример конфига

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
        {MyBot.Handlers.Start, 1000} # {модуль, время буферизации сообщений}
      ]
    ],
    bots: [:my_bot]
  ```

```bash
touch config/menu.exs
```

## Пример `menu.exs`
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
# Маршрутизация
Маршруты создаются из определенных в конфигах обработчиков. Каждый обработчик имеет функцию `get_cmd_name/0`, которая возвращает имя команды для этого обработчика. Когда пользователь вызывает команду `/start`, маршрутизатор находит модуль для обработки этого сообщения по значению ответа` get_cmd_name/0`.

При желании вы можете создать файл "routes.exs` и переопределить или добавить псевдонимы для ваших команд

### Example `routes.exs`
```elixir
%{
  :my_bot:
    %{"s" => MyBot.Handlers.Start}
}
```

## Пример `Updater`

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
  Функция извлекает данные из источника
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

## Пример `MessageTransformer`

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
      data: nil
    }
  end
end
```
## Пример `Middleware`

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

## Пример `Handler`
```elixir
defmodule MyBot.Handlers.Start do
  @moduledoc false

  use BotEx.Handlers.ModuleHandler
  use BotEx.Handlers.ModuleInit

  alias BotEx.Models.Message

  def get_cmd_name, do: "start"

  @doc """
  Асинхронный обработчик сообщений модуля

  ## Параметры

  - `Message`: обработанное сообщение от бота
  """
  @spec handle_message(Message.t()) :: any()
  def handle_message(%Message{chat_id: ch_id}) do
    MyBotApi.send_message(ch_id, "Hello")

    nil
  end
end

```
