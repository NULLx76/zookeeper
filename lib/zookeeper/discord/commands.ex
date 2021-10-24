defmodule Zookeeper.Discord.Commands do
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
end
