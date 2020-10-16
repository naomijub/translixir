defmodule Translixir.Client do
  @moduledoc """
  Módule containing the Client configurations
  """

  @enforce_keys [:host, :port]
  defstruct [:host, :port, :auth]

  def new(host, port) do
    HTTPoison.start
    client = %Translixir.Client{host: host, port: port}
    Agent.start_link(fn -> client end)
  end

  def auth(pid, auth) do
    Agent.update(pid, fn(client) ->
      map = Map.put(client, :auth, auth)
      map
    end)
  end

  def get(pid) do
    Agent.get(pid, fn(client) -> client end)
  end

  def headers(pid) do
    content_type = {"Content-Type", "application/edn"}
    Agent.get(pid, fn(client) -> case Map.fetch(client, :auth) do
        {:ok, auth} when not is_nil(auth)-> [content_type, {"Authorization", "Bearer #{auth}"}]
        _ -> [content_type]
      end
    end)
  end

  def endpoint(pid, action) do
    base_url = Agent.get(pid, fn(client) -> "#{client.host}:#{client.port}" end)
    case action do
      :tx_log -> "http://#{base_url}/tx-log"
      :entity -> "http://#{base_url}/entity"
    end
  end
end
