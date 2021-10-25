defmodule Zookeeper.Discord do
  import Plug.Conn

  @spec verify_signature(Plug.Conn.t(), binary()) ::
          {:error, 400 | 401, binary()} | {:ok, Plug.Conn.t(), map()}
  def verify_signature(conn, pk) do
    with [signature | _] <- get_req_header(conn, "x-signature-ed25519"),
         [timestamp | _] <- get_req_header(conn, "x-signature-timestamp"),
         {:ok, body, conn} <- read_body(conn),
         {:ok, json} <- Poison.decode(body),
         {:ok, signature} <- signature |> String.upcase() |> Base.decode16(),
         {:ok, pk} <- pk |> String.upcase() |> Base.decode16() do
      if :enacl.sign_verify_detached(signature, timestamp <> body, pk) do
        {:ok, conn, json}
      else
        {:error, 401, "invalid request signature"}
      end
    else
      _ -> {:error, 400, "invalid headers or body"}
    end
  end

  def set_slash_commands!(app_id, token, guild_id, def) do
    {:ok, resp} =
      Finch.build(
        :put,
        "https://discord.com/api/v8/applications/#{app_id}/guilds/#{guild_id}/commands",
        [
          {"content-type", "application/json"},
          {"Authorization", "Bot " <> token}
        ],
        Poison.encode!(def)
      )
      |> Finch.request(MyFinch)

    resp.status
  end
end
