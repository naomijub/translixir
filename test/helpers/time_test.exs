defmodule Helpers.TimeTest do
  use ExUnit.Case
  doctest Translixir
  alias Translixir.Helpers.Time

  @valid_time DateTime.from_naive!(~N[2020-10-10 13:26:08.003], "Etc/UTC")
  @tx_time DateTime.from_naive!(~N[2020-12-10 13:26:08.003], "Etc/UTC")
  @base_url "base_url"

  test "No time stamp" do
    url = Time.build_timed_url(@base_url, "", "")

    assert url == "base_url"
  end

  test "Valid time" do
    url = Time.build_timed_url(@base_url, "", @valid_time)

    assert url == "base_url?valid-time=2020-10-10T13:26:08.003%2B00:00"
  end

  test "Tx time" do
    url = Time.build_timed_url(@base_url, @tx_time, "")

    assert url == "base_url?transaction-time=2020-12-10T13:26:08.003%2B00:00"
  end

  test "Tx time and valid time" do
    url = Time.build_timed_url(@base_url, @tx_time, @valid_time)

    assert url ==
             "base_url?transaction-time=2020-12-10T13:26:08.003%2B00:00&valid-time=2020-10-10T13:26:08.003%2B00:00"
  end
end
