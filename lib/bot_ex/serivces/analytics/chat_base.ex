defmodule BotEx.Services.Analytics.ChatBase do
  @moduledoc """
  Analytics Gathering Module
  """

  require Logger

  alias BotEx.Config
  alias BotEx.Exceptions.ConfigError

  @doc """
  Sends information to analytics collection service
  more details about the parameters can be found
  in [documentation](https://chatbase.com/documentation/docs-overview)
  ## Parameters
  - msg: message
  - user_id: user id
  - intent: intent
  - platform: platform
  """
  @spec send_data(binary(), binary() | integer(), binary(), binary()) :: boolean()
  def send_data(msg, user_id, intent, platform) do
    try do
      api_key = get_api_key!()

      HTTPoison.post!(
        "https://chatbase.com/api/message",
        Jason.encode!(%{
          "api_key" => api_key,
          "type" => "user",
          "platform" => platform,
          "message" => msg,
          "intent" => intent,
          "version" => "1.0",
          "user_id" => user_id,
          "time_stamp" => :os.system_time(:millisecond)
        }),
        [
          {"Content-Type", "application/json"},
          {"cache-control", "no-cache"}
        ],
        timeout: 1000,
        recv_timeout: 1000
      )

      true
    rescue
      e in _ ->
        Logger.error("send error: #{inspect(e)}")
        false
    end
  end

  # return api key from config
  defp get_api_key!() do
    key = Config.get(:analytic_key)

    unless is_binary(key) do
      raise(ConfigError,
        message:
          "You should define a binary key in configuration (:key), to use this module, like:\n" <>
            "config :bot_ex, analytic_key: key"
      )
    end
  end
end
