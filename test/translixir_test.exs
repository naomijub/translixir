defmodule TranslixirTest do
  use ExUnit.Case
  doctest Translixir
  alias Translixir.Http.Client
  alias Translixir.Model.Action
  alias Translixir

  import Mox

  @client Client.new("localhost", "3000")

  test "tx_log puts info" do
    Translixir.HttpBehaviourMock
    |> expect(:post, fn _, _, _ ->
      {:ok,
       %HTTPoison.Response{
         body: "{:crux.tx/tx-id 1, :crux.tx/tx-time #inst \"2020-11-01T02:33:47.525-00:00\"}",
         status_code: 202
       }}
    end)

    put =
      Action.new()
      |> Action.add_action(Action.put(:jorge, %{name: "hello"}))
      |> Action.actions()

    result = Translixir.tx_log(@client, put)
    assert {:ok, %{"crux.tx/tx-id": 1, "crux.tx/tx-time": ~U[2020-11-01 02:33:47.525Z]}} == result
  end
end
