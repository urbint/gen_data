defmodule GenData.Mixfile do
  use Mix.Project

  def project do
    [app: :gen_data,
     version: "0.1.0",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps(),
     dialyzer: [ignore_warnings: "./.dialyzer-ignore-warnings.txt"]]
  end


  def application do
    [extra_applications: [:logger]]
  end


  defp deps do
    [
      {:cortex, "~> 0.4", only: [:test, :dev], runtime: !ci_build?()},
      {:shorter_maps, "~> 2.1"},
      {:credo, "~> 0.8", only: [:dev, :test]},
      {:dialyxir, "~> 0.5", only: [:dev], runtime: false},
      {:ex_doc, ">= 0.0.0", only: [:dev]},
      {:ex_dash, "~> 0.1", only: [:dev]},
    ]
  end

  defp ci_build?, do: System.get_env("CI") != nil
end
