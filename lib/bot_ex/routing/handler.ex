defmodule BotEx.Routing.Handler do
  use GenServer
  require Logger

  alias BotEx.Models.Message
  alias BotEx.Behaviours.{MiddlewareParser, Middleware}
  alias BotEx.Config
  alias BotEx.Routing.Router
  alias BotEx.Helpers.Tools
  alias BotEx.Exceptions.BehaviourError

  @doc """
  Apply middleware modules to messages
  """
  @spec handle(any, any) :: :ok
  def handle(list, type) do
    GenServer.cast(__MODULE__, {type, list})
  end

  @spec init(any) :: {:ok, []}
  def init(_args) do
    middlware =
      Config.get(:middlware)
      |> check_middleware!()

    {:ok, middlware}
  end

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]},
      type: :worker
    }
  end

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @doc """
  Apply middleware to incoming messages and routing them to handlers
  ## Parameters
  - {key, list}: key - atom with bot type key,
  list - list incoming `BotEx.Models.Message` messages
  - state: current state
  """
  @spec handle_cast({atom(), list()}, any()) :: {:noreply, any()}
  def handle_cast({key, list}, state) do
    [parser | middlware] = Keyword.get(state, key)

    full_middlware =
      unless BotEx.Middleware.LastCallUpdater in middlware do
        middlware ++ [BotEx.Middleware.LastCallUpdater]
      else
        middlware
      end

    Enum.each(list, fn msg ->
      parser.transform(msg)
      |> call_middlware(full_middlware)
      |> Router.send_to_handler()
    end)

    {:noreply, state}
  end

  #apply middleware modules to one message
  @spec call_middlware(Message.t(), list()) :: Message.t()
  defp call_middlware(%Message{} = msg, []), do: msg

  defp call_middlware(%Message{} = msg, [module | rest]) do
    module.transform(msg)
    |> call_middlware(rest)
  end

  #check middlware modules
  @spec check_middleware!(list()) :: list()
  defp check_middleware!([]) do
    Logger.warn("No middlware was set")
    []
  end

  defp check_middleware!(all) do
    Enum.each(all, fn {_, [parser | middlware]} ->
      unless Tools.is_behaviours?(parser, MiddlewareParser),
        do: raise(BehaviourError, message: "#{parser} must implement behavior BotEx.Behaviours.MiddlewareParser")

      Enum.each(middlware, fn module ->
        unless Tools.is_behaviours?(module, Middleware),
          do: raise(BehaviourError, message: "#{module} must implement behavior BotEx.Behaviours.Middleware")
      end)
    end)

    all
  end
end
