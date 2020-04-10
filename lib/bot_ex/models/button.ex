defmodule BotEx.Models.Button do
  @typedoc """
  Module, that represents menu button struct.
  ## Fields:
  - `text`: visible text,
  - `module`: call module,
  - `action`: action,
  - `data`: some data
  """
  @type t() :: %__MODULE__{
          text: nil | binary(),
          module: nil | binary(),
          action: nil | binary(),
          data: nil | binary()
        }

  defstruct text: nil,
            module: nil,
            action: nil,
            data: nil
end
