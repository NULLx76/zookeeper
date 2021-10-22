defmodule Zookeeper.Discord do
  import Plug.Conn

  # @root "discord.com"

  @spec verify_signature(Plug.Conn.t(), binary()) ::
          {:error, 400 | 401, binary()} | {:ok, Plug.Conn.t(), map()}
  def verify_signature(conn, pk) do
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

  @spec add_slash_command!(any, binary, any) :: non_neg_integer()
  def add_slash_command!(app_id, token, guild_id) do
    request = %{
      "name" => "blep",
      "type" => 1,
      "description" => "blep"
    }

    {:ok, resp} =
      Finch.build(
        :post,
        "https://discord.com/api/v8/applications/#{app_id}/guilds/#{guild_id}/commands",
        [
          {"content-type", "application/json"},
          {"Authorization", "Bot " <> token}
        ],
        Poison.encode!(request)
      )
      |> Finch.request(MyFinch)

    resp.status
  end
end
