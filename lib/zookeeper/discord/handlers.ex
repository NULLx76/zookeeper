defmodule Zookeeper.Discord.Handlers do
  import Plug.Conn

  def hello_world(conn, data) do
    hello_world = %{
      "type" => 4,
      "data" => %{
        "tts" => false,
        "content" => "Hello World",
        "embed" => [],
        "allowed_mentions" => %{ "parse" => [] }
      }
    }

    conn
    |> send_resp(conn, 200, Poison.encode!(hello_world))
  end
end
