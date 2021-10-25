defmodule Zookeeper.Discord.RegisterCommands do
  use Task, restart: :transient
  alias Zookeeper.Discord
  alias Zookeeper.Discord.Commands

  def start_link(arg) do
    Task.start_link(__MODULE__, :run, [
      Keyword.fetch!(arg, :app_id),
      Keyword.fetch!(arg, :token),
      Keyword.fetch!(arg, :guilds)
    ])
  end

  def run(app_id, token, guilds) do
    commands = Commands.command_definitions()

    for guild <- guilds do
      Discord.set_slash_commands!(app_id, token, guild, commands)
    end
  end
end
