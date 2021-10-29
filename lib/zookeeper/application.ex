defmodule Zookeeper.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Plug.Cowboy, scheme: :http, plug: Zookeeper.Discord.Router, port: 8085},
      {Finch, name: MyFinch},
      {Zookeeper.Twitter.TweetStore, 0},
      {Task.Supervisor, name: Zookeeper.TaskSupervisor},
      {Zookeeper.Discord.RegisterCommands,
       app_id: Application.fetch_env!(:zookeeper, :discord_app_id),
       token: Application.fetch_env!(:zookeeper, :discord_token),
       guilds: Application.fetch_env!(:zookeeper, :discord_guilds)}
    ]

    # Don't run TweetFetcher when disabled (during tests)
    children =
      if Application.fetch_env!(:zookeeper, :start_fetch) do
        children
      else
        children ++
          [
            {Zookeeper.Twitter.TweetFetcher,
             token: Application.fetch_env!(:zookeeper, :twitter_token),
             accounts: Application.fetch_env!(:zookeeper, :twitter_accounts)}
          ]
      end

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Zookeeper.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
