defmodule Translixir.Http.Client do
  @moduledoc """
  Módule containing the Client configurations
  """

  @enforce_keys [:host, :port]
  defstruct [:host, :port, :auth]

  @doc """
  `new` creates an Agent that contains structs `Client` with fields `:host, :port`
  """
  def new(host, port) do
    HTTPoison.start()
    client = %Translixir.Http.Client{host: host, port: port}
    Agent.start_link(fn -> client end)
  end

  @doc """
  `auth` includes field `:auth` at struct Client contained at <PID>, it is the authorization token

  ```
  {:ok, client} = Client.new("localhost", "3000")
  Client.auth(client, "token")

  assert Client.headers(client) == [
            {"Content-Type", "application/edn"},
            {"Authorization", "Bearer token"}
          ]
  ```
  """
  def auth(pid, auth) do
    Agent.update(pid, fn client ->
      map = Map.put(client, :auth, auth)
      map
    end)
  end

  @doc """
  `get` returns struct `Client` contained at <PID>
  """
  def get(pid) do
    Agent.get(pid, fn client -> client end)
  end

  @doc """
  `headers` returns the request headers for Client at <PID>.
  If `:auth` is present
  returns `[{"Content-Type", "application/edn"}, {"Authorization", "Bearer token"}]`
  else
  returns `[{"Content-Type", "application/edn"}]`

  ```
  {:ok, client} = Client.new("localhost", "3000")
  assert Client.headers(client) == [{"Content-Type", "application/edn"}]
  ```
  """
  def headers(pid) do
    content_type = {"Content-Type", "application/edn"}

    Agent.get(pid, fn client ->
      case Map.fetch(client, :auth) do
        {:ok, auth} when not is_nil(auth) -> [content_type, {"Authorization", "Bearer #{auth}"}]
        _ -> [content_type]
      end
    end)
  end

  @doc """
  `endpoint` returns the endpoin for Client at `<PID>`.
  * `:tx_log => "http://base_url/tx-log"`
  * `:entity => "http://#base_url/entity"`
  * `:entity_tx => "http://base_url/entity-tx"`
  * `:entity_history => "http://base_url/entity-history"`

  ```
  {:ok, client} = Client.new("localhost", "3000")
  assert Client.endpoint(client, :tx_log) == "http://localhost:3000/tx-log"
  assert Client.endpoint(client, :entity) == "http://localhost:3000/entity"
  assert Client.endpoint(client, :entity_tx) == "http://localhost:3000/entity-tx"
  assert Client.endpoint(client, :entity_history) == "http://localhost:3000/entity-history"
  assert Client.endpoint(client, :query) == "http://localhost:3000/query"
  ```
  """
  def endpoint(pid, endpoint) do
    base_url = Agent.get(pid, fn client -> "#{client.host}:#{client.port}" end)

    case endpoint do
      :tx_log -> "http://#{base_url}/tx-log"
      :entity -> "http://#{base_url}/entity"
      :entity_tx -> "http://#{base_url}/entity-tx"
      :entity_history -> "http://#{base_url}/entity-history"
      :query -> "http://#{base_url}/query"
    end
  end
end
