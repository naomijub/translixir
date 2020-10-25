# Translixir

[![hex.pm](https://img.shields.io/hexpm/v/translixir.svg)](https://hex.pm/packages/translixir)
[![hex.pm](https://img.shields.io/badge/docs-hexpm-blue.svg)](https://hexdocs.pm/translixir)
[![hex.pm](https://img.shields.io/hexpm/dt/translixir.svg)](https://hex.pm/packages/translixir)
[![hex.pm](https://img.shields.io/hexpm/l/translixir.svg)](https://hex.pm/packages/translixir)
[![github.com](https://img.shields.io/github/last-commit/naomijub/translixir.svg)](https://github.com/naomijub/translixir/commits/master)

Elixir client for [Crux DB](https://www.opencrux.com), the general purpose
database with bitemporal Datalog and SQL.
- [x] Via `Docker` with a [`crux-standalone`](https://opencrux.com/reference/building.html#_docker) version [docker-hub](https://hub.docker.com/r/juxt/crux-standalone). Current Docker image `juxt/crux-standalone:20.09-1.11.0`. **Via github dependency**
- [x] Via [`HTTP`](https://opencrux.com/reference/http.html#start-http-server) using the [`HTTP API`](https://opencrux.com/reference/http.html#http-api). **Via github dependency**
- [ ] Missing entity_history with time-stamps
- [ ] Include tests for every http function

* [**Crux Getting Started**](https://opencrux.com/reference/get-started.html)
* [**Crux FAQs**](https://opencrux.com/about/faq.html)
* [**Rust Client** as inspiration](https://github.com/naomijub/transistor)

## Bitemporal Crux

Crux is optimised for efficient and globally consistent point-in-time queries using a pair of transaction-time and valid-time timestamps.

Ad-hoc systems for bitemporal recordkeeping typically rely on explicitly tracking either valid-from and valid-to timestamps or range types directly within relations. The bitemporal document model that Crux provides is very simple to reason about and it is universal across the entire database, therefore it does not require you to consider which historical information is worth storing in special "bitemporal tables" upfront.

One or more documents may be inserted into Crux via a put transaction at a specific valid-time, defaulting to the transaction time (i.e. now), and each document remains valid until explicitly updated with a new version via put or deleted via delete.

### Why?

| Time 	| Purpose 	|
|-	|-	|
| transaction-time 	| Used for audit purposes, technical requirements such as event sourcing. 	|
| valid-time 	| Used for querying data across time, historical analysis. 	|

`transaction-time` represents the point at which data arrives into the database. This gives us an audit trail and we can see what the state of the database was at a particular point in time. You cannot write a new transaction with a transaction-time that is in the past.

`valid-time` is an arbitrary time that can originate from an upstream system, or by default is set to transaction-time. Valid time is what users will typically use for query purposes.

Reference [crux bitemporality](https://opencrux.com/about/bitemporality.html) and [value of bitemporality](https://juxt.pro/blog/posts/value-of-bitemporality.html)


## Installation

The package can be installed by adding `translixir` to your list of
dependencies in `mix.exs`:
* For now only via github. Dependent crates are not on hex [jfacorro/Eden](https://github.com/jfacorro/Eden) and [jfacorro/elixir-array](https://github.com/jfacorro/elixir-array).

```elixir
def deps do
  [
    {:translixir, github: "naomijub/translixir"}
  ]
end
```

## Creating a Crux Client

All operations with Translixir required a `Translixir.Client`. You can instantiate a new `Agent` containing the required information for a request with `Translixir.Client.new(host, port)` and set authorization header token with `Translixir.Client.auth(<pid>, token)`.

```elixir
# Simple Client
  {:ok, client} = Client.new("localhost","3000")
  expected = %Client{host: "localhost", port: "3000"}
  assert Client.get(client) == expected


# Client with Authorization
  {:ok, client} = Client.new("localhost","3000")
  Client.auth(client, "token")
  expected = %Client{host: "localhost", port: "3000", auth: "token"}
  assert Client.get(client) == expected
```

## Building a `tx_log::Action` to Insert in database
* use module `Translixir.Model.Action`

```elixir
alias Translixir.Model.Action

actions =
  Action.new()
  |> Action.add_action(Action.evict(:hello))
  |> Action.add_action(
    Action.delete(:my_id, DateTime.from_naive!(~N[2020-10-10 13:26:08.003], "Etc/UTC"))
  )
  |> Action.actions()

assert actions ==
          "[[:crux.tx/evict :hello] [:crux.tx/delete :my_id #inst \"2020-10-10T13:26:08.003%2B00:00\"]]"
```

Possible Actions:
```elixir
alias Translixir.Model.Action

actual = Action.put(:my_id, %{first_name: "test", last_name: "wow"})
expected = "[:crux.tx/put {:crux.db/id :my_id, :first_name \"test\", :last_name \"wow\"}]"
assert actual == expected

actual =
  Action.put(
    :my_id,
    %{first_name: "test", last_name: "wow"},
    DateTime.from_naive!(~N[2020-10-10 13:26:08.003], "Etc/UTC")
  )
expected =
  "[:crux.tx/put {:crux.db/id :my_id, :first_name \"test\", :last_name \"wow\"} #inst \"2020-10-10T13:26:08.003%2B00:00\"]"
assert actual == expected

actual = Action.delete(:my_id)
expected = "[:crux.tx/delete :my_id]"
assert actual == expected

actual = Action.delete(:my_id, DateTime.from_naive!(~N[2020-10-10 13:26:08.003], "Etc/UTC"))
expected = "[:crux.tx/delete :my_id #inst \"2020-10-10T13:26:08.003%2B00:00\"]"
assert actual == expected

assert Action.evict(3) == "[:crux.tx/evict 3]"
assert Action.evict(:my_id) == "[:crux.tx/evict :my_id]"
```

## Building a Query
* Use module `Translixir.Model.Query`

```elixir
alias Translixir.Model.Query

actual =
  Query.find(%{}, ["?h", "?q"])
  |> Query.where(["?p1 :name ?n", "?p1 :is-sql true"])
  |> Query.build()
expected = "{:query {:find [?h ?q], :where [[?p1 :name ?n] [?p1 :is-sql true]]}}"
assert actual == expected

assert catch_error(Query.find(%{}, [":hello", ":world"])) ==
          %RuntimeError{message: "All keys should be atoms or strings starting with `?`"}

actual =
  Query.find(%{}, ["?h", "?q"])
  |> Query.where(["?p1 :name ?n", "?p1 :is-sql ?s"])
  |> Query.args(["?s true"])
  |> Query.build()
expected =
  "{:query {:args [{?s true}], :find [?h ?q], :where [[?p1 :name ?n] [?p1 :is-sql ?s]]}}"
assert actual == expected

actual =
  Query.find(%{}, ["?h", "?q"])
  |> Query.where(["?p1 :name ?n", "?p1 :is-sql ?s"])
  |> Query.limit(5)
  |> Query.offset(20)
  |> Query.build()
expected =
  "{:query {:find [?h ?q], :limit 5, :offset 20, :where [[?p1 :name ?n] [?p1 :is-sql ?s]]}}"
assert actual == expected

actual =
  Query.find(%{}, [:h, :q])
  |> Query.where(["?p1 :name ?n", "?p1 :is-sql ?s"])
  |> Query.order_by(["?s true"])
  |> Query.with_full_results()
  |> Query.build()
expected =
  "{:query {:find [?h ?q], :full-results? true, :order-by [[?s true]], :where [[?p1 :name ?n] [?p1 :is-sql ?s]]}}"
assert actual == expected
```

## Functions examples

```elixir
alias Translixir.Http.Client
alias Translixir.Model.Action

client = Client.new("localhost", "3000")
put = Action.new()
  |> Action.add_action(Action.put(:hello, %{first_name: "Hello", last_name: "World"}))
  |> Action.add_action(Action.delete(:delete_id))
  |> Action.actions()

client |> Translixir.tx_log(put)
# {:ok, %{"crux.tx/tx-id": 7, "crux.tx/tx-time": ~U[2020-10-25 04:33:41.102Z]}}

client |> Translixir.entity(:hello) |> IO.inspect()
# {:ok, %{"crux.db/id": :hello, first_name: "Hello", last_name: "World"}}

```

## License

[LGPL](LICENSE). Copyright (c) 2020 Julia Naomi.
