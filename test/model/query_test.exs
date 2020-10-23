defmodule Model.QueryTest do
  use ExUnit.Case
  doctest Translixir
  alias Translixir.Model.Query

  test "simple query" do
    actual =
      Query.find(%{}, ["?h", "?q"])
      |> Query.where(["?p1 :name ?n", "?p1 :is-sql true"])
      |> Query.build()

    expected = "{:query {:find [?h ?q], :where [[?p1 :name ?n] [?p1 :is-sql true]]}}"
    assert actual == expected
  end

  test "Query error" do
    assert catch_error(Query.find(%{}, [":hello", ":world"])) ==
             %RuntimeError{message: "All keys should be atoms or strings starting with `?`"}
  end

  test "Query with args" do
    actual =
      Query.find(%{}, ["?h", "?q"])
      |> Query.where(["?p1 :name ?n", "?p1 :is-sql ?s"])
      |> Query.args(["?s true"])
      |> Query.build()

    expected =
      "{:query {:args [{?s true}], :find [?h ?q], :where [[?p1 :name ?n] [?p1 :is-sql ?s]]}}"

    assert actual == expected
  end

  test "Query with limit and offset" do
    actual =
      Query.find(%{}, ["?h", "?q"])
      |> Query.where(["?p1 :name ?n", "?p1 :is-sql ?s"])
      |> Query.limit(5)
      |> Query.offset(20)
      |> Query.build()

    expected =
      "{:query {:find [?h ?q], :limit 5, :offset 20, :where [[?p1 :name ?n] [?p1 :is-sql ?s]]}}"

    assert actual == expected
  end

  test "Query with order-by and full-results" do
    actual =
      Query.find(%{}, [:h, :q])
      |> Query.where(["?p1 :name ?n", "?p1 :is-sql ?s"])
      |> Query.order_by(["?s true"])
      |> Query.with_full_results()
      |> Query.build()

    expected =
      "{:query {:find [?h ?q], :full-results? true, :order-by [[?s true]], :where [[?p1 :name ?n] [?p1 :is-sql ?s]]}}"

    assert actual == expected
  end
end
