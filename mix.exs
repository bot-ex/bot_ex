defmodule BotEx.Mixfile do
  use Mix.Project

  def project do
    [
      app: :bot_ex,
      description: "Bot development core for Elixir",
      version: "0.2.0",
      elixir: "~> 1.9",
      elixirc_paths: elixirc_paths(Mix.env),
      compilers: [:gettext] ++ Mix.compilers,
      start_permanent: Mix.env == :prod,
      aliases: aliases(),
      deps: deps(),
      package: [
        licenses: "MIT",
        homepage_url: "https://github.com/bot-ex"
      ]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {BotEx.Application, []},
      extra_applications: [:logger, :runtime_tools, :timex]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:gettext, "~> 0.17"},
      {:exprintf, "~> 0.2"},
      {:logger_file_backend, "~> 0.0.11"},
      {:timex, "~> 3.6"},
      {:gen_worker, "~> 0.0.5"},
      {:earmark, "~> 1.4", only: :dev},
      {:ex_doc, "~> 0.21", only: :dev},
      {:deep_merge, "~> 1.0"},
      {:jason, "~> 1.1"},
      {:httpoison, "~> 1.6"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      test: ["test"]
    ]
  end
end
