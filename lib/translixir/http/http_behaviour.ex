defmodule Translixir.Http.HttpBehaviour do
  @moduledoc false
  @callback get(String.t(), list()) :: any()
  @callback post(String.t(), String.t(), list()) :: any()
end
