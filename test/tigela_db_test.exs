defmodule TigelaDBTest do
  use ExUnit.Case
  doctest TigelaDB

  test "greets the world" do
    assert TigelaDB.hello() == :world
  end
end
