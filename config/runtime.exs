import Config

if config_env() == :prod do
  config :zookeeper,
    discord_app_id: System.fetch_env!("DISCORD_APP_ID"),
    discord_token: System.fetch_env!("DISCORD_TOKEN"),
    discord_public_key: System.fetch_env!("DISCORD_PUBLIC_KEY"),
    twitter_token: System.fetch_env!("TWITTER_TOKEN")

  service_name = System.fetch_env!("SERVICE_NAME")

  config :peerage,
    via: Peerage.Via.Dns,
    dns_name: service_name,
    app_name: "zookeeper"
end
