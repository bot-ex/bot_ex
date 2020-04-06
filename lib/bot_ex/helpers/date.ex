defmodule BotEx.Helpers.Date do
  @moduledoc """
  Date formatting functions
  """

  @default_date_format "{0D}.{0M}.{YYYY}, {h24}:{m}"

  @doc """
  returns current date in @default_date_format
  ## Parameters
  - format: any string format fot `Timex.format!/1`
  """
  @spec get_current_date_as_string!(binary) :: binary
  def get_current_date_as_string!(format \\ @default_date_format) do
    Timex.local() |> Timex.format!(format)
  end
end
