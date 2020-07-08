defmodule TestBot.Updater do
  @moduledoc false

  use GenServer

  alias BotEx.Routing.MessageHandler

  def send_message(msg) do
    GenServer.call(__MODULE__, msg)
  end

  @spec start_link(any) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(state \\ []) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  @spec init(any) :: {:ok, :no_state}
  def init(_opts) do
    {:ok, :no_state}
  end

  def handle_call(msg, _from, state) do
    msgs = [msg]
    MessageHandler.handle(msgs, :test_bot)
    {:reply, :ok, state}
  end
end
