import Config

# Placeholders during test
config :zookeeper,
  discord_app_id: "DISCORD_APP_ID",
  discord_token: "DISCORD_TOKEN",
  discord_public_key: "DISCORD_PUBLIC_KEY",
  twitter_token: "TWITTER_TOKEN",
  service_name: "SERVICE_NAME"

config :logger, level: :warn
