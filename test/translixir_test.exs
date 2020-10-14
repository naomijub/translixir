defmodule TranslixirTest do
  use ExUnit.Case
  doctest Translixir

  test "greets the world" do
    assert Translixir.hello() == :world
  end
end
