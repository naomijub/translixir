# Changelog

## v0.4.0
  - Includes Translixir function `entity_history_timed`.
  - Function `entity_history_timed` uses struct `Translixir.Model.HistoryTimeRange` for time ranges.

## v0.3.0
  - Includes Query namespace to create queries for `query` function.
  - Refactors timed queries to apply dialyzer
  - Includes Github Actions
  - Parses Crux edn responses with [jfacorro/Eden](https://github.com/jfacorro/Eden)

## v0.2.0
  - Includes query functions `entiity_history` and `query`.
  - Includes Action namespace to create `tx-log` transactions.
  - Includes timed query functions

## v0.1.1

  - Includes query functions  `tx_logs`, `entity` and `entity_tx`. They receive as argument `{:ok, <PID>}` and return `{:ok, body}` or `error`
  - Includes bang functions for `tx_log!`, `tx_logs!`, `entity!` and `entity_tx!`. They receive as argument `<PID>` and return `body` or raise expection.
  - Creates `Translixir.Client` module that deals with Client required information.

## v0.1.0

  - Initial public release
  - `tx_log` function
