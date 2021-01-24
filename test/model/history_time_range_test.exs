defmodule Model.HistoryTimeRangeTest do
  use ExUnit.Case
  alias Translixir.Http.EntityHistory
  alias Translixir.Model.HistoryTimeRange

  test "All fields are defined" do
    time = DateTime.from_naive!(~N[2020-10-10 13:26:08.003], "Etc/UTC")

    ranges = %HistoryTimeRange{
      start_valid_time: time,
      end_valid_time: time,
      start_tx_time: time,
      end_tx_time: time
    }

    actual = EntityHistory.time_ranges(ranges)

    expected =
      "end-tx-time=2020-10-10T13:26:08.003%2B00:00&end-valid-time=2020-10-10T13:26:08.003%2B00:00&start-tx-time=2020-10-10T13:26:08.003%2B00:00&start-valid-time=2020-10-10T13:26:08.003%2B00:00"

    assert actual == expected
  end

  test "All tx fields are defined" do
    start_time = DateTime.from_naive!(~N[2020-10-10 13:26:08.003], "Etc/UTC")
    end_time = DateTime.from_naive!(~N[2020-11-10 13:26:08.003], "Etc/UTC")

    ranges = %HistoryTimeRange{
      start_tx_time: start_time,
      end_tx_time: end_time
    }

    actual = EntityHistory.time_ranges(ranges)

    expected =
      "end-tx-time=2020-11-10T13:26:08.003%2B00:00&start-tx-time=2020-10-10T13:26:08.003%2B00:00"

    assert actual == expected
  end

  test "All valid fields are defined" do
    start_time = DateTime.from_naive!(~N[2020-10-10 13:26:08.003], "Etc/UTC")
    end_time = DateTime.from_naive!(~N[2020-11-10 13:26:08.003], "Etc/UTC")

    ranges = %HistoryTimeRange{
      start_valid_time: start_time,
      end_valid_time: end_time
    }

    actual = EntityHistory.time_ranges(ranges)

    expected =
      "end-valid-time=2020-11-10T13:26:08.003%2B00:00&start-valid-time=2020-10-10T13:26:08.003%2B00:00"

    assert actual == expected
  end
end
