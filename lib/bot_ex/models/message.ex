defmodule BotEx.Models.Message do
  @typedoc """
  Module, that represents message wrapper struct

  ##
  - `is_cmd`: is it a command or not,
  - `module`: the name of the module that will be called must match the result of `BotEx.Handlers.ModuleHandler.get_cmd_name/0`,
  - `action`: action,
  - `data`: data,
  - `msg`: original message
  - `user`: current user
  - `user_id`: user id
  - `text`: message text, if any
  - `force_new`:- report that editing the message is undesirable
  - `chat_id`:- chat id
  - `custom_data`:- any additional data
  """
  @type t() :: %__MODULE__{
          is_cmd: boolean(),
          module: binary(),
          action: binary(),
          data: binary(),
          msg: any(),
          user: any(),
          user_id: integer(),
          text: binary(),
          date_time: any(),
          force_new: boolean(),
          chat_id: integer(),
          custom_data: any(),
          from: atom()
        }

  defstruct is_cmd: false,
            module: nil,
            action: nil,
            data: nil,
            msg: nil,
            user: nil,
            user_id: nil,
            text: nil,
            date_time: nil,
            force_new: false,
            chat_id: nil,
            custom_data: nil,
            from: nil
end
