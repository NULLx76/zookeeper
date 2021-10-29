import Config

if config_env() == :test do
  # Just have placeholders during tests
  config :zookeeper,
    discord_app_id: "DISCORD_APP_ID",
    discord_token: "DISCORD_TOKEN",
    discord_public_key: "DISCORD_PUBLIC_KEY",
    twitter_token: "TWITTER_TOKEN",
    start_fetch: false
else
  config :zookeeper,
    discord_app_id: System.fetch_env!("DISCORD_APP_ID"),
    discord_token: System.fetch_env!("DISCORD_TOKEN"),
    discord_public_key: System.fetch_env!("DISCORD_PUBLIC_KEY"),
    twitter_token: System.fetch_env!("TWITTER_TOKEN"),
    start_fetch: true
end

# Config peerage for prod.
if config_env() == :prod do
  service_name = System.fetch_env!("SERVICE_NAME")

  config :peerage,
    via: Peerage.Via.Dns,
    dns_name: service_name,
    app_name: "dps"
end
