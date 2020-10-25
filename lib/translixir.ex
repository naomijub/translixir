defmodule Translixir do
  @moduledoc """
  Documentation for `Translixir`.
  """
  alias Translixir.Helpers.Time
  alias Translixir.Http.Client
  alias Translixir.Http.EntityHistory

  @spec tx_log({:ok, pid}, any) :: {:error} | {:ok, any}
  @doc """
    `tx_log({:ok, <PID>}, actions)` POSTs a collection of `Action` at CruxDB endpoint [`/tx-log`](https://www.opencrux.com/reference/20.09-1.12.1/http.html#tx-log-post)

    Usage:
    ```elixir
    put = action(:put, "{ :crux.db/id :jorge-3, :first-name \"Michael\", :last-name \"Jorge\", }")

    Client.new("localhost", "3000")
    |> tx_log(put)
    |> IO.inspect
    ```

    Returns:
    * `status_2XX` -> {:ok, body}
    * _ -> {:error}

    Example `Action`:
    * `{ :crux.db/id :jorge-3, :first-name \"Michael\", :last-name \"Jorge\", }`

    Example Response:
    * `{:ok, "{:crux.tx/tx-id 7, :crux.tx/tx-time #inst \"2020-07-16T21:50:39.309-00:00\"}"}`
  """
  def tx_log({:ok, client}, actions) do
    url = Client.endpoint(client, :tx_log)
    headers = Client.headers(client)
    response = HTTPoison.post(url, "#{actions}", headers)

    case response do
      {:ok, content} when content.status_code < 300 -> Eden.decode(content.body)
      _ -> {:error}
    end
  end

  @spec tx_log!(pid, any) :: any
  @doc """
    `tx_log!(<PID>, actions)` POSTs a collection of `Action` at CruxDB endpoint `/tx-log`

    Returns:
    * `status_2XX` -> body
    * _ -> exception is raised

  """
  def tx_log!(client, actions) when is_pid(client) do
    url = Client.endpoint(client, :tx_log)
    headers = Client.headers(client)
    response = HTTPoison.post(url, "#{actions}", headers)

    case response do
      {:ok, content} when content.status_code < 300 -> Eden.decode!(content.body)
      _ -> raise "POST at tx-log with body #{actions} did not return 200"
    end
  end

  @spec tx_logs({:ok, pid}) :: {:error} | {:ok, any}
  @doc """
    `tx_logs({:ok, <PID>})` GETs at CruxDB endpoint [`/tx-log`](https://www.opencrux.com/reference/20.09-1.12.1/http.html#tx-log)

    Returns:
    * `status_2XX` -> {:ok, body}
    * _ -> {:error}

    Example Response:
    ```elixir
    {:ok,
      ({:crux.tx/tx-id 0, :crux.tx/tx-time #inst \"2020-10-14T03:48:43.298-00:00\", :crux.tx.event/tx-events
        [[:crux.tx/put #crux/id \"be21bd5ae7f3334b9b8abb185dfbeae1623088b1\" #crux/id \"9d2c7102d6408d465f85b0b35dfb209b34daadd1\"]]}
      {:crux.tx/tx-id 1, :crux.tx/tx-time #inst \"2020-10-16T01:10:08.451-00:00\", :crux.tx.event/tx-events
        [[:crux.tx/put #crux/id \"be21bd5ae7f3334b9b8abb185dfbeae1623088b1\" #crux/id \"9d2c7102d6408d465f85b0b35dfb209b34daadd1\"]]})}
    ```

  """
  def tx_logs({:ok, client}) do
    url = Client.endpoint(client, :tx_log)
    headers = Client.headers(client)
    response = HTTPoison.get(url, headers)

    case response do
      {:ok, content} when content.status_code < 300 -> Eden.decode(content.body)
      _ -> {:error}
    end
  end

  @spec tx_logs!(pid) :: any
  @doc """
    `tx_logs!(<PID>)` GETs at CruxDB endpoint `/tx-log`

    Returns:
    * `status_2XX` ->  body
    * _ -> exception is raised
  """
  def tx_logs!(client) when is_pid(client) do
    url = Client.endpoint(client, :tx_log)
    headers = Client.headers(client)
    response = HTTPoison.get(url, headers)

    case response do
      {:ok, content} when content.status_code < 300 -> Eden.decode!(content.body)
      _ -> raise "GET at tx-log did not return 200"
    end
  end

  @spec entity({:ok, atom | pid | {atom, any} | {:via, atom, any}}, atom | binary | integer) ::
          {:error} | {:error, atom} | {:ok, any}
  @doc """
    1. `entity({:ok, <PID>}, entity_crux_id)`
    2. `entity({:ok, <PID>}, entity_crux_id, transaction_time, valid_time)`
    POSTs an ID at CruxDB endpoint [`/entity[?[transaction-time=<transaction_time>]&[valid-time=<valid_time>]]`}(https://www.opencrux.com/reference/20.09-1.12.1/http.html#entity)
    * `transaction_time` and `valid_time` are in `DateTime` format

    Returns:
    * `status_2XX` -> {:ok, body}
    * _ -> {:error}

    Example `entity_crux_id`:
    * `":jorge-3"`, `:jorge_3` or `3`
    * `":jorge-3"` and `:jorge_3` are not equivalent

    Example Response:
    * `{:ok, { :crux.db/id :jorge-3, :first-name \"Michael\", :last-name \"Jorge\", }}`

  """
  def entity({:ok, client}, entity_id)
      when is_atom(entity_id) or is_integer(entity_id) or is_binary(entity_id) do
    url = Client.endpoint(client, :entity)
    headers = Client.headers(client)

    entity_data =
      case is_atom(entity_id) do
        true -> "{:eid :#{entity_id}}"
        false -> "{:eid #{entity_id}}"
      end

    response = HTTPoison.post(url, entity_data, headers)

    case response do
      {:ok, content} when content.status_code < 300 -> Eden.decode(content.body)
      _ -> {:error}
    end
  end

  @spec entity(
          {:ok, atom | pid | {atom, any} | {:via, atom, any}},
          atom | binary | integer,
          DateTime.t(),
          DateTime.t()
        ) :: {:error} | {:error, atom} | {:ok, any}
  def entity({:ok, client}, entity_id, tx_time, valid_time)
      when is_atom(entity_id) or is_integer(entity_id) or is_binary(entity_id) do
    url = Time.build_timed_url(Client.endpoint(client, :entity), tx_time, valid_time)
    headers = Client.headers(client)

    entity_data =
      case is_atom(entity_id) do
        true -> "{:eid :#{entity_id}}"
        false -> "{:eid #{entity_id}}"
      end

    response = HTTPoison.post(url, entity_data, headers)

    case response do
      {:ok, content} when content.status_code < 300 -> Eden.decode(content.body)
      _ -> {:error}
    end
  end

  @spec entity!(pid, atom | binary | integer, DateTime.t(), DateTime.t()) :: any
  @doc """
    1. `entity!(<PID>, entity_crux_id)`
    2. `entity!(<PID>, entity_crux_id, transaction_time, valid_time)`
    POSTs an ID at CruxDB endpoint `/entity[?[transaction-time=<transaction_time>]&[valid-time=<valid_time>]]`
    * `transaction_time` and `valid_time` are in `DateTime` format

    Returns:
    * `status_2XX` -> body
    * _ -> exception is raised

    Example `entity_crux_id`:
    * `":jorge-3"`, `:jorge_3` or `3`
    * `":jorge-3"` and `:jorge_3` are not equivalent

    Example Response:
    * `{ :crux.db/id :jorge-3, :first-name \"Michael\", :last-name \"Jorge\", }`

  """
  def entity!(client, entity_id, tx_time, valid_time)
      when is_pid(client) and
             (is_atom(entity_id) or is_integer(entity_id) or is_binary(entity_id)) do
    url = Time.build_timed_url(Client.endpoint(client, :entity), tx_time, valid_time)
    headers = Client.headers(client)

    entity_data =
      case is_atom(entity_id) do
        true -> "{:eid :#{entity_id}}"
        false -> "{:eid #{entity_id}}"
      end

    response = HTTPoison.post(url, entity_data, headers)

    case response do
      {:ok, content} when content.status_code < 300 -> Eden.decode!(content.body)
      _ -> raise "POST at entity with id #{entity_id} did not return 200"
    end
  end

  @spec entity!(pid, atom | binary | integer) :: any
  def entity!(client, entity_id)
      when is_pid(client) and
             (is_atom(entity_id) or is_integer(entity_id) or is_binary(entity_id)) do
    url = Client.endpoint(client, :entity)
    headers = Client.headers(client)

    entity_data =
      case is_atom(entity_id) do
        true -> "{:eid :#{entity_id}}"
        false -> "{:eid #{entity_id}}"
      end

    response = HTTPoison.post(url, entity_data, headers)

    case response do
      {:ok, content} when content.status_code < 300 -> Eden.decode!(content.body)
      _ -> raise "POST at entity with id #{entity_id} did not return 200"
    end
  end

  @spec entity_tx({:ok, atom | pid | {atom, any} | {:via, atom, any}}, atom | binary | integer) ::
          {:error} | {:error, atom} | {:ok, any}
  @doc """
    1. `entity_tx({:ok, <PID>}, entity_crux_id)`
    2. `entity_tx({:ok, <PID>}, entity_crux_id, transaction_time, valid_time)`
    POSTs an ID at CruxDB endpoint [`/entity-tx`](https://www.opencrux.com/reference/20.09-1.12.1/http.html#entity-tx)
    * `transaction_time` and `valid_time` are in `DateTime` format

    Returns:
    * `status_2XX` -> {:ok, body}
    * _ -> {:error}

    Example `entity_crux_id`:
    * `":jorge-3"`, `:jorge_3` or `3`
    * `":jorge-3"` and `:jorge_3` are not equivalent

    Example Response:
    * `{:ok, "{:crux.db/id #crux/id \"be21bd5ae7f3334b9b8abb185dfbeae1623088b1\", :crux.db/content-hash #crux/id \"9d2c7102d6408d465f85b0b35dfb209b34daadd1\", :crux.db/valid-time #inst \"2020-10-16T01:51:50.568-00:00\", :crux.tx/tx-time #inst \"2020-10-16T01:51:50.568-00:00\", :crux.tx/tx-id 4}"}`

  """
  def entity_tx({:ok, client}, entity_id)
      when is_atom(entity_id) or is_integer(entity_id) or is_binary(entity_id) do
    url = Client.endpoint(client, :entity_tx)
    headers = Client.headers(client)

    entity_data =
      case is_atom(entity_id) do
        true -> "{:eid :#{entity_id}}"
        false -> "{:eid #{entity_id}}"
      end

    response = HTTPoison.post(url, entity_data, headers)

    case response do
      {:ok, content} when content.status_code < 300 -> Eden.decode(content.body)
      _ -> {:error}
    end
  end

  @spec entity_tx(
          {:ok, atom | pid | {atom, any} | {:via, atom, any}},
          atom | binary | integer,
          DateTime.t(),
          DateTime.t()
        ) :: {:error} | {:error, atom} | {:ok, any}
  def entity_tx({:ok, client}, entity_id, tx_time, valid_time)
      when is_atom(entity_id) or is_integer(entity_id) or is_binary(entity_id) do
    url = Time.build_timed_url(Client.endpoint(client, :entity_tx), tx_time, valid_time)
    headers = Client.headers(client)

    entity_data =
      case is_atom(entity_id) do
        true -> "{:eid :#{entity_id}}"
        false -> "{:eid #{entity_id}}"
      end

    response = HTTPoison.post(url, entity_data, headers)

    case response do
      {:ok, content} when content.status_code < 300 -> Eden.decode(content.body)
      _ -> {:error}
    end
  end

  @spec entity_tx!(pid, atom | binary | integer) :: any
  @doc """
    1. `entity_tx!(<PID>, entity_crux_id)`
    2. `entity_tx!(<PID>, entity_crux_id, transaction_time, valid_time)`
    POSTs an ID at CruxDB endpoint `/entity-tx`
    * `transaction_time` and `valid_time` are in `DateTime` format

    Returns:
    * `status_2XX` -> body
    * _ -> exception is raised

    Example `entity_crux_id`:
    * `":jorge-3"`, `:jorge_3` or `3`
    * `":jorge-3"` and `:jorge_3` are not equivalent

    Example Response:
    * `"{:crux.db/id #crux/id \"be21bd5ae7f3334b9b8abb185dfbeae1623088b1\", :crux.db/content-hash #crux/id \"9d2c7102d6408d465f85b0b35dfb209b34daadd1\", :crux.db/valid-time #inst \"2020-10-16T01:51:50.568-00:00\", :crux.tx/tx-time #inst \"2020-10-16T01:51:50.568-00:00\", :crux.tx/tx-id 4}"`

  """
  def entity_tx!(client, entity_id)
      when is_pid(client) and
             (is_atom(entity_id) or is_integer(entity_id) or is_binary(entity_id)) do
    url = Client.endpoint(client, :entity_tx)
    headers = Client.headers(client)

    entity_data =
      case is_atom(entity_id) do
        true -> "{:eid :#{entity_id}}"
        false -> "{:eid #{entity_id}}"
      end

    response = HTTPoison.post(url, entity_data, headers)

    case response do
      {:ok, content} when content.status_code < 300 -> Eden.decode!(content.body)
      _ -> raise "POST at entity-tx with id #{entity_id} did not return 200"
    end
  end

  @spec entity_tx!(pid, atom | binary | integer, DateTime.t(), DateTime.t()) :: any
  def entity_tx!(client, entity_id, tx_time, valid_time)
      when is_pid(client) and
             (is_atom(entity_id) or is_integer(entity_id) or is_binary(entity_id)) do
    url = Time.build_timed_url(Client.endpoint(client, :entity_tx), tx_time, valid_time)
    headers = Client.headers(client)

    entity_data =
      case is_atom(entity_id) do
        true -> "{:eid :#{entity_id}}"
        false -> "{:eid #{entity_id}}"
      end

    response = HTTPoison.post(url, entity_data, headers)

    case response do
      {:ok, content} when content.status_code < 300 -> Eden.decode!(content.body)
      _ -> raise "POST at entity-tx with id #{entity_id} did not return 200"
    end
  end

  @spec entity_history({:ok, pid}, any, :asc | :desc, boolean) :: any
  @doc """
    `entity_history({:ok, <PID>}, entity_hash, order, with_docs \\ false)`
    GETs an CruxdD hash at CruxDB endpoint [`/entity-history/<hash>?sort-order=<order>&with-docs=<with_docs>`](https://www.opencrux.com/reference/20.09-1.12.1/http.html#entity-history)
    * `order` can be `:asc` or `:desc`

    Returns:
    * `status_2XX` -> {:ok, body}
    * _ -> {:error}

    Example `entity_hash`:
    * `"9d2c7102d6408d465f85b0b35dfb209b34daadd1"`

    Example Response (`with_docs = false`):
    ```elixir
    {:ok, [
      %{
        "crux.db/content-hash": %Eden.Tag{
          name: "crux/id",
          value: "9d2c7102d6408d465f85b0b35dfb209b34daadd1"
        },
        "crux.db/valid-time": ~U[2020-10-22 18:18:20.524Z],
        "crux.tx/tx-id": 160,
        "crux.tx/tx-time": ~U[2020-10-22 18:18:20.524Z]
      },
      ...]
    }```
  """
  def entity_history({:ok, client}, entity_hash, order, with_docs \\ false)
      when is_pid(client) and is_boolean(with_docs) and is_atom(order) do
    url = Client.endpoint(client, :entity_history)
    headers = Client.headers(client)

    EntityHistory.entity_history(url, headers, entity_hash, with_docs, order)
  end

  @spec query({:ok, atom | pid | {atom, any} | {:via, atom, any}}, any) ::
          {:error} | {:error, atom} | {:ok, any}
  @doc """
    `entity_history!(<PID>, entity_hash, order, with_docs \\ false)`
    GETs an CruxdD hash at CruxDB endpoint `/entity-history/<hash>?sort-order=<order>&with-docs=<with_docs>`
    * `order` can be `:asc` or `:desc`



    Returns:
    * `status_2XX` -> {:ok, body}
    * _ -> {:error}

    Example `entity_hash`:
    * `"9d2c7102d6408d465f85b0b35dfb209b34daadd1"`

    Example Response (`with_docs = false`):
    ```elixir
    [
      %{
      "crux.db/content-hash": %Eden.Tag{
    EntityHistory.entity_history(url, headers, entity_hash, with_docs, order)
    query = %{}
      |> Query.find(["?n"])
      |> Query.where([
        "?n :first-name ?p",
      ])
      |> Query.args(["?p \"Michael\""])
      |> Query.with_full_results
      |> Query.build



    client
    |> query(query)
    |> IO.inspect
    # {:ok,
    #   [
    #     #Array<[
    #       %{"crux.db/id": :"jorge-3", "first-name": "Michael", "last-name": "Jorge"}
    #     ], fixed=false, default=nil>
    #   ]}
    ```
  """
  def query({:ok, client}, query) do
    url = Client.endpoint(client, :query)
    headers = Client.headers(client)
    response = HTTPoison.post(url, "#{query}", headers)

    case response do
      {:ok, content} when content.status_code < 300 -> Eden.decode(content.body)
      _ -> {:error}
    end
  end

  @spec query!(pid, any) :: any
  @doc """
    `query!(<PID>, query)` POSTs a `Query` at CruxDB endpoint `/query`
  """
  def query!(client, query) when is_pid(client) do
    url = Client.endpoint(client, :query)
    headers = Client.headers(client)
    response = HTTPoison.post(url, "#{query}", headers)

    case response do
      {:ok, content} when content.status_code < 300 -> Eden.decode!(content.body)
      _ -> raise "POST at query with body #{query} did not return 200"
    end
  end
end
