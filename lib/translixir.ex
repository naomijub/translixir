defmodule Translixir do
  @moduledoc """
  Documentation for `Translixir`.
  """

  def client(host, port) do
    "#{host}:#{port}"
  end

  def action(:put, value) do
    "[[:crux.tx/put #{value}]]"
  end

  def tx_log(client, actions) do
    HTTPoison.start
    HTTPoison.post "http://#{client}/tx-log", "#{actions}", [{"Content-Type", "application/edn"}]
  end

  def init() do
    put = action(:put, "{ :crux.db/id :jorge-3, :first-name \"Michael\", :last-name \"Jorge\", }")

    client("localhost", "3000")
    |> tx_log(put)
    |> IO.inspect
  end
end
