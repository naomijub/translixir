defmodule Translixir.Http.HttpClient do
  @moduledoc false
  @behaviour Translixir.Http.HttpBehaviour

  @impl Translixir.Http.HttpBehaviour
  def post(url, data, headers) do
    HTTPoison.post(url, data, headers) |> IO.inspect()
  end

  @impl Translixir.Http.HttpBehaviour
  def get(url, headers) do
    HTTPoison.get(url, headers) |> IO.inspect()
  end
end
