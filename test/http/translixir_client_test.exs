defmodule Http.TranslixirClientTest do
  use ExUnit.Case
  doctest Translixir
  alias Translixir.Http.Client

  test "new client has host and port" do
    {:ok, client} = Client.new("localhost", "3000")
    expected = %Client{host: "localhost", port: "3000"}
    assert Client.get(client) == expected
  end

  test "adds auth to client" do
    {:ok, client} = Client.new("localhost", "3000")
    Client.auth(client, "token")
    expected = %Client{host: "localhost", port: "3000", auth: "token"}
    assert Client.get(client) == expected
  end

  test "headers without auth" do
    {:ok, client} = Client.new("localhost", "3000")
    assert Client.headers(client) == [{"Content-Type", "application/edn"}]
  end

  test "headers with auth" do
    {:ok, client} = Client.new("localhost", "3000")
    Client.auth(client, "token")

    assert Client.headers(client) == [
             {"Content-Type", "application/edn"},
             {"Authorization", "Bearer token"}
           ]
  end

  test "client endpoints" do
    {:ok, client} = Client.new("localhost", "3000")
    assert Client.endpoint(client, :tx_log) == "http://localhost:3000/tx-log"
    assert Client.endpoint(client, :entity) == "http://localhost:3000/entity"
    assert Client.endpoint(client, :entity_tx) == "http://localhost:3000/entity-tx"
    assert Client.endpoint(client, :entity_history) == "http://localhost:3000/entity-history"
    assert Client.endpoint(client, :query) == "http://localhost:3000/query"
  end
end
