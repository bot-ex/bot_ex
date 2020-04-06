defmodule BotEx.Models.Menu do
  @moduledoc """
  Menu.

  - `name`: menu unique identifier,
  - `text`: menu text,
  - `buttons`: list of buttons `BotEx.Models.Button`  or a function that returns list of buttons
  - `custom`: any data
  """

  @type t() :: %__MODULE__{
          name: binary(),
          text: nil | binary(),
          buttons: [BotEx.Models.Button.t(), ...] | function(),
          custom: any()
        }

  defstruct name: nil,
            text: nil,
            buttons: [],
            custom: nil
end
