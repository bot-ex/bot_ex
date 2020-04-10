defmodule BotEx.Updaters.LogRotate do
  @moduledoc """
  Log rotator.
  Since it is not possible to dynamically change the date of the log.
  This module backup the current log once a day
  """

  use GenWorker,
    run_at: [hour: 0, minute: 0, second: 1],
    run_each: [days: 1],
    timezone: "Europe/Moscow"

  require Logger

  @log_config Application.get_env(:logger, :error_log)

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]},
      type: :worker
    }
  end

  def run(_args) do
    logFile = @log_config[:path]

    if(File.exists?(logFile)) do
      dir = Path.dirname(logFile)
      newFile = "#{dir}/#{Date.utc_today()}_elixir_dbg.log"
      File.rename(logFile, newFile)

      zipFile = '#{newFile}'
      zipName = '#{newFile}.zip'

      case :zip.create(zipName, [zipFile]) do
        {:ok, _f} -> File.rm!(newFile)
        error -> Logger.error("Can not create zip from log #{newFile} #{inspect(error)}")
      end
    end
  end
end
