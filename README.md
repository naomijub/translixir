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

```elixir
def deps do
  [
    {:translixir, "~> 0.1.1"}
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

## License

[LGPL](LICENSE). Copyright (c) 2020 Julia Naomi.
