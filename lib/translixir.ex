defmodule Translixir do
  @moduledoc """
  Documentation for `Translixir`.
  """
  alias Translixir.Client


  def action(:put, value) do
    "[[:crux.tx/put #{value}]]"
  end

  def tx_log({:ok, client}, actions) do
    url = Client.endpoint(client, :tx_log)
    headers = Client.headers(client)
    HTTPoison.post url, "#{actions}", headers
  end

  def tx_log!(client, actions) when is_pid(client) do
    url = Client.endpoint(client, :tx_log)
    headers = Client.headers(client)
    HTTPoison.post url, "#{actions}", headers
  end

  def tx_logs({:ok, client}) do
    url = Client.endpoint(client, :tx_log)
    headers = Client.headers(client)
    HTTPoison.get url, headers
  end

  def tx_logs!(client) when is_pid(client) do
    url = Client.endpoint(client, :tx_log)
    headers = Client.headers(client)
    HTTPoison.get url, headers
  end

  def entity({:ok, client}, entity) do
    url = Client.endpoint(client, :entity)
    headers = Client.headers(client)
    HTTPoison.post url, "{:eid #{entity}}", headers
  end

  def entity!(client, entity) when is_pid(client) do
    url = Client.endpoint(client, :entity)
    headers = Client.headers(client)
    HTTPoison.post url, "{:eid #{entity}}", headers
  end
end
