use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :ocjb, Ocjb.Endpoint,
  http: [port: 4001],
  server: false,
  music_dir: "web/static/assets/mp3"

# Print only warnings and errors during test
config :logger, level: :warn
