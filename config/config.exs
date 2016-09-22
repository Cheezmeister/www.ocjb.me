# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :ocjb, Ocjb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "agxd0Xv6NlhjvLXjmmcjqkArob3s2KlecQ9QUnvrL7AAq5MODG7hAHTQ1mHYSdnx",
  render_errors: [view: Ocjb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Ocjb.PubSub,
           adapter: Phoenix.PubSub.PG2]

config :phoenix, :template_engines,
  slim: PhoenixSlime.Engine,
  slime: PhoenixSlime.Engine

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
