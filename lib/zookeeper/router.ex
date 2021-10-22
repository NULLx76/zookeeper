defmodule Zookeeper.Router do
  use Plug.Router
  use Plug.Debugger
  require Logger
  alias Zookeeper.Discord

  plug(Plug.Logger, log: :debug)

  plug(:match)

  plug(:dispatch)

  get "/hello" do
    send_resp(conn, 200, "world")
  end

  @pk "7B4C72BEF63E5742543EE008434AAAFC965BF599650CDEA671D5DD57B3A45163" |> Base.decode16!()

  post "/discord" do
    with {:ok, conn, json} <- Discord.verify_signature(conn, @pk) do
      case Map.fetch!(json, "type") do
        # Ping
        1 ->
          conn
          |> put_resp_content_type("application/json")
          |> send_resp(200, Poison.encode!(%{"type" => 1}))

        # Slash Command
        2 ->
          conn
          |> put_resp_content_type("application/json")
          |> send_resp(
            200,
            Poison.encode!(%{
              "type" => 4,
              "data" => %{
                "tts" => false,
                "content" => "Hello #{get_in(json, ["member", "nick"])}!",
                "embeds" => [],
                "allowed_mentions" => %{"parse" => []}
              }
            })
          )

        _ ->
          send_resp(conn, 400, "Invalid Request")
      end
    else
      {:error, code, msg} -> send_resp(conn, code, msg)
    end
  end

  match _ do
    send_resp(conn, 404, "Not Found")
  end
end
