defmodule Zookeeper.Discord.Router do
  use Plug.Router
  use Plug.Debugger
  require Logger

  plug(Plug.Logger, log: :debug)
  plug(:match)
  plug(:dispatch)

  plug(Zookeeper.Discord.VerificationPlug, public_key: "yeet")

  def handle(conn) do
    with {:ok, body, conn} <- read_body(conn),
         {:ok, json} <- Poison.decode(body),
         %{"type" => t} <- json do
      case t do
        1 -> send_resp(conn, 200, Poison.encode!(%{:type => 1}))
        4 -> Zookeeper.Discord.Handlers
        _ -> send_resp(conn, 200, "cool")
      end
    else
      _ -> send_resp(conn, 400, "Invalid Data")
    end
  end

  post "/", do: handle(conn)

  match _ do
    send_resp(conn, 404, "Not Found")
  end
end
