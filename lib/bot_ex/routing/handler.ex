defmodule BotEx.Routing.Handler do
  use GenServer
  require Logger

  alias BotEx.Models.Message
  alias BotEx.Behaviours.{MiddlewareParser, Middleware}
  alias BotEx.Config
  alias BotEx.Routing.Router
  alias BotEx.Helpers.Tools
  alias BotEx.Exceptions.BehaviourError
  alias BotEx.Middleware.LastCallUpdater

  defmodule State do
    @typedoc """
    State for `BotEx.Routing.Handler`
    ## Fields:
    - `middlware`: list all possible middlware
    - `message_buffer`: buffering messages
    """
    @type t() :: %__MODULE__{
            middlware: list(),
            message_buffer: map()
          }

    defstruct middlware: [],
              message_buffer: %{}
  end

  @doc """
  Apply middleware modules to messages
  """
  @spec handle(any, any) :: :ok
  def handle(list, type) do
    GenServer.cast(__MODULE__, {type, list})
  end

  @spec init(any) :: {:ok, State.t()}
  def init(_args) do
    middlware =
      Config.get(:middlware)
      |> check_middleware!()

    buffers =
      Config.get(:handlers)
      |> schedule_flush_all(Config.get(:default_buffer_time))
      |> create_buffers()

    {:ok, %State{middlware: middlware, message_buffer: buffers}}
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
  @spec handle_cast({atom(), list()} | :flush_buffer, State.t()) :: {:noreply, State.t()}
  def handle_cast(
        {bot_key, msg_list},
        %State{middlware: all_middlware, message_buffer: old_buffer} = state
      ) do
    [parser | middlware] = Keyword.get(all_middlware, bot_key)

    full_middlware =
      unless LastCallUpdater in middlware do
        middlware ++ [LastCallUpdater]
      else
        middlware
      end

    new_buffer =
      Enum.reduce(msg_list, old_buffer, fn msg, acc ->
        # apply middleware to message and update buuffer
        parser.transform(msg)
        |> call_middlware(full_middlware)
        |> update_buffer(acc)
      end)

    {:noreply, %State{state | message_buffer: new_buffer}}
  end

  @doc """
  Fluhs messages to handlers
  """
  def handle_info({:flush_buffer, bot, handler}, %State{message_buffer: buffer} = state) do
    get_in(buffer, [bot, handler])
    |> Router.send_to_handler()

    Config.get(:handlers)[bot]
    |> Enum.filter(fn h -> elem(h, 0).get_cmd_name() == handler end)
    |> hd()
    |> schedule_buffer_flush(bot, Config.get(:default_buffer_time))

    {:noreply, %State{state | message_buffer: update_in(buffer, [bot, handler], fn _ -> [] end)}}
  end

  def handle_info(_, state) do
    {:noreply, state}
  end

  # create from existings handlers buffers structure
  @spec create_buffers(map()) :: map()
  defp create_buffers(handlers) do
    Enum.reduce(handlers, %{}, fn {bot, hs}, acc ->
      # for each bot handler create structure like
      # %{bot_name: %{"module_cmd" => []}}
      Map.put(
        acc,
        bot,
        Enum.reduce(hs, %{}, fn h, acc2 ->
          Map.put(acc2, elem(h, 0).get_cmd_name(), [])
        end)
      )
    end)
  end

  @spec update_buffer(Message.t(), map()) :: map()
  defp update_buffer(%Message{from: bot, module: handler} = msg, old_buffer),
    do: update_in(old_buffer, [bot, handler], fn old_msgs -> Enum.concat(old_msgs, [msg]) end)

  # scheduling flush all buffers
  @spec schedule_flush_all(map(), integer()) :: map()
  defp schedule_flush_all(handlers, default_buffer_time) do
    Enum.each(handlers, fn {bot, hs} ->
      Enum.each(hs, fn
        h -> schedule_buffer_flush(h, bot, default_buffer_time)
      end)
    end)

    handlers
  end

  # single buffer flush planning
  @spec schedule_buffer_flush(
          {atom(), integer()} | {atom(), integer(), integer()},
          atom(),
          integer()
        ) ::
          reference()
  defp schedule_buffer_flush({h, cnt}, bot, default_buffer_time),
    do: schedule_buffer_flush({h, cnt, default_buffer_time}, bot, default_buffer_time)

  defp schedule_buffer_flush({h, _cnt, time}, bot, _default_buffer_time),
    do: Process.send_after(self(), {:flush_buffer, bot, h.get_cmd_name()}, time)

  # apply middleware modules to one message
  @spec call_middlware(Message.t(), list()) :: Message.t()
  defp call_middlware(%Message{} = msg, []), do: msg

  defp call_middlware(%Message{} = msg, [module | rest]) do
    module.transform(msg)
    |> call_middlware(rest)
  end

  # check middlware modules
  @spec check_middleware!(list()) :: list()
  defp check_middleware!([]) do
    Logger.warn("No middlware was set")
    []
  end

  defp check_middleware!(all) do
    Enum.each(all, fn {_, [parser | middlware]} ->
      unless Tools.is_behaviours?(parser, MiddlewareParser),
        do:
          raise(BehaviourError,
            message: "#{parser} must implement behavior BotEx.Behaviours.MiddlewareParser"
          )

      Enum.each(middlware, fn module ->
        unless Tools.is_behaviours?(module, Middleware),
          do:
            raise(BehaviourError,
              message: "#{module} must implement behavior BotEx.Behaviours.Middleware"
            )
      end)
    end)

    all
  end
end
