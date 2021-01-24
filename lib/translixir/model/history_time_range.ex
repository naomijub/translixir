defmodule Translixir.Model.HistoryTimeRange do
  defstruct [:start_valid_time, :end_valid_time, :start_tx_time, :end_tx_time]

  @type t(start_valid_time, end_valid_time, start_tx_time, end_tx_time) :: %Translixir.Model.HistoryTimeRange{
    start_valid_time: start_valid_time, end_valid_time: end_valid_time, start_tx_time: start_tx_time, end_tx_time: end_tx_time
  }

  @type t :: %Translixir.Model.HistoryTimeRange{
    start_valid_time: DateTime.t(), end_valid_time: DateTime.t(), start_tx_time: DateTime.t(), end_tx_time: DateTime.t()
  }
end
