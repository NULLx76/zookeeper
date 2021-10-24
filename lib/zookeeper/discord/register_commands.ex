defmodule Zookeeper.Discord.RegisterCommands do
  use Task, restart: :transient
  alias Zookeeper.Discord

  def start_link(arg) do
    Task.start_link(__MODULE__, :run, [
      Keyword.fetch!(arg, :app_id),
      Keyword.fetch!(arg, :token),
      Keyword.fetch!(arg, :guilds)
    ])
  end

  def run(app_id, token, guilds) do
    for guild <- guilds do
      Discord.add_slash_command!(app_id, token, guild)
    end
  end
end
