defmodule Zookeeper.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  alias Zookeeper.Discord

  @impl true
  def start(_type, _args) do
    children = [
      {Plug.Cowboy, scheme: :http, plug: Zookeeper.Router, port: 8085},
      {Finch, name: MyFinch}
    ]

    # Discord.add_slash_command!(APP_ID, TOKEN, GUILD_ID)

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Zookeeper.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
