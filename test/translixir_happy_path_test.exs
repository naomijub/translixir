defmodule TranslixirHappyPathTest do
  use ExUnit.Case
  doctest Translixir
  alias Translixir
  alias Translixir.Http.Client
  alias Translixir.Model.Action
  alias Translixir.Model.HistoryTimeRange
  alias Translixir.Model.Query

  import Mox

  test "tx_log puts info" do
    actions =
      Action.new()
      |> Action.add_action(Action.put(:jorge, %{name: "hello"}))
      |> Action.actions()

    mock_actions = "#{actions}"

    Translixir.MockHTTPoison
    |> expect(:post, fn "http://localhost:3000/tx-log",
                        mock_actions,
                        [{"Content-Type", "application/edn"}] ->
      {:ok,
       %HTTPoison.Response{
         body: "{:crux.tx/tx-id 1, :crux.tx/tx-time #inst \"2020-11-01T02:33:47.525-00:00\"}",
         status_code: 202
       }}
    end)

    result = Translixir.tx_log(Client.new("localhost", "3000"), actions)
    assert {:ok, %{"crux.tx/tx-id": 1, "crux.tx/tx-time": ~U[2020-11-01 02:33:47.525Z]}} == result
  end

  test "tx_log! puts info" do
    {:ok, client_pid} = Client.new("localhost", "3000")

    actions =
      Action.new()
      |> Action.add_action(Action.put(:jorge, %{name: "hello"}))
      |> Action.actions()

    mock_actions = "#{actions}"

    Translixir.MockHTTPoison
    |> expect(:post, fn "http://localhost:3000/tx-log",
                        mock_actions,
                        [{"Content-Type", "application/edn"}] ->
      {:ok,
       %HTTPoison.Response{
         body: "{:crux.tx/tx-id 1, :crux.tx/tx-time #inst \"2020-11-01T02:33:47.525-00:00\"}",
         status_code: 202
       }}
    end)

    result = Translixir.tx_log!(client_pid, actions)
    assert %{"crux.tx/tx-id": 1, "crux.tx/tx-time": ~U[2020-11-01 02:33:47.525Z]} == result
  end

  test "tx_logs gets tx history" do
    Translixir.MockHTTPoison
    |> expect(:get, fn "http://localhost:3000/tx-log", [{"Content-Type", "application/edn"}] ->
      {:ok,
       %HTTPoison.Response{
         body:
           "({:crux.tx/tx-id 0, :crux.tx/tx-time #inst \"2020-11-01T02:33:13.371-00:00\",
              :crux.tx.event/tx-events [[:crux.tx/put #crux/id \"33f927344e079e00d3fa45d8833b04e735223eec\" #crux/id \"d5c474af4ced822d951d0d2da2d75cf946bca62c\"]]}
            {:crux.tx/tx-id 1, :crux.tx/tx-time #inst \"2020-11-01T02:33:47.525-00:00\",
              :crux.tx.event/tx-events [[:crux.tx/put #crux/id \"33f927344e079e00d3fa45d8833b04e735223eec\" #crux/id \"d5c474af4ced822d951d0d2da2d75cf946bca62c\"]]})",
         status_code: 200
       }}
    end)

    {:ok, result} = Translixir.tx_logs(Client.new("localhost", "3000"))

    assert Eden.encode!(result) ==
             "({:crux.tx.event/tx-events [[:crux.tx/put, #crux/id \"33f927344e079e00d3fa45d8833b04e735223eec\", #crux/id \"d5c474af4ced822d951d0d2da2d75cf946bca62c\"]], :crux.tx/tx-id 0, :crux.tx/tx-time #inst \"2020-11-01T02:33:13.371Z\"}, {:crux.tx.event/tx-events [[:crux.tx/put, #crux/id \"33f927344e079e00d3fa45d8833b04e735223eec\", #crux/id \"d5c474af4ced822d951d0d2da2d75cf946bca62c\"]], :crux.tx/tx-id 1, :crux.tx/tx-time #inst \"2020-11-01T02:33:47.525Z\"})"
  end

  test "entity returns correct entity" do
    Translixir.MockHTTPoison
    |> expect(:post, fn "http://localhost:3000/entity",
                        "{:eid :jorge}",
                        [{"Content-Type", "application/edn"}] ->
      {:ok,
       %HTTPoison.Response{
         body: "{:crux.db/id :jorge, :name \"hello\"}",
         status_code: 200
       }}
    end)

    result = Translixir.entity(Client.new("localhost", "3000"), :jorge)

    assert result ==
             {:ok, %{"crux.db/id": :jorge, name: "hello"}}
  end

  test "entity timed returns correct entity" do
    {:ok, client_pid} = Client.new("localhost", "3000")

    Translixir.MockHTTPoison
    |> expect(:post, fn _, "{:eid :jorge}", [{"Content-Type", "application/edn"}] ->
      {:ok,
       %HTTPoison.Response{
         body: "{:crux.db/id :jorge, :name \"hello\"}",
         status_code: 200
       }}
    end)

    result =
      Translixir.entity!(
        client_pid,
        :jorge,
        ~U[2020-11-04 00:07:29.057Z],
        ~U[2020-11-04 00:07:29.057Z]
      )

    assert result == %{"crux.db/id": :jorge, name: "hello"}
  end

  test "entity-tx returns correct entity" do
    Translixir.MockHTTPoison
    |> expect(:post, fn "http://localhost:3000/entity-tx",
                        "{:eid :jorge}",
                        [{"Content-Type", "application/edn"}] ->
      {:ok,
       %HTTPoison.Response{
         body: "{:crux.db/id #crux/id \"33f927344e079e00d3fa45d8833b04e735223eec\",
            :crux.db/content-hash #crux/id \"d5c474af4ced822d951d0d2da2d75cf946bca62c\",
            :crux.db/valid-time #inst \"2020-11-04T00:07:29.057-00:00\",
            :crux.tx/tx-time #inst \"2020-11-04T00:07:29.057-00:00\", :crux.tx/tx-id 2}",
         status_code: 200
       }}
    end)

    result = Translixir.entity_tx(Client.new("localhost", "3000"), :jorge)

    assert result ==
             {:ok,
              %{
                "crux.db/content-hash": %Eden.Tag{
                  name: "crux/id",
                  value: "d5c474af4ced822d951d0d2da2d75cf946bca62c"
                },
                "crux.db/id": %Eden.Tag{
                  name: "crux/id",
                  value: "33f927344e079e00d3fa45d8833b04e735223eec"
                },
                "crux.db/valid-time": ~U[2020-11-04 00:07:29.057Z],
                "crux.tx/tx-id": 2,
                "crux.tx/tx-time": ~U[2020-11-04 00:07:29.057Z]
              }}
  end

  test "entity-tx timed returns correct entity" do
    {:ok, client_pid} = Client.new("localhost", "3000")

    Translixir.MockHTTPoison
    |> expect(:post, fn _, "{:eid :jorge}", [{"Content-Type", "application/edn"}] ->
      {:ok,
       %HTTPoison.Response{
         body: "{:crux.db/id #crux/id \"33f927344e079e00d3fa45d8833b04e735223eec\",
            :crux.db/content-hash #crux/id \"d5c474af4ced822d951d0d2da2d75cf946bca62c\",
            :crux.db/valid-time #inst \"2020-11-04T00:07:29.057-00:00\",
            :crux.tx/tx-time #inst \"2020-11-04T00:07:29.057-00:00\", :crux.tx/tx-id 2}",
         status_code: 200
       }}
    end)

    result =
      Translixir.entity_tx!(
        client_pid,
        :jorge,
        ~U[2020-11-04 00:07:29.057Z],
        ~U[2020-11-04 00:07:29.057Z]
      )

    assert result ==
             %{
               "crux.db/content-hash": %Eden.Tag{
                 name: "crux/id",
                 value: "d5c474af4ced822d951d0d2da2d75cf946bca62c"
               },
               "crux.db/id": %Eden.Tag{
                 name: "crux/id",
                 value: "33f927344e079e00d3fa45d8833b04e735223eec"
               },
               "crux.db/valid-time": ~U[2020-11-04 00:07:29.057Z],
               "crux.tx/tx-id": 2,
               "crux.tx/tx-time": ~U[2020-11-04 00:07:29.057Z]
             }
  end

  test "entity history" do
    Translixir.MockHTTPoison
    |> expect(:get, fn
      "http://localhost:3000/entity-history/33f927344e079e00d3fa45d8833b04e735223eec?sort-order=asc&with-docs=true",
      [{"Content-Type", "application/edn"}] ->
        {:ok,
         %HTTPoison.Response{
           body:
             "({:crux.tx/tx-time #inst \"2020-11-01T02:33:13.371-00:00\", :crux.tx/tx-id 0, :crux.db/valid-time #inst \"2020-11-01T02:33:13.371-00:00\", :crux.db/content-hash #crux/id \"d5c474af4ced822d951d0d2da2d75cf946bca62c\", :crux.db/doc {:crux.db/id :jorge, :name \"hello\"}}
            {:crux.tx/tx-time #inst \"2020-11-01T02:33:47.525-00:00\", :crux.tx/tx-id 1, :crux.db/valid-time #inst \"2020-11-01T02:33:47.525-00:00\", :crux.db/content-hash #crux/id \"d5c474af4ced822d951d0d2da2d75cf946bca62c\", :crux.db/doc {:crux.db/id :jorge, :name \"hello\"}}
            {:crux.tx/tx-time #inst \"2020-11-04T00:07:29.057-00:00\", :crux.tx/tx-id 2, :crux.db/valid-time #inst \"2020-11-04T00:07:29.057-00:00\", :crux.db/content-hash #crux/id \"d5c474af4ced822d951d0d2da2d75cf946bca62c\", :crux.db/doc {:crux.db/id :jorge, :name \"hello\"}})",
           status_code: 200
         }}
    end)

    result =
      Translixir.entity_history(
        Client.new("localhost", "3000"),
        "33f927344e079e00d3fa45d8833b04e735223eec",
        :asc,
        true
      )

    assert result ==
             [
               %{
                 "crux.db/content-hash": %Eden.Tag{
                   name: "crux/id",
                   value: "d5c474af4ced822d951d0d2da2d75cf946bca62c"
                 },
                 "crux.db/doc": %{"crux.db/id": :jorge, name: "hello"},
                 "crux.db/valid-time": ~U[2020-11-01 02:33:13.371Z],
                 "crux.tx/tx-id": 0,
                 "crux.tx/tx-time": ~U[2020-11-01 02:33:13.371Z]
               },
               %{
                 "crux.db/content-hash": %Eden.Tag{
                   name: "crux/id",
                   value: "d5c474af4ced822d951d0d2da2d75cf946bca62c"
                 },
                 "crux.db/doc": %{"crux.db/id": :jorge, name: "hello"},
                 "crux.db/valid-time": ~U[2020-11-01 02:33:47.525Z],
                 "crux.tx/tx-id": 1,
                 "crux.tx/tx-time": ~U[2020-11-01 02:33:47.525Z]
               },
               %{
                 "crux.db/content-hash": %Eden.Tag{
                   name: "crux/id",
                   value: "d5c474af4ced822d951d0d2da2d75cf946bca62c"
                 },
                 "crux.db/doc": %{"crux.db/id": :jorge, name: "hello"},
                 "crux.db/valid-time": ~U[2020-11-04 00:07:29.057Z],
                 "crux.tx/tx-id": 2,
                 "crux.tx/tx-time": ~U[2020-11-04 00:07:29.057Z]
               }
             ]
  end

  test "entity timed history" do
    Translixir.MockHTTPoison
    |> expect(:get, fn
      "http://localhost:3000/entity-history/33f927344e079e00d3fa45d8833b04e735223eec?sort-order=asc&with-docs=true&end-tx-time=2020-10-10T13:26:08.003%2B00:00&end-valid-time=2020-10-10T13:26:08.003%2B00:00&start-tx-time=2020-10-10T13:26:08.003%2B00:00&start-valid-time=2020-10-10T13:26:08.003%2B00:00",
      [{"Content-Type", "application/edn"}] ->
        {:ok,
         %HTTPoison.Response{
           body:
             "({:crux.tx/tx-time #inst \"2020-11-01T02:33:13.371-00:00\", :crux.tx/tx-id 0, :crux.db/valid-time #inst \"2020-11-01T02:33:13.371-00:00\", :crux.db/content-hash #crux/id \"d5c474af4ced822d951d0d2da2d75cf946bca62c\", :crux.db/doc {:crux.db/id :jorge, :name \"hello\"}}
            {:crux.tx/tx-time #inst \"2020-11-01T02:33:47.525-00:00\", :crux.tx/tx-id 1, :crux.db/valid-time #inst \"2020-11-01T02:33:47.525-00:00\", :crux.db/content-hash #crux/id \"d5c474af4ced822d951d0d2da2d75cf946bca62c\", :crux.db/doc {:crux.db/id :jorge, :name \"hello\"}}
            {:crux.tx/tx-time #inst \"2020-11-04T00:07:29.057-00:00\", :crux.tx/tx-id 2, :crux.db/valid-time #inst \"2020-11-04T00:07:29.057-00:00\", :crux.db/content-hash #crux/id \"d5c474af4ced822d951d0d2da2d75cf946bca62c\", :crux.db/doc {:crux.db/id :jorge, :name \"hello\"}})",
           status_code: 200
         }}
    end)

    time = DateTime.from_naive!(~N[2020-10-10 13:26:08.003], "Etc/UTC")

    ranges = %HistoryTimeRange{
      start_valid_time: time,
      end_valid_time: time,
      start_tx_time: time,
      end_tx_time: time
    }

    result =
      Translixir.entity_history_timed(
        Client.new("localhost", "3000"),
        "33f927344e079e00d3fa45d8833b04e735223eec",
        :asc,
        true,
        ranges
      )

    assert result ==
             [
               %{
                 "crux.db/content-hash": %Eden.Tag{
                   name: "crux/id",
                   value: "d5c474af4ced822d951d0d2da2d75cf946bca62c"
                 },
                 "crux.db/doc": %{"crux.db/id": :jorge, name: "hello"},
                 "crux.db/valid-time": ~U[2020-11-01 02:33:13.371Z],
                 "crux.tx/tx-id": 0,
                 "crux.tx/tx-time": ~U[2020-11-01 02:33:13.371Z]
               },
               %{
                 "crux.db/content-hash": %Eden.Tag{
                   name: "crux/id",
                   value: "d5c474af4ced822d951d0d2da2d75cf946bca62c"
                 },
                 "crux.db/doc": %{"crux.db/id": :jorge, name: "hello"},
                 "crux.db/valid-time": ~U[2020-11-01 02:33:47.525Z],
                 "crux.tx/tx-id": 1,
                 "crux.tx/tx-time": ~U[2020-11-01 02:33:47.525Z]
               },
               %{
                 "crux.db/content-hash": %Eden.Tag{
                   name: "crux/id",
                   value: "d5c474af4ced822d951d0d2da2d75cf946bca62c"
                 },
                 "crux.db/doc": %{"crux.db/id": :jorge, name: "hello"},
                 "crux.db/valid-time": ~U[2020-11-04 00:07:29.057Z],
                 "crux.tx/tx-id": 2,
                 "crux.tx/tx-time": ~U[2020-11-04 00:07:29.057Z]
               }
             ]
  end

  test "query for entity" do
    {:ok, client_pid} = Client.new("localhost", "3000")

    query =
      Query.find(%{}, [:h])
      |> Query.where(["?h :name \"hello\""])
      |> Query.with_full_results()
      |> Query.build()

    mock_query = "#{query}"

    Translixir.MockHTTPoison
    |> expect(:post, fn "http://localhost:3000/query",
                        mock_query,
                        [{"Content-Type", "application/edn"}] ->
      {:ok,
       %HTTPoison.Response{
         body: "([{:crux.db/id :jorge, :name \"hello\"}])",
         status_code: 200
       }}
    end)

    result = Translixir.query!(client_pid, query)
    assert "([{:crux.db/id :jorge, :name \"hello\"}])" == Eden.encode!(result)
  end
end
