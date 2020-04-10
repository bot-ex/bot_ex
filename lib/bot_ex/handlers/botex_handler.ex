defmodule BotEx.Handlers.ModuleHandler do
  @moduledoc """
  The base macro that all message handlers should implement
  """

  defmacro __using__(_opts) do
    quote do
      @behaviour BotEx.Behaviours.Handler

      alias BotEx.Models.Message
      alias BotEx.Helpers.UserActions
      alias BotEx.Exceptions.BehaviourError

      @doc """
      Returns a command is responsible for module processing
      """
      @spec get_cmd_name() :: any()
      def get_cmd_name() do
        raise(BehaviourError, message: "Behaviour function #{__MODULE__}.get_cmd_name/0 is not implemented!")
      end

      def child_spec(opts) do
        %{
          id: __MODULE__,
          start: {__MODULE__, :start_link, [opts]},
          type: :worker
        }
      end

      @doc """
      Asynchronous message handler
      ## Parameters
      - msg: incoming `BotEx.Models.Message` message
      - state: current state
      """
      @spec handle_cast(msg :: Message.t(), state :: any()) :: {:noreply, any()}
      def handle_cast(msg, state) do
        new_state = handle_message(msg, state)

        :poolboy.checkin(__MODULE__, self())
        {:noreply, new_state}
      end

      @doc """
      Message handler
      ## Parameters
      - msg: incoming `BotEx.Models.Message` message.
      - state: current state
      return new state
      """
      def handle_message(_a, _b) do
        raise(BehaviourError, message: "Behaviour function #{__MODULE__}.handle_message/2 is not implemented!")
      end

      def start_link(_) do
        GenServer.start_link(__MODULE__, [])
      end

      @doc """
      Send message to the worker
      ## Parameters
      - info: message `BotEx.Models.Message` for sending
      return `BotEx.Models.Message`
      """
      @spec send_message(Message.t()) :: Message.t()
      def send_message(info) do
        :poolboy.checkout(__MODULE__) |> GenServer.cast(info)

        info
      end

      @doc """
      Changes the current message handler
      ## Parameters
      - msg: message `BotEx.Models.Message`
      """
      @spec change_handler(Message.t()) :: true
      def change_handler(%Message{
            user_id: u_id,
            module: module,
            is_cmd: is_cmd,
            action: action,
            data: data
          }) do
        tMsg = UserActions.get_last_call(u_id)

        n_t_msg = %Message{
          tMsg
          | module: module,
            is_cmd: is_cmd,
            action: action,
            data: data
        }

        UserActions.update_last_call(u_id, n_t_msg)
      end

      defoverridable handle_message: 2
      defoverridable get_cmd_name: 0
    end
  end
end
