defmodule BotEx.Handlers.ModuleInit do
  @moduledoc """
  A simple macro to initialize a GenServer.
  Takes the current state structure as an argument
  Example
  ```elixir
  use BotEx.Handlers.ModuleInit, state: [menu: []]
  ```
  """

  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts], location: :keep do
      defmodule State do
        defstruct opts[:state] || []
      end

      @doc """
      Module init
      """
      def init(_opts), do: {:ok, %State{}}

      defoverridable init: 1
    end
  end
end
