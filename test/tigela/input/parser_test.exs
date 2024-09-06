defmodule Tigela.Input.ParserTest do
  use ExUnit.Case

  alias Tigela.Input.Parser

  doctest Parser

  describe "command/1" do
    test "parses BEGIN command" do
      assert {:ok, {:begin}} = Parser.command("BEGIN")
    end

    test "parses COMMIT command" do
      assert {:ok, {:commit}} = Parser.command("COMMIT")
    end

    test "parses ROLLBACK command" do
      assert {:ok, {:rollback}} = Parser.command("ROLLBACK")
    end

    test "parses GET command" do
      assert {:ok, {:get, "x"}} = Parser.command("GET x")
      assert {:ok, {:get, "complex key"}} = Parser.command("GET 'complex key'")
    end

    test "parses SET command with various types" do
      assert {:ok, {:set, %Tigela.Data{key: "x", type: "integer", value: "10"}}} =
               Parser.command("SET x 10")

      assert {:ok, {:set, %Tigela.Data{key: "y", type: "float", value: "3.14"}}} =
               Parser.command("SET y 3.14")

      assert {:ok, {:set, %Tigela.Data{key: "z", type: "boolean", value: "TRUE"}}} =
               Parser.command("SET z TRUE")

      assert {:ok, {:set, %Tigela.Data{key: "str", type: "string", value: "hello"}}} =
               Parser.command("SET str hello")

      assert {:ok,
              {:set, %Tigela.Data{key: "complex key", type: "string", value: "\"complex value\""}}} =
               Parser.command("SET 'complex key' \"complex value\"")
    end

    test "returns error for invalid commands" do
      assert {:error, "No command SETA. Did you mean SET?"} = Parser.command("SETA x 10")
      assert {:error, "No command FOO. "} = Parser.command("FOO")
    end

    test "returns error for syntax errors" do
      assert {:error, "SET <key> <value> - Syntax error"} = Parser.command("SET x")
      assert {:error, "GET <key> - Syntax error"} = Parser.command("GET x y")
      assert {:error, "BEGIN - Syntax error"} = Parser.command("BEGIN transaction")
    end

    test "returns error for NIL value" do
      assert {:error, "NIL value cannot be entered"} = Parser.command("SET x NIL")
    end
  end
end
