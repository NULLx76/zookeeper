defmodule Zookeeper.Discord.Router do
  use Plug.Router
  use Plug.Debugger
  require Logger
  alias Zookeeper.Discord
  alias Zookeeper.Discord.Commands

  plug(Plug.Logger, log: :debug)

  plug(:match)

  plug(:dispatch)

  get "/hello" do
    send_resp(conn, 200, "world")
  end

  post "/discord" do
    pk = Application.fetch_env!(:zookeeper, :discord_public_key)

    with {:ok, conn, json} <- Discord.verify_signature(conn, pk) do
      case Map.fetch!(json, "type") do
        # Ping
        1 ->
          conn
          |> put_resp_content_type("application/json")
          |> send_resp(200, Poison.encode!(%{"type" => 1}))

        # Slash Command
        2 ->
          {:ok, msg} = Commands.run_command(json)

          conn
          |> put_resp_content_type("application/json")
          |> send_resp(200, Poison.encode!(msg))

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
