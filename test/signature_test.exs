defmodule ZookeeperTest.SignatureTest do
  use ExUnit.Case, async: true
  use Plug.Test

  test "test succesful sign" do
    timestamp = "xxx"
    msg = ~s({"type": 1})

    %{public: pk, secret: sk} = :enacl.crypto_sign_ed25519_keypair()

    signature = :enacl.sign_detached(timestamp <> msg, sk) |> Base.encode16()

    # Create a test connection
    conn =
      conn(:post, "/discord", msg)
      |> put_req_header("x-signature-ed25519", signature)
      |> put_req_header("x-signature-timestamp", timestamp)

    # Invoke the plug
    {:ok, conn, _json} = Zookeeper.Discord.verify_signature(conn, pk)

    assert conn.status != 401
    assert conn.status != 400
  end

  test "test invalid sign" do
    timestamp = "xxx"
    msg = ~s({"type": 1})

    %{public: pk, secret: sk} = :enacl.crypto_sign_ed25519_keypair()

    signature = :enacl.sign_detached(timestamp <> msg, sk) |> Base.encode16()

    # Create a test connection
    conn =
      conn(:post, "/discord", ~s({"type": 1, "bogus": "data"}))
      |> put_req_header("x-signature-ed25519", signature)
      |> put_req_header("x-signature-timestamp", timestamp)

    # Invoke the plug
    {:error, 401, _} = Zookeeper.Discord.verify_signature(conn, pk)
  end

  test "test invalid json" do
    timestamp = "xxx"
    msg = "non-json"

    %{public: pk, secret: sk} = :enacl.crypto_sign_ed25519_keypair()

    signature = :enacl.sign_detached(timestamp <> msg, sk) |> Base.encode16()

    # Create a test connection
    conn =
      conn(:post, "/discord", msg)
      |> put_req_header("x-signature-ed25519", signature)
      |> put_req_header("x-signature-timestamp", timestamp)

    # Invoke the plug
    {:error, 400, _} = Zookeeper.Discord.verify_signature(conn, pk)
  end
end
