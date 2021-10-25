defmodule Zookeeper.Discord.Commands do
  def run_command(data) do
    case get_in(data, ["data", "name"]) do
      "boop" -> blep()
      _ -> unknown()
    end
  end

  def command_definitions() do
    [
      %{
        "name" => "boop",
        "type" => 1,
        "description" => "Show a random cute animal picture"
      }
    ]
  end

  def blep() do
    with {:ok, pic} <- Zookeeper.get_pic() do
      {:ok,
       %{
         "type" => 4,
         "data" => %{
           "tts" => false,
           "content" => Map.fetch!(pic, :media_preview_url),
           "embeds" => [],
           "allowed_mentions" => %{"parse" => []}
         }
       }}
    else
      _ -> :error
    end
  end

  def unknown() do
    {:ok,
     %{
       "type" => 4,
       "data" => %{
         "tts" => false,
         "content" => "Unknown command",
         "embeds" => [],
         "allowed_mentions" => %{"parse" => []}
       }
     }}
  end
end
