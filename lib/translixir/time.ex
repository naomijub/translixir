defmodule Translixir.Time do

  @spec build_timed_url(binary(), DateTime.t() | binary, DateTime.t() | binary) :: binary()
  def build_timed_url(url, tx_time, valid_time) do
    url = case {Timex.format(tx_time, "{ISO:Extended}"), Timex.format(valid_time, "{ISO:Extended}")} do
      {{:ok, tx_date}, {:ok, valid_date}} -> "#{url}?transaction-time=#{tx_date}&valid-time=#{valid_date}"
      {_, {:ok, valid_date}} -> "#{url}?valid-time=#{valid_date}"
      {{:ok, tx_date}, _} -> "#{url}?transaction-time=#{tx_date}"
      _ -> url
    end
    String.replace(url, "+", "%2B")
  end
end
