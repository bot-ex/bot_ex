defmodule BotEx.Core.Messages.DefaultBufferingStrategy do
  @moduledoc """
  This module buffering messages for each handler of bot
  """
  @behaviour BotEx.Behaviours.BufferingStrategy

  require Logger
  alias BotEx.Models.Message
  alias BotEx.Config
  import BotEx.Helpers.Debug, only: [print_debug: 1]

  # create from existings handlers buffers structure
  @impl true
  def create_buffers(handlers) do
    Map.new(handlers, fn {bot, hs} ->
      # for each bot handler create structure like
      # %{bot_name: %{"module_cmd" => []}}
      {bot, Map.new(hs, &put_handler_in_buffer/1)}
    end)
  end

  @impl true
  def update_buffers_from_messages(msg_list, current_buffer) do
    Enum.reduce(msg_list, current_buffer, &update_buffer/2)
  end

  # scheduling flush all buffers
  @impl true
  def schedule_flush_all(handlers, default_buffering_time, handler_pid) do
    Enum.each(handlers, fn {bot, hs} ->
      Enum.each(hs, &schedule_buffer_flush(&1, bot, default_buffering_time, handler_pid))
    end)

    handlers
  end

  # single buffer flush planning
  @impl true
  def schedule_buffer_flush([bot, handler], default_buffering_time, handler_pid) do
    find_handler_by_name(bot, handler)
    |> schedule_buffer_flush(bot, default_buffering_time, handler_pid)
  end

  @spec schedule_buffer_flush(
          {module(), integer()} | module(),
          atom(),
          integer(),
          pid()
        ) :: reference
  def schedule_buffer_flush({h, time}, bot, _default_buffering_time, handler_pid),
    do: Process.send_after(handler_pid, {:flush_buffer, [bot, h.get_cmd_name()]}, time)

  def schedule_buffer_flush(h, bot, default_buffering_time, handler_pid) when is_atom(h),
    do:
      schedule_buffer_flush({h, default_buffering_time}, bot, default_buffering_time, handler_pid)

  @impl true
  def get_messages(buffer, key), do: get_in(buffer, key)

  @impl true
  def reset_buffer(buffer, key), do: put_in(buffer, key, [])

  @spec put_handler_in_buffer({atom(), integer()} | atom() | any()) :: tuple()
  defp put_handler_in_buffer({h, _time}), do: {h.get_cmd_name(), []}

  defp put_handler_in_buffer(h) when is_atom(h), do: {h.get_cmd_name(), []}

  # coveralls-ignore-start
  defp put_handler_in_buffer(h) do
    Logger.warning("Unsupported type #{inspect(h)}")
  end

  # coveralls-ignore-stop

  @spec update_buffer(Message.t() | atom(), map()) :: map()
  defp update_buffer(:ignore, old_buffer), do: old_buffer

  defp update_buffer(%Message{from: bot, module: handler} = msg, old_buffer),
    do:
      update_in(old_buffer, [bot, handler], fn
        old_msgs when is_list(old_msgs) ->
          print_debug("Add message to buffer. Bot: #{bot} handler: #{handler}")
          Enum.concat(old_msgs, [msg])

        error ->
          Logger.warning("Can not add message to \"#{error}\" buffer")
      end)

  @spec find_handler_by_name(atom(), String.t()) :: module()
  defp find_handler_by_name(bot, name) do
    Config.get(:handlers)[bot]
    |> Enum.filter(fn
      {h, _time} ->
        h.get_cmd_name() == name

      h when is_atom(h) ->
        h.get_cmd_name() == name

      # coveralls-ignore-start
      e ->
        Logger.warning("Unsupported type #{inspect(e)}")
        false
        # coveralls-ignore-stop
    end)
    |> hd()
  end
end
