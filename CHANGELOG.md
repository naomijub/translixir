# Changelog

## v0.1.1

  - Includes query functions  `tx_logs`, `entity` and `entity_tx`. They receive as argument `{:ok, <PID>}` and return `{:ok, body}` or `error`
  - Includes bang functions for `tx_log!`, `tx_logs!`, `entity!` and `entity_tx!`. They receive as argument `<PID>` and return `body` or raise expection.
  - Creates `Translixir.Client` module that deals with Client required information.

## v0.1.0

  - Initial public release
  - `tx_log` function
