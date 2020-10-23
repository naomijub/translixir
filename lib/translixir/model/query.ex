defmodule Translixir.Model.Query do
  @moduledoc """
  Query module is responsible for facilitationg the creation of a query to send to endpoint `/query`:

  ```
    query =
      Query.find(%{}, [:h, :q])
      |> Query.where(["?p1 :name ?n", "?p1 :is-sql ?s"])
      |> Query.order_by(["?s true"])
      |> Query.limit(5)
      |> Query.offset(20)
      |> Query.with_full_results()
      |> Query.build()

    expected =
      "{:query {:find [?h ?q], :full-results? true, :limit 5, :offset 20, :order-by [[?s true]], :where [[?p1 :name ?n] [?p1 :is-sql ?s]]}}"

    assert query == expected
  ```
  """

  def find(map, keys) when is_list(keys) do
    are_atoms =
      keys |> Enum.map(fn e -> is_atom(e) end) |> Enum.reduce(true, fn e, acc -> acc and e end)

    elements =
      cond do
        are_atoms ->
          keys |> Enum.map(fn e -> "?#{Atom.to_string(e)}" end) |> Enum.join(" ")

        keys
        |> Enum.map(fn e -> String.starts_with?(e, "?") end)
        |> Enum.reduce(true, fn e, acc -> acc and e end) ->
          keys |> Enum.join(" ")

        true ->
          raise "All keys should be atoms or strings starting with `?`"
      end

    Map.put_new(map, :find, Eden.Symbol.new("[#{elements}]"))
  end

  def where(map, clauses) when is_list(clauses) do
    where = clauses |> Enum.map(fn e -> "[#{e}]" end) |> Enum.join(" ")
    Map.put_new(map, :where, Eden.Symbol.new("[#{where}]"))
  end

  def args(map, args) when is_list(args) do
    args_str = args |> Enum.map(fn e -> "{#{e}}" end) |> Enum.join(" ")
    Map.put_new(map, :args, Eden.Symbol.new("[#{args_str}]"))
  end

  def order_by(map, orders) when is_list(orders) do
    order_str = orders |> Enum.map(fn e -> "[#{e}]" end) |> Enum.join(" ")
    Map.put_new(map, :"order-by", Eden.Symbol.new("[#{order_str}]"))
  end

  @spec limit(map, integer) :: map
  def limit(map, limit) when is_integer(limit) do
    Map.put_new(map, :limit, limit)
  end

  @spec offset(map, integer) :: map
  def offset(map, offset) when is_integer(offset) do
    Map.put_new(map, :offset, offset)
  end

  @spec with_full_results(map) :: map
  def with_full_results(map) do
    Map.put_new(map, :"full-results?", true)
  end

  def build(map) when not is_nil(map.find) and not is_nil(map.where) do
    query = %{query: map}
    query |> Eden.encode!()
  end
end
