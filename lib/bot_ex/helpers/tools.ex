defmodule BotEx.Helpers.Tools do
  @moduledoc """
  Secondary functions
  """

  alias BotEx.Exceptions.ConfigError

  @doc """
  Checks the behavior is implemented by module
  ## Parameters
  - module: module for checking
  - behaviour: behaviour for checking
  """
  @spec is_behaviours?(atom() | %{module_info: nil | keyword() | map()}, any()) :: boolean()
  def is_behaviours?(module, behaviour) do
    module.module_info[:attributes]
    |> Keyword.get_values(:behaviour)
    |> List.flatten()
    |> Enum.member?(behaviour)
  end

  @doc """
  Checked if the file exists at the given path
  ## Parameters
  - path: file path in any valid format for `File.exists?/1`
  """
  @spec check_path!(nil | Path.t()) :: binary() | no_return()
  def check_path!(nil), do: raise(ConfigError, message: "Path not set")

  def check_path!(path) do
    if File.exists?(path) do
      path
    else
      raise(ConfigError, message: "File '#{path}' not exists")
    end
  end
end
