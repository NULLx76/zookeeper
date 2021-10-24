import Config

config :zookeeper,
  discord_app_id: System.fetch_env!("DISCORD_APP_ID"),
  discord_token: System.fetch_env!("DISCORD_TOKEN"),
  discord_public_key: System.fetch_env!("DISCORD_PUBLIC_KEY"),
  twitter_token: System.fetch_env!("TWITTER_TOKEN")
