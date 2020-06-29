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
      @impl true
      @spec get_cmd_name() :: any()
      def get_cmd_name() do
        raise(BehaviourError,
          message: "Behaviour function #{__MODULE__}.get_cmd_name/0 is not implemented!"
        )
      end

      @impl true
      @spec handle_message(Message.t()) :: any() | no_return()
      def handle_message(_a) do
        raise(BehaviourError,
          message: "Behaviour function #{__MODULE__}.handle_message/1 is not implemented!"
        )
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

      defoverridable handle_message: 1
      defoverridable get_cmd_name: 0
    end
  end
end
