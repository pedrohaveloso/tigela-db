defmodule Tigela.ProcessorTest do
  use ExUnit.Case

  alias Tigela.Processor
  alias Tigela.Data.{Model, Transaction, Persistent}

  setup do
    File.rm_rf("./tmp/tigela_db/")

    Persistent.start()
    Transaction.start()

    :ok
  end

  doctest Processor

  test "run_command/1 with :set and no existing key" do
    data = %Model{key: "x", type: "string", value: "foo"}

    assert {:ok, "FALSE foo"} = Processor.run_command({:set, data})
    assert Persistent.exists?("x")
    assert Persistent.get("x").value == "foo"
  end

  test "run_command/1 with :set and existing key" do
    Persistent.set(%Model{key: "x", type: "string", value: "foo"})
    data = %Model{key: "x", type: "string", value: "bar"}

    assert {:ok, "TRUE bar"} = Processor.run_command({:set, data})
    assert Persistent.exists?("x")
    assert Persistent.get("x").value == "bar"
  end

  test "run_command/1 with :get existing key" do
    Persistent.set(%Model{key: "x", type: "string", value: "foo"})

    assert {:ok, "foo"} = Processor.run_command({:get, "x"})
  end

  test "run_command/1 with :get non-existing key" do
    assert {:ok, "NIL"} = Processor.run_command({:get, "y"})
  end

  test "run_command/1 with :begin starts a transaction" do
    assert {:ok, 1} = Processor.run_command({:begin})
    assert Transaction.level() == 1
  end

  test "run_command/1 with :rollback rolls back the transaction" do
    Processor.run_command({:begin})
    Processor.run_command({:set, %Model{key: "x", type: "string", value: "foo"}})

    assert {:ok, 0} = Processor.run_command({:rollback})
    assert Persistent.get("x") == nil
  end

  test "run_command/1 with :rollback without transaction returns error" do
    assert {:error, _reason} = Processor.run_command({:rollback})
  end

  test "run_command/1 with :commit commits the transaction" do
    Processor.run_command({:begin})
    Processor.run_command({:set, %Model{key: "x", type: "string", value: "foo"}})

    assert {:ok, 0} = Processor.run_command({:commit})
    assert Persistent.get("x").value == "foo"
  end

  test "run_command/1 with :commit without transaction returns error" do
    assert {:error, _reason} = Processor.run_command({:commit})
  end
end
