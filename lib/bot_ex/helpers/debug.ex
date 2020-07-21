defmodule BotEx.Helpers.Debug do
  require Logger
  alias BotEx.Config

  @doc """
  Print debug message if it enabled in config
  """
  @spec print_debug(any) :: nil | :ok
  def print_debug(message) do
    Config.get(:show_msg_log)
    |> do_print(message)
  end

  # coveralls-ignore-start
  defp do_print(true = _enable, message) when is_binary(message), do: Logger.debug(message)
  defp do_print(true = _enable, message), do: Logger.debug(inspect(message))
  defp do_print(_, _message), do: nil
  # coveralls-ignore-stop
end
