defmodule FinancialSystem.Mixfile do
  use Mix.Project

  def project do
    [
      app: :financial_system,
      version: "0.1.0",
      elixir: "~> 1.8",
      start_permanent: Mix.env == :prod,
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [coveralls: :test]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:dialyxir, "~> 0.5", only: [:dev]},
      {:excoveralls, "~> 0.10", only: [:test]}
    ]
  end
end
