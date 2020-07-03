defmodule BotEx.Behaviours.BufferingStrategy do
  @moduledoc """
  The behaviour for a module that implements a message buffering strategy
  """

  alias BotEx.Models.Message

  @doc """
  This function calling on start `BotEx.Routing.MessageHandler`
  and must return struct for saving incoming messages

  ## Parameters
  - handlers: handlers map as in config parameter handlers
  return buffer struct
  """
  @callback create_buffers(handlers :: map()) :: map()

  @doc """
  This function calling on receive new messages and must
  put it on them a place in buffer struct from `create_buffers`

  ## Parameters
  - msg_list: list of new messages
  - current_buffer: buffer with messages

  return new buffer with added messages
  """
  @callback update_buffers_from_messages(msg_list :: [Message.t(), ...], current_buffer :: map()) ::
              map()

  @doc """
  This function calling on start `BotEx.Routing.MessageHandler`
  and create a plan for flush all buffers from `create_buffers`

  ## Parameters:
  - handlers: map of handlers as in config
  - default_buffering_time: default buffering time from config, can be replaced for the handler
  - handler_pid: pid of `BotEx.Routing.MessageHandler`

  return handlers map
  """
  @callback schedule_flush_all(
              handlers :: map(),
              default_buffering_time :: integer(),
              handler_pid :: pid()
            ) :: map()

  @doc """
  This function call on one buffer flushing
  for  planning next buffer flush. Must send `{:flush_buffer, bot, handler}` message to `handler_pid`

  ## Parameters:
  - key: any key for get value from buffer
  - buffering_time: buffering time
  - handler_pid: pid of `BotEx.Routing.MessageHandler`

  return reference from `Process.send_after`
  """
  @callback schedule_buffer_flush(
              key :: any(),
              buffering_time :: integer(),
              handler_pid :: pid()
            ) ::
              reference()

  @doc """
  Return messages for send from buffer

  ## Parameters:
  - buffer: current buffer
  - key: any key for getting messages from buffer

  return list of messages for sending
  """
  @callback get_messages(buffer :: map(), key :: any()) :: [
              Message.t(),
              ...
            ]

  @doc """
  Reset buffer values by key

  ## Parameters:
  - buffer: current buffer
  - key: any key for delete messages from buffer
  """
  @callback reset_buffer(buffer :: map(), key :: any()) :: map()
end
