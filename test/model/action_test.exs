defmodule Model.ActionsTest do
  use ExUnit.Case
  doctest Translixir
  alias Translixir.Model.Action

  test "Put returns correct value without date" do
    actual = Action.put(:my_id, %{first_name: "test", last_name: "wow"})
    expected = "[:crux.tx/put {:crux.db/id :my_id, :first_name \"test\", :last_name \"wow\"}]"
    assert actual == expected
  end

  test "Put returns correct value with date" do
    actual =
      Action.put(
        :my_id,
        %{first_name: "test", last_name: "wow"},
        DateTime.from_naive!(~N[2020-10-10 13:26:08.003], "Etc/UTC")
      )

    expected =
      "[:crux.tx/put {:crux.db/id :my_id, :first_name \"test\", :last_name \"wow\"} #inst \"2020-10-10T13:26:08.003%2B00:00\"]"

    assert actual == expected
  end

  test "Delete returns correct value without date" do
    actual = Action.delete(:my_id)
    expected = "[:crux.tx/delete :my_id]"
    assert actual == expected
  end

  test "Delete returns correct value with date" do
    actual = Action.delete(:my_id, DateTime.from_naive!(~N[2020-10-10 13:26:08.003], "Etc/UTC"))
    expected = "[:crux.tx/delete :my_id #inst \"2020-10-10T13:26:08.003%2B00:00\"]"
    assert actual == expected
  end

  test "Evict ids" do
    assert Action.evict(3) == "[:crux.tx/evict 3]"
    assert Action.evict(:my_id) == "[:crux.tx/evict :my_id]"
  end

  test "Build actions" do
    actions =
      Action.new()
      |> Action.add_action(Action.evict(:hello))
      |> Action.add_action(
        Action.delete(:my_id, DateTime.from_naive!(~N[2020-10-10 13:26:08.003], "Etc/UTC"))
      )
      |> Action.actions()

    assert actions ==
             "[[:crux.tx/evict :hello] [:crux.tx/delete :my_id #inst \"2020-10-10T13:26:08.003%2B00:00\"]]"
  end
end
