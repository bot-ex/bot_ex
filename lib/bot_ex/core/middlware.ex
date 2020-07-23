defmodule BotEx.Core.Middleware do
  alias BotEx.Models.Message
  alias BotEx.Behaviours.{MiddlewareParser, Middleware}
  alias BotEx.Helpers.Tools
  alias BotEx.Exceptions.BehaviourError
  alias BotEx.Middleware.LastCallUpdater

  require Logger

  @spec apply_to_messages(list(), any) :: [Message.t()]
  def apply_to_messages([parser | middleware], msg_list) do
    msg_list
    |> Enum.map(fn msg ->
      parser.transform(msg)
      |> call_middleware(middleware)
    end)
  end

  # apply middleware modules to one message
  @spec call_middleware(Message.t(), list()) :: Message.t()
  def call_middleware(%Message{} = msg, []), do: msg

  def call_middleware(%Message{} = msg, [module | rest]) do
    module.transform(msg)
    |> call_middleware(rest)
  end

  # check middleware modules
  @spec check_middleware!(list()) :: list() | no_return()
  def check_middleware!([]) do
    # coveralls-ignore-start
    Logger.warn("No middleware was set")
    []
    # coveralls-ignore-stop
  end

  def check_middleware!(all) do
    # coveralls-ignore-start
    Enum.each(all, fn {_, [parser | middleware]} ->
      unless Tools.is_behaviours?(parser, MiddlewareParser),
        do:
          raise(BehaviourError,
            message: "#{parser} must implement behavior BotEx.Behaviours.MiddlewareParser"
          )

      Enum.each(middleware, fn module ->
        unless Tools.is_behaviours?(module, Middleware),
          do:
            raise(BehaviourError,
              message: "#{module} must implement behavior BotEx.Behaviours.Middleware"
            )
      end)
    end)

    # coveralls-ignore-stop
    all
    |> add_last_call_updater()
  end

  @spec add_last_call_updater(list()) :: list()
  defp add_last_call_updater(middleware) do
    Enum.map(middleware, fn {bot, mdl} ->
      all =
        unless LastCallUpdater in mdl do
          mdl ++ [LastCallUpdater]
        else
          # coveralls-ignore-start
          mdl
          # coveralls-ignore-stop
        end

      {bot, all}
    end)
  end
end
