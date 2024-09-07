defmodule TigelaTest do
  use ExUnit.Case

  alias Tigela.Data.{Transaction, Persistent}

  setup do
    File.rm_rf("./tmp/tigela_db/")

    Persistent.start()
    Transaction.start()

    :ok
  end

  doctest Tigela

  test "SET command with integer value" do
    assert {:ok, "FALSE 10"} = Tigela.process("SET integer_key 10")
  end

  test "SET command with string value without spaces" do
    assert {:ok, "FALSE simple"} = Tigela.process("SET string_key simple")
  end

  test "SET command with string value with spaces" do
    assert {:ok, "FALSE \"string with spaces\""} =
             Tigela.process("SET spaced_key \"string with spaces\"")
  end

  test "SET command with string containing double quotes" do
    assert {:ok, "FALSE \"string \\\"with quotes\\\"\""} =
             Tigela.process("SET quotes_key \"string \\\"with quotes\\\"\"")
  end

  test "SET command with boolean TRUE value" do
    assert {:ok, "FALSE TRUE"} = Tigela.process("SET bool_key TRUE")
  end

  test "SET command with boolean FALSE value" do
    assert {:ok, "FALSE FALSE"} = Tigela.process("SET bool_key_false FALSE")
  end

  test "SET command with key containing spaces" do
    assert {:ok, "FALSE 20"} = Tigela.process("SET 'key with spaces' 20")
  end

  test "SET command with string that looks like an integer" do
    assert {:ok, "FALSE \"101\""} = Tigela.process("SET string_like_integer \"101\"")
  end

  test "SET command with special key characters" do
    assert {:ok, "FALSE 50"} = Tigela.process("SET 'special!@#$%^&*()_+=' 50")
  end

  test "GET command retrieves integer value" do
    Tigela.process("SET int_key 42")

    assert {:ok, "42"} = Tigela.process("GET int_key")
  end

  test "GET command retrieves string value" do
    Tigela.process("SET string_key \"Hello World\"")

    assert {:ok, "\"Hello World\""} = Tigela.process("GET string_key")
  end

  test "GET command retrieves boolean value" do
    Tigela.process("SET bool_key TRUE")

    assert {:ok, "TRUE"} = Tigela.process("GET bool_key")
  end

  test "GET command for key with spaces" do
    Tigela.process("SET 'key with spaces' 100")

    assert {:ok, "100"} = Tigela.process("GET 'key with spaces'")
  end

  test "GET command for key with special characters" do
    Tigela.process("SET 'special key!@#' 123")

    assert {:ok, "123"} = Tigela.process("GET 'special key!@#'")
  end

  test "SET and GET with complex string keys" do
    Tigela.process("SET 'complex \"key\"' \"complex value\"")

    assert {:ok, "\"complex value\""} = Tigela.process("GET 'complex \"key\"'")
  end

  test "SET command with improperly escaped string should return syntax error" do
    assert {:error, "SET <key> <value> - Syntax error"} =
             Tigela.process("SET key \"bad \"escaping\"")
  end

  test "GET command for non-existent complex key" do
    assert {:ok, "NIL"} = Tigela.process("GET 'non-existent \"key\"'")
  end

  test "GET command for non-existent key with spaces" do
    assert {:ok, "NIL"} = Tigela.process("GET 'non existent key'")
  end

  test "NIL value cannot be entered" do
    assert {:error, "NIL value cannot be entered"} = Tigela.process("SET key NIL")
  end

  test "BEGIN command to start transaction" do
    assert {:ok, 1} = Tigela.process("BEGIN")
  end

  test "Nested BEGIN commands" do
    Tigela.process("BEGIN")

    assert {:ok, 2} = Tigela.process("BEGIN")
  end

  test "ROLLBACK command in transaction" do
    Tigela.process("BEGIN")
    Tigela.process("SET trans_key 100")

    assert {:ok, 0} = Tigela.process("ROLLBACK")
    assert {:ok, "NIL"} = Tigela.process("GET trans_key")
  end

  test "ROLLBACK on transaction level 0 should return error" do
    assert {:error, "No active transaction"} = Tigela.process("ROLLBACK")
  end

  test "COMMIT command to apply transaction" do
    Tigela.process("BEGIN")
    Tigela.process("SET trans_key 200")

    assert {:ok, 0} = Tigela.process("COMMIT")
    assert {:ok, "200"} = Tigela.process("GET trans_key")
  end

  test "Nested transactions and COMMIT behavior" do
    Tigela.process("BEGIN")
    Tigela.process("SET nested_key 300")
    Tigela.process("BEGIN")
    Tigela.process("SET inner_key 400")

    assert {:ok, 1} = Tigela.process("COMMIT")
    assert {:ok, "400"} = Tigela.process("GET inner_key")
    assert {:ok, "300"} = Tigela.process("GET nested_key")
  end

  test "Nested transactions and ROLLBACK behavior" do
    Tigela.process("BEGIN")
    Tigela.process("SET nested_key 500")
    Tigela.process("BEGIN")
    Tigela.process("SET inner_key 600")

    assert {:ok, 1} = Tigela.process("ROLLBACK")
    assert {:ok, "NIL"} = Tigela.process("GET inner_key")
    assert {:ok, "500"} = Tigela.process("GET nested_key")
  end

  test "SET with invalid syntax" do
    assert {:error, "SET <key> <value> - Syntax error"} = Tigela.process("SET key_only")
  end

  test "GET with extra arguments should return error" do
    assert {:error, "GET <key> - Syntax error"} = Tigela.process("GET key extra_arg")
  end

  test "Unsupported command should return error" do
    assert {:error, "No command TRY."} = Tigela.process("TRY")
  end

  test "COMMIT on transaction level 0 should return error" do
    assert {:error, "No active transaction"} = Tigela.process("COMMIT")
  end
end
