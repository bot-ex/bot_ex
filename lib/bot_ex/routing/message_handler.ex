defmodule BotEx.Routing.MessageHandler do
  use GenServer
  require Logger

  alias BotEx.Config
  alias BotEx.Routing.Router
  alias BotEx.Core.Middleware
  alias BotEx.Helpers.Tools
  alias BotEx.Behaviours.BufferingStrategy

  defmodule State do
    @typedoc """
    State for `BotEx.Routing.MessageHandler`
    ## Fields:
    - `middleware`: list all possible middleware
    - `message_buffer`: buffering messages
    - `default_buffering_time`: time buffering messages
    - `buffering_strategy`: strategy for buffering messages. Must implements `BotEx.Behaviours.BufferingStrategy`
    """
    @type t() :: %__MODULE__{
            middleware: list(),
            message_buffer: map(),
            default_buffering_time: integer(),
            default_buffering_time: module()
          }

    defstruct middleware: [],
              message_buffer: %{},
              default_buffering_time: nil,
              buffering_strategy: nil
  end

  @doc """
  Apply middleware modules to messages
  """
  @spec handle(any, any) :: :ok
  def handle(msg_list, bot_key) do
    GenServer.cast(__MODULE__, {bot_key, msg_list})
  end

  @spec init(any) :: {:ok, State.t()}
  def init(_args) do
    middleware =
      Config.get(:middleware)
      |> Middleware.check_middleware!()

    default_buffering_time = Config.get(:default_buffering_time)

    buffering_strategy =
      Config.get(:buffering_strategy)
      |> Tools.check_behaviours!(BufferingStrategy)

    buffers =
      Config.get(:handlers)
      |> buffering_strategy.schedule_flush_all(default_buffering_time, self())
      |> buffering_strategy.create_buffers()

    {:ok,
     %State{
       middleware: middleware,
       message_buffer: buffers,
       default_buffering_time: default_buffering_time,
       buffering_strategy: buffering_strategy
     }}
  end

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]},
      type: :worker
    }
  end

  @spec start_link(any) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @doc """
  Apply middleware to incoming messages and buffering them
  ## Parameters
  - {bot_key, msg_list}: bot_key - atom with bot key,
  list - list incoming `BotEx.Models.Message` messages
  - state: current state
  """
  @spec handle_cast({atom(), list()}, State.t()) :: {:noreply, State.t()}
  def handle_cast(
        {bot_key, msg_list},
        %State{
          middleware: all_middleware,
          message_buffer: old_buffer,
          buffering_strategy: buffering_strategy
        } = state
      ) do
    new_buffer =
      Keyword.get(all_middleware, bot_key)
      |> Middleware.apply_to_messages(msg_list)
      |> buffering_strategy.update_buffers_from_messages(old_buffer)

    {:noreply, %State{state | message_buffer: new_buffer}}
  end

  @doc """
  Fluhs messages to handlers
  """
  @spec handle_info({:flush_buffer, any()}, State.t()) ::
          {:noreply, State.t()}
  def handle_info(
        {:flush_buffer, key},
        %State{
          message_buffer: buffer,
          default_buffering_time: default_buffering_time,
          buffering_strategy: buffering_strategy
        } = state
      ) do
    buffering_strategy.get_messages(buffer, key)
    |> Router.send_to_handler()

    buffering_strategy.schedule_buffer_flush(key, default_buffering_time, self())

    {:noreply, %State{state | message_buffer: buffering_strategy.reset_buffer(buffer, key)}}
  end
end
