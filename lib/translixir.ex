defmodule Translixir do
  @moduledoc """
  Documentation for `Translixir`.
  """
  alias Translixir.Helpers.Time
  alias Translixir.Http.Client
  alias Translixir.Http.EntityHistory

  @spec tx_log({:ok, pid}, any) :: {:error} | {:ok, any}
  @doc """
    tx_log({:ok, <PID>}, actions)
    POST a collection of `Action` at CruxDB endpoint `/tx-log`

    Usage:
    ```
    put = action(:put, "{ :crux.db/id :jorge-3, :first-name \"Michael\", :last-name \"Jorge\", }")

    Client.new("localhost", "3000")
    |> tx_log(put)
    |> IO.inspect
    ```

    Returns:
    `status_2XX` -> {:ok, body}
    _ -> {:error}

    Example `Action`
    `{ :crux.db/id :jorge-3, :first-name \"Michael\", :last-name \"Jorge\", }`

    Example Response:
    `{:ok, "{:crux.tx/tx-id 7, :crux.tx/tx-time #inst \"2020-07-16T21:50:39.309-00:00\"}"}`
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
    tx_log!(<PID>, actions)
    POST a collection of `Action` at CruxDB endpoint `/tx-log`

    Returns:
    `status_2XX` -> body
    _ -> exception is raised

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
    tx_logs({:ok, <PID>})
    GET at CruxDB endpoint `/tx-log`

    Returns:
    `status_2XX` -> {:ok, body}
    _ -> {:error}

    Example Response:
    ```
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
    tx_logs!(<PID>)
    GET at CruxDB endpoint `/tx-log`

    Returns:
    `status_2XX` ->  body
    _ -> exception is raised

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

  # @spec entity({:ok, pid}, any) :: {:error} | {:ok, any}
  # @doc """
  #   entity({:ok, <PID>}, entity_crux_id)
  #   POST an ID at CruxDB endpoint `/entity`

  #   Returns:
  #   `status_2XX` -> {:ok, body}
  #   _ -> {:error}

  #   Example `entity_crux_id`
  #   `":jorge-3"`

  #   Example Response:
  #   `{:ok, { :crux.db/id :jorge-3, :first-name \"Michael\", :last-name \"Jorge\", }}`

  # """
  # def entity({:ok, client}, entity_id) do
  #   url = Client.endpoint(client, :entity)
  #   headers = Client.headers(client)
  #   response = HTTPoison.post(url, "{:eid #{entity_id}}", headers)

  #   case response do
  #     {:ok, content} when content.status_code < 300 -> Eden.decode(content.body)
  #     _ -> {:error}
  #   end
  # end

  @doc """
    `entity({:ok, <PID>}, entity_crux_id, transaction_time \\ "", valid_time \\ "")`
    * `transaction_time` and `valid_time` are in `DateTime` format
    POST an ID at CruxDB endpoint `/entity[?[transaction-time=<transaction_time>]&[valid-time=<valid_time>]]`

    Returns:
    `status_2XX` -> {:ok, body}
    _ -> {:error}

    Example `entity_crux_id`
    `":jorge-3"`

    Example Response:
    `{:ok, { :crux.db/id :jorge-3, :first-name \"Michael\", :last-name \"Jorge\", }}`

  """
  def entity({:ok, client}, entity_id, tx_time \\ "", valid_time \\ "") do
    url = Time.build_timed_url(Client.endpoint(client, :entity), tx_time, valid_time)
    headers = Client.headers(client)
    response = HTTPoison.post(url, "{:eid #{entity_id}}", headers)

    case response do
      {:ok, content} when content.status_code < 300 -> Eden.decode(content.body)
      _ -> {:error}
    end
  end

  @doc """
    `entity!(<PID>, entity_crux_id, transaction_time \\ "", valid_time \\ "")`
    * `transaction_time` and `valid_time` are in `DateTime` format
    POST an ID at CruxDB endpoint `/entity[?[transaction-time=<transaction_time>]&[valid-time=<valid_time>]]`


    Returns:
    `status_2XX` -> body
    _ -> exception is raised

    Example `entity_crux_id`
    `":jorge-3"`

    Example Response:
    `{ :crux.db/id :jorge-3, :first-name \"Michael\", :last-name \"Jorge\", }`

  """
  def entity!(client, entity_id, tx_time \\ "", valid_time \\ "") when is_pid(client) do
    url = Time.build_timed_url(Client.endpoint(client, :entity), tx_time, valid_time)
    headers = Client.headers(client)
    response = HTTPoison.post(url, "{:eid #{entity_id}}", headers)

    case response do
      {:ok, content} when content.status_code < 300 -> Eden.decode!(content.body)
      _ -> raise "POST at entity with id #{entity_id} did not return 200"
    end
  end

  @doc """
    `entity_tx({:ok, <PID>}, entity_crux_id transaction_time \\ "", valid_time \\ "")`
    * `transaction_time` and `valid_time` are in `DateTime` format
    POST an ID at CruxDB endpoint `/entity-tx`

    Returns:
    `status_2XX` -> {:ok, body}
    _ -> {:error}

    Example `entity_crux_id`
    `":jorge-3"`

    Example Response:
    `{:ok, "{:crux.db/id #crux/id \"be21bd5ae7f3334b9b8abb185dfbeae1623088b1\", :crux.db/content-hash #crux/id \"9d2c7102d6408d465f85b0b35dfb209b34daadd1\", :crux.db/valid-time #inst \"2020-10-16T01:51:50.568-00:00\", :crux.tx/tx-time #inst \"2020-10-16T01:51:50.568-00:00\", :crux.tx/tx-id 4}"}`

  """
  def entity_tx({:ok, client}, entity_id, tx_time \\ "", valid_time \\ "") do
    url = Time.build_timed_url(Client.endpoint(client, :entity_tx), tx_time, valid_time)
    headers = Client.headers(client)
    response = HTTPoison.post(url, "{:eid #{entity_id}}", headers)

    case response do
      {:ok, content} when content.status_code < 300 -> Eden.decode(content.body)
      _ -> {:error}
    end
  end

  @spec entity_tx!(pid, any) :: any
  @doc """
    `entity_tx!(<PID>, entity_crux_id, transaction_time \\ "", valid_time \\ "")`
    * `transaction_time` and `valid_time` are in `DateTime` format
    POST an ID at CruxDB endpoint `/entity-tx`

    Returns:
    `status_2XX` -> body
    _ -> exception is raised

    Example `entity_crux_id`
    `":jorge-3"`

    Example Response:
    `"{:crux.db/id #crux/id \"be21bd5ae7f3334b9b8abb185dfbeae1623088b1\", :crux.db/content-hash #crux/id \"9d2c7102d6408d465f85b0b35dfb209b34daadd1\", :crux.db/valid-time #inst \"2020-10-16T01:51:50.568-00:00\", :crux.tx/tx-time #inst \"2020-10-16T01:51:50.568-00:00\", :crux.tx/tx-id 4}"`

  """
  def entity_tx!(client, entity_id, tx_time \\ "", valid_time \\ "") when is_pid(client) do
    url = Time.build_timed_url(Client.endpoint(client, :entity_tx), tx_time, valid_time)
    headers = Client.headers(client)
    response = HTTPoison.post(url, "{:eid #{entity_id}}", headers)

    case response do
      {:ok, content} when content.status_code < 300 -> Eden.decode!(content.body)
      _ -> raise "POST at entity-tx with id #{entity_id} did not return 200"
    end
  end

  @spec entity_history({:ok, pid}, any, :asc | :desc, boolean) :: any
  @doc """
    `entity_history({:ok, <PID>}, entity_hash, order, with_docs \\ false)`
    * `order` can be `:asc` or `:desc`

    GET an CruxdD hash at CruxDB endpoint `/entity-history/<hash>?sort-order=<order>&with-docs=<with_docs>`

    Returns:
    `status_2XX` -> {:ok, body}
    _ -> {:error}

    Example `entity_hash`
    `"9d2c7102d6408d465f85b0b35dfb209b34daadd1"`

    Example Response (`with_docs = false`):
    ```{:ok,
        [%{
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

  @spec entity_history!(pid, any, :asc | :desc, boolean) :: any
  @doc """
    `entity_history!(<PID>, entity_hash, order, with_docs \\ false)`
    * `order` can be `:asc` or `:desc`

    GET an CruxdD hash at CruxDB endpoint `/entity-history/<hash>?sort-order=<order>&with-docs=<with_docs>`

    Returns:
    `status_2XX` -> {:ok, body}
    _ -> {:error}

    Example `entity_hash`
    `"9d2c7102d6408d465f85b0b35dfb209b34daadd1"`

    Example Response (`with_docs = false`):
    ```[
      %{
      "crux.db/content-hash": %Eden.Tag{
        name: "crux/id",
        value: "9d2c7102d6408d465f85b0b35dfb209b34daadd1"
      },
      "crux.db/valid-time": ~U[2020-10-22 18:18:20.524Z],
      "crux.tx/tx-id": 160,
      "crux.tx/tx-time": ~U[2020-10-22 18:18:20.524Z]
    },
    ...
  ]```
  """
  def entity_history!(client, entity_hash, order, with_docs \\ false)
      when is_pid(client) and is_boolean(with_docs) and is_atom(order) do
    url = Client.endpoint(client, :entity_history)
    headers = Client.headers(client)

    EntityHistory.entity_history(url, headers, entity_hash, with_docs, order)
  end

  # entity-history with time
  # query
end
