defmodule Ocjb.Mixfile do
  use Mix.Project

  def project do
    [app: :ocjb,
     version: "0.0.1",
     elixir: "~> 1.2",
     elixirc_paths: elixirc_paths(Mix.env),
     compilers: [:phoenix, :gettext] ++ Mix.compilers,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [mod: {Ocjb, []},
     applications: [:appsignal, :phoenix, :phoenix_pubsub, :phoenix_html, :cowboy, :logger, :gettext]]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "web", "test/support"]
  defp elixirc_paths(_),     do: ["lib", "web"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [{:phoenix, "~> 1.4"},
     {:phoenix_pubsub, "~> 1.0"},
     {:phoenix_html, "~> 2.6"},
     {:phoenix_slime, "~> 0.12.0"},
     {:phoenix_live_reload, "~> 1.1.1", only: :dev},
     {:jason, "~> 1.0"},
     {:gettext, "~> 0.13"},
     {:plug_cowboy, "~> 2.0"},
     {:appsignal, "~> 1.0"},
     {:id3v2, "~> 0.1.3"}]
  end
end
