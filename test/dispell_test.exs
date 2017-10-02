defmodule DispellTest do
  use ExUnit.Case
  doctest Dispell

  test "greets the world" do
    assert Dispell.hello() == :world
  end
end
