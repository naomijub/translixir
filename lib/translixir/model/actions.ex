defmodule Translixir.Model.Action do
  @moduledoc """
  For `tx_log` functions it is necessary to create Actions.
  This module is to assist on the creation of this Actions.
  """

  @spec put(atom | integer, map) :: <<_::64, _::_*8>>
  @doc """
  Creates a `tx_log::put` with argument `id, value, valid_time`. It inserts value in CruxDb
  * `id` can be `atom` or `int`
  * `value` can be `struct` or `map`
  * `valid_time` is `DateTime` and optional

  ```elixir
  put = Actions.put(3, %{first_name: "hello", last_name: "world"})

  put == "[:crux.tx/put {:crux.db/id 3 :first_name \"hello\" :last_name \"world\"}]"

  put_date = Actions.put(3, %User{first_name: "hello", last_name: "world"}, DateTime.from_naive!(~N[2020-10-10 13:26:08.003], "Etc/UTC"))

  put_date == "[:crux.tx/put {:crux.db/id 3 :first_name \"hello\" :last_name \"world\"} #inst \"2020-10-10T13:26:08.003%2B00:00\"]"

  ```
  """
  def put(id, value)
      when (is_atom(id) or is_integer(id)) and
             (is_struct(value) or is_map(value)) do
    internal_put(id, value)
  end

  @spec put(
          atom | integer,
          map,
          any
        ) :: binary
  def put(id, value, valid_time)
      when (is_atom(id) or is_integer(id)) and
             (is_struct(value) or is_map(value)) do
    internal_put(id, value, valid_time)
  end

  defp internal_put(id, value, valid_time) when is_struct(value) do
    struct = Map.from_struct(value)
    put = Map.put_new(struct, :"crux.db/id", id)
    encoded = Eden.encode!(put)

    case Timex.format(valid_time, "{ISO:Extended}") do
      {:ok, time} -> String.replace("[:crux.tx/put #{encoded} #inst \"#{time}\"]", "+", "%2B")
      _ -> "[:crux.tx/put #{encoded}]"
    end
  end

  defp internal_put(id, value, valid_time) when is_map(value) do
    put = Map.put_new(value, :"crux.db/id", id)
    encoded = Eden.encode!(put)

    case Timex.format(valid_time, "{ISO:Extended}") do
      {:ok, time} -> String.replace("[:crux.tx/put #{encoded} #inst \"#{time}\"]", "+", "%2B")
      _ -> "[:crux.tx/put #{encoded}]"
    end
  end

  defp internal_put(id, value) when is_struct(value) do
    struct = Map.from_struct(value)
    put = Map.put_new(struct, :"crux.db/id", id)
    encoded = Eden.encode!(put)

    "[:crux.tx/put #{encoded}]"
  end

  defp internal_put(id, value) when is_map(value) do
    put = Map.put_new(value, :"crux.db/id", id)
    encoded = Eden.encode!(put)

    "[:crux.tx/put #{encoded}]"
  end

  @spec delete(atom | integer) :: <<_::64, _::_*8>>
  @doc """
  Creates a `tx_log::delete` with argument `id, valid_time`. Deletes a Document by `id` at a specific `valid_time`
  * `id` can be `atom` or `int`
  * `valid_time` is `DateTime` and optional

  ```elixir
  delete_date = Action.delete(:my_id, DateTime.from_naive!(~N[2020-10-10 13:26:08.003], "Etc/UTC"))

  delete_date == "[:crux.tx/delete :my_id #inst \"2020-10-10T13:26:08.003%2B00:00\"]"

  delete_no_date = Action.delete(:my_id)

  delete_no_date == == "[:crux.tx/delete :my_id]"
  ```
  """
  def delete(id) when is_atom(id) or is_integer(id) do
    id = Eden.encode!(id)

    "[:crux.tx/delete #{id}]"
  end

  @spec delete(
          atom | integer,
          any
        ) :: binary
  def delete(id, valid_time) when is_atom(id) or is_integer(id) do
    id = Eden.encode!(id)

    case Timex.format(valid_time, "{ISO:Extended}") do
      {:ok, time} -> String.replace("[:crux.tx/delete #{id} #inst \"#{time}\"]", "+", "%2B")
      _ -> "[:crux.tx/delete #{id}]"
    end
  end

  @spec match(atom | integer, any) :: <<_::64, _::_*8>>
  @doc """
  Creates a `tx_log::match` with argument `id, match, valid_time`
  * `id` can be `atom` or `int`
  * `match` matching edn
  * `valid_time` is `DateTime` and optional
  """
  def match(id, match) when is_atom(id) or is_integer(id) do
    id = Eden.encode!(id)

    "[:crux.tx/match #{id} #{match}]"
  end

  @spec match(
          atom | integer,
          any,
          any
        ) :: binary
  def match(id, match, valid_time) when is_atom(id) or is_integer(id) do
    id = Eden.encode!(id)

    case Timex.format(valid_time, "{ISO:Extended}") do
      {:ok, time} ->
        String.replace("[:crux.tx/match #{id} #{match} #inst \"#{time}\"]", "+", "%2B")

      _ ->
        "[:crux.tx/match #{id} #{match}]"
    end
  end

  @doc """
  Creates a `tx_log::evict` with argument `id`
  * `id` can be `atom` or `int`

  ```elixir
  evict = Action.evict(:hello)

  evict ==  "[:crux.tx/evict :hello]"
  ```
  """
  @spec evict(atom | integer) :: <<_::64, _::_*8>>
  def evict(id) when is_atom(id) or is_integer(id) do
    id = Eden.encode!(id)
    "[:crux.tx/evict #{id}]"
  end

  @doc """
  Creates a new `Action` list
  """
  @spec new :: pid
  def new do
    {:ok, pid} = Agent.start_link(fn -> [] end)
    pid
  end

  @doc """
  Adds a new `Action` (`put, delete, match, evict`) into the `Action Agent`

  ```elixir
  Action.add_action(Action.new(), Action.evict(:hello))
  Action.add_action(Action.new(), Action.delete(:hello))
  Action.add_action(Action.new(), Action.put(:hello, %{name: "hello", age: 4300000000}))
  ```
  """
  @spec add_action(pid, any) :: pid
  def add_action(pid, action) when is_pid(pid) do
    Agent.update(pid, fn n -> [action | n] end)
    pid
  end

  @doc """
  Generates the proper encoding for `Actions` present in `Action Agent`

  ```elixir
  actions =
      Action.new()
      |> Action.add_action(Action.evict(:hello))
      |> Action.add_action(
        Action.delete(:my_id, DateTime.from_naive!(~N[2020-10-10 13:26:08.003], "Etc/UTC"))
      )
      |> Action.add_action(
        Action.put(:hello, %{name: "hello", age: 4300000000})
      )
      |> Action.actions()

  actions == "[[:crux.tx/evict :hello] [:crux.tx/delete :my_id #inst \"2020-10-10T13:26:08.003%2B00:00\"]]"
  ```
  """
  @spec actions(pid) :: <<_::16, _::_*8>>
  def actions(pid) when is_pid(pid) do
    actions =
      Agent.get(pid, fn n -> n end)
      |> Enum.reverse()
      |> Enum.join(" ")

    "[#{actions}]"
  end
end
