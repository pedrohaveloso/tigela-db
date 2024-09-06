defmodule Tigela.Data.TransactionTest do
  use ExUnit.Case

  alias Tigela.Data
  alias Tigela.Data.Transaction

  setup do
    Transaction.start()
    :ok
  end

  doctest Transaction

  test "starting a transacction" do
    assert Transaction.start() == :ok
  end

  test "begin a new transaction increases level" do
    assert Transaction.level() == 0
    assert Transaction.begin() == :ok
    assert Transaction.level() == 1
    assert Transaction.begin() == :ok
    assert Transaction.level() == 2
  end

  test "committing a transaction" do
    assert Transaction.begin() == :ok
    assert Transaction.begin() == :ok
    assert Transaction.commit() == {:ok, nil}
    assert Transaction.level() == 1
    assert Transaction.commit() == {:ok, %{}}
    assert Transaction.level() == 0
  end

  test "rolling back a transaction" do
    assert Transaction.rollback() == {:error, "No active transaction"}
    assert Transaction.begin() == :ok
    assert Transaction.rollback() == :ok
    assert Transaction.level() == 0
  end

  test "setting and getting data within transactions" do
    data = %Data{key: "x", type: "string", value: "foo"}

    assert Transaction.get("x") == nil
    assert Transaction.set(data) == {:error, "No active transaction"}

    assert Transaction.begin() == :ok
    assert Transaction.set(data) == :ok
    assert Transaction.get("x") == %Data{key: "x", type: "string", value: "foo"}
  end

  test "data does not persist after rollback" do
    data = %Data{key: "x", type: "string", value: "foo"}

    assert Transaction.begin() == :ok
    assert Transaction.set(data) == :ok
    assert Transaction.get("x") == %Data{key: "x", type: "string", value: "foo"}
    assert Transaction.rollback() == :ok
    assert Transaction.get("x") == nil
  end

  test "data persists after commit" do
    data1 = %Data{key: "x", type: "string", value: "foo"}
    data2 = %Data{key: "y", type: "integer", value: "42"}

    assert Transaction.begin() == :ok
    assert Transaction.set(data1) == :ok
    assert Transaction.set(data2) == :ok
    assert Transaction.get("x") == %Data{key: "x", type: "string", value: "foo"}
    assert Transaction.get("y") == %Data{key: "y", type: "integer", value: "42"}

    assert Transaction.commit() ==
             {:ok,
              %{
                "x" => %{"type" => "string", "value" => "foo"},
                "y" => %{"type" => "integer", "value" => "42"}
              }}
  end

  test "nested transactions with commit and rollback" do
    data1 = %Data{key: "x", type: "string", value: "foo"}
    data2 = %Data{key: "y", type: "integer", value: "42"}

    assert Transaction.begin() == :ok
    assert Transaction.set(data1) == :ok

    assert Transaction.begin() == :ok
    assert Transaction.set(data2) == :ok
    assert Transaction.get("x") == %Data{key: "x", type: "string", value: "foo"}
    assert Transaction.get("y") == %Data{key: "y", type: "integer", value: "42"}

    assert Transaction.rollback() == :ok
    assert Transaction.get("x") == %Data{key: "x", type: "string", value: "foo"}
    assert Transaction.get("y") == nil
  end

  test "checking if a key exists" do
    data = %Data{key: "x", type: "string", value: "foo"}

    assert not Transaction.exists?("x")

    assert Transaction.begin() == :ok
    assert Transaction.set(data) == :ok
    assert Transaction.exists?("x")
  end
end
