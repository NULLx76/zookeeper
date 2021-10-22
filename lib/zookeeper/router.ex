defmodule Zookeeper.Router do
  use Plug.Router
  use Plug.Debugger
  require Logger

  plug(Plug.Logger, log: :debug)

  plug(:match)

  plug(:dispatch)

  get "/hello" do
    send_resp(conn, 200, "world")
  end

  @pk "7b4c72bef63e5742543ee008434aaafc965bf599650cdea671d5dd57b3a45163"
      |> String.upcase()
      |> Base.decode16!()

  def verify_signature(conn, pk \\ @pk) do
    with [signature | _] <- get_req_header(conn, "x-signature-ed25519"),
         [timestamp | _] <- get_req_header(conn, "x-signature-timestamp"),
         {:ok, body, conn} <- read_body(conn),
         {:ok, json} <- Poison.decode(body),
         {:ok, signature} <- signature |> String.upcase() |> Base.decode16() do
      if :enacl.sign_verify_detached(signature, timestamp <> body, pk) do
        {:ok, conn, json}
      else
        {:error, 401, "invalid request signature"}
      end
    else
      _ -> {:error, 400, "invalid headers or body"}
    end
  end

  post "/discord" do
    with {:ok, conn, json} <- verify_signature(conn) do
      case Map.fetch!(json, "type") do
        1 ->
          conn
          |> put_resp_content_type("application/json")
          |> send_resp(200, Poison.encode!(%{"type" => 1}))

        _ ->
          conn
      end
    else
      {:error, code, msg} -> send_resp(conn, code, msg)
    end
  end

  match _ do
    send_resp(conn, 404, "Not Found")
  end
end
