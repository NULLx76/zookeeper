defmodule ZookeeperTest.AuthPlugTest do
  use ExUnit.Case, async: true
  use Plug.Test
  import Plug.Conn


  test "ed25519 test valid" do
    %{public: public, secret: secret} = :enacl.crypto_sign_ed25519_keypair()

    timestamp = "#{DateTime.utc_now()}"
    msg = "wooloo"

    signature = :enacl.sign_detached(timestamp <> msg, secret)

    assert :enacl.sign_verify_detached(signature, timestamp <> msg, public)

    # Create a test connection
    conn =
      conn(:post, "/discord", msg)
      |> put_req_header("x-signature-ed25519", signature)
      |> put_req_header("x-signature-timestamp", timestamp)

    # Invoke the plug
    conn = Zookeeper.Discord.VerificationPlug.call(conn, [public_key: public])

    assert conn.status != 402
  end

  test "ed25519 test invalid" do
    %{public: public, secret: secret} = :enacl.crypto_sign_ed25519_keypair()

    timestamp = "#{DateTime.utc_now()}"
    msg = "wooloo"

    # Flip msg and timestamp
    signature = :enacl.sign_detached(msg <> timestamp, secret)

    assert !:enacl.sign_verify_detached(signature, timestamp <> msg, public)

    # Create a test connection
    conn =
      conn(:post, "/discord", msg)
      |> put_req_header("x-signature-ed25519", signature)
      |> put_req_header("x-signature-timestamp", timestamp)

    # Invoke the plug
    conn = Zookeeper.Discord.VerificationPlug.call(conn, [public_key: public])

    assert conn.status == 402
  end
end
