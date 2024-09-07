defmodule Tigela.Data.PersistentTest do
  use ExUnit.Case

  alias Tigela.Data
  alias Tigela.Data.Persistent

  setup do
    File.rm_rf("./tmp/tigela_db/")

    Persistent.start()

    :ok
  end

  doctest Persistent

  test "get/1 returns nil for non-existent keys" do
    assert Persistent.get("non_existent") == nil
  end

  test "set/1 and get/1 work correctly" do
    data = %Data.Model{key: "x", type: "string", value: "foo"}
    assert :ok == Persistent.set(data)
    assert Persistent.get("x") == data
  end

  test "exists?/1 returns false for non-existent keys" do
    assert not Persistent.exists?("non_existent")
  end

  test "exists?/1 returns true for existing keys" do
    data = %Data.Model{key: "x", type: "string", value: "foo"}
    Persistent.set(data)

    assert Persistent.exists?("x")
  end

  test "delete/1 removes keys from storage" do
    data = %Data.Model{key: "x", type: "string", value: "foo"}
    Persistent.set(data)

    assert Persistent.exists?("x")
    assert :ok == Persistent.delete("x")
    assert not Persistent.exists?("x")
    assert Persistent.get("x") == nil
  end

  test "set/1 properly sanitizes keys and values" do
    data = %Data.Model{key: "weird[==λ==]key", type: "string", value: "weird[==λ==]value"}
    Persistent.set(data)

    sanitized_data = %Data.Model{key: "weird?key", type: "string", value: "weird?value"}
    assert Persistent.get("weird?key") == sanitized_data
  end

  test "multiple sets and gets are consistent" do
    data1 = %Data.Model{key: "x", type: "string", value: "foo"}
    data2 = %Data.Model{key: "y", type: "integer", value: "42"}

    Persistent.set(data1)
    Persistent.set(data2)

    assert Persistent.get("x") == data1
    assert Persistent.get("y") == data2
  end
end
