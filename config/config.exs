import Config

config :zookeeper,
  twitter_accounts: ["gayocats", "RedPandaEveryHr", "CagleCats"],
  discord_guilds: [483224125125427200]

# Default to prod false
config :zookeeper, prod: false

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
