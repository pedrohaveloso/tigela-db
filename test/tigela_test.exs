defmodule TigelaTest do
  use ExUnit.Case
  doctest Tigela

  test "greets the world" do
    assert Tigela.hello() == :world
  end
end
