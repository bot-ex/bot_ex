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
    - `buffer_time`: time for buffering messages
    - `buffer`: buffering messages
    """
    @type t() :: %__MODULE__{
            middlware: list(),
            buffer_time: integer(),
            buffer: list()
          }

    defstruct middlware: [],
              buffer_time: nil,
              buffer: []
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

    buffer_time = Config.get(:buffer_time)
    Process.send_after(self(), :flush_buffer, buffer_time)

    {:ok, %State{middlware: middlware, buffer_time: buffer_time}}
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
  - {key, list}: key - atom with bot type key,
  list - list incoming `BotEx.Models.Message` messages
  - state: current state
  """
  @spec handle_cast({atom(), list()} | :flush_buffer, State.t()) :: {:noreply, State.t()}
  def handle_cast({key, list}, %State{middlware: all_middlware, buffer: old_buffer} = state) do
    [parser | middlware] = Keyword.get(all_middlware, key)

    full_middlware =
      unless LastCallUpdater in middlware do
        middlware ++ [LastCallUpdater]
      else
        middlware
      end

    handled =
      Enum.map(list, fn msg ->
        parser.transform(msg)
        |> call_middlware(full_middlware)
      end)

    {:noreply, %State{state | buffer: Enum.concat(old_buffer, handled)}}
  end

  @doc """
  Fluhs messages to handlers
  """
  def handle_cast(:flush_buffer, %State{buffer: buffer, buffer_time: buffer_time} = state) do
    buffer |> Router.send_to_handler()
    Process.send_after(self(), :flush_buffer, buffer_time)

    {:noreply, %State{state | buffer: []}}
  end

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
