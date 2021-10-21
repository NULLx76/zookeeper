defmodule Zookeeper.Discord.VerificationPlug do
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, opts) do
    pk = Keyword.fetch!(opts, :public_key)

    with [signature | _] <- get_req_header(conn, "x-signature-ed25519"),
         [timestamp | _] <- get_req_header(conn, "x-signature-timestamp"),
         {:ok, body, conn} = read_body(conn),
         true <- :enacl.sign_verify_detached(signature, to_string(timestamp <> body), pk) do
      conn
    else
      _ -> send_resp(conn, 402, "")
    end
  end
end
