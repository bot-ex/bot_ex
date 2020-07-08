defmodule BotEx.Helpers.UserActions do
  @moduledoc """
  User actions interacting functions
  """

  alias BotEx.Models.Message

  @doc """
  Find the last user action
  ## Parameters:
  - u_id: user id
  """
  @spec get_last_call(integer | binary) :: Message.t()
  def get_last_call(u_id) when is_binary(u_id), do: String.to_integer(u_id) |> get_last_call()
  def get_last_call(u_id) when is_integer(u_id) do
    case :ets.lookup(:last_call, u_id) do
      [] -> %Message{}
      [{_, msg}] -> msg
    end
  end

  @doc """
  Update last user message
  ## Parameters:
  - user_id: user id
  - call: `BotEx.Models.Message` for saving
  """
  @spec update_last_call(user_id :: integer() | binary(), call :: Message.t()) :: :true
  def update_last_call(user_id, call) when is_binary(user_id), do: String.to_integer(user_id) |> update_last_call(call)
  def update_last_call(user_id, %Message{} = call), do: :ets.insert(:last_call, {user_id, call})
end
