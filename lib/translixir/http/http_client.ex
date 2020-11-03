# defmodule Translixir.Http.HttpClient do
#   @moduledoc false
#   @behaviour Translixir.Http.Adapter

#   @impl Translixir.Http.Adapter
#   @spec post(binary, any, any) :: any
#   def post(url, data, headers) do
#     HTTPoison.post(url, data, headers) |> IO.inspect()
#   end

#   @impl Translixir.Http.Adapter
#   @spec get(binary, any) :: any
#   def get(url, headers) do
#     HTTPoison.get(url, headers) |> IO.inspect()
#   end
# end
