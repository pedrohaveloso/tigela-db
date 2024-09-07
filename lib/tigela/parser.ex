defmodule Tigela.Parser do
  @moduledoc """
  It analyses and parses input commands, converting them into internal
  structures.
  """

  @commands ["BEGIN", "COMMIT", "ROLLBACK", "GET", "SET"]

  @key_regex "(?:'((?:\\\\'|[^'])*)'|(\\S+))"
  @value_regex "(?:(\"(?:\\\\\"|[^\"])+\")|(\\d+(?:\\.\\d+)?|TRUE|FALSE|\\S+))"

  @get_regex "^GET\\s+#{@key_regex}$"
  @set_regex "^SET\\s+#{@key_regex}\\s+#{@value_regex}$"

  @doc """
  Analyses and interprets an input command.

  ## Examples

      iex> Tigela.Parser.command("SET x 10")
      {:ok, {:set, %Tigela.Data.Model{key: "x", type: "integer", value: "10"}}}
      iex> Tigela.Parser.command("GET x")
      {:ok, {:get, "x"}}
      iex> Tigela.Parser.command("BEGIN")
      {:ok, {:begin}}
      iex> Tigela.Parser.command("ROLLBACK")
      {:ok, {:rollback}}
      iex> Tigela.Parser.command("COMMIT")
      {:ok, {:commit}}
  """
  @spec command(binary()) :: {:ok, tuple()} | {:error, String.t()}
  def command(input) when is_binary(input) do
    input = String.trim(input)

    command =
      input
      |> String.split(" ")
      |> List.first()

    if Enum.member?(@commands, command),
      do: parse_command(input, command),
      else: no_command(command)
  end

  @doc false
  @spec parse_command(String.t(), String.t()) :: tuple()
  defp parse_command(input, "SET") do
    @set_regex
    |> Regex.compile!()
    |> Regex.run(input)
    # TODO: improve this:
    |> case do
      [_, key, "", value, ""] -> parse_set_value(key, value)
      [_, "", key, value, ""] -> parse_set_value(key, value)
      [_, key, "", "", value] -> parse_set_value(key, value)
      [_, "", key, "", value] -> parse_set_value(key, value)
      [_, key, "", value] -> parse_set_value(key, value)
      [_, "", key, value] -> parse_set_value(key, value)
      _ -> {:error, "SET <key> <value> - Syntax error"}
    end
  end

  defp parse_command(input, "GET") do
    @get_regex
    |> Regex.compile!()
    |> Regex.run(input)
    |> case do
      [_, key] -> {:ok, {:get, key}}
      [_, _, key] -> {:ok, {:get, key}}
      _ -> {:error, "GET <key> - Syntax error"}
    end
  end

  defp parse_command(input, command) do
    if input == command do
      {:ok, {command |> String.downcase() |> String.to_atom()}}
    else
      {:error, "#{command} - Syntax error"}
    end
  end

  @doc false
  @spec no_command(String.t()) :: {:error, String.t()}
  defp no_command(command) do
    most_similar = command |> String.upcase() |> most_similar_command()

    most_similar_message =
      if is_nil(most_similar), do: "", else: ". Did you mean #{most_similar}?"

    {:error, "No command #{command}#{most_similar_message}"}
  end

  @doc false
  @spec most_similar_command(String.t()) :: String.t() | nil
  defp most_similar_command(input) do
    @commands
    |> Enum.map(fn cmd -> {cmd, String.jaro_distance(cmd, input)} end)
    |> Enum.max_by(fn {_, distance} -> distance end)
    |> then(fn {cmd, distance} -> if distance > 0.5, do: cmd, else: nil end)
  end

  @doc false
  @spec parse_set_value(String.t(), String.t()) :: {:error, String.t()}
  defp parse_set_value(_, "NIL"), do: {:error, "NIL value cannot be entered"}

  @doc false
  @spec parse_set_value(String.t(), String.t()) :: {:ok, tuple()}
  defp parse_set_value(key, value) do
    type =
      cond do
        value in ["TRUE", "FALSE"] -> "boolean"
        match?({_, ""}, Integer.parse(value)) -> "integer"
        match?({_, ""}, Float.parse(value)) -> "float"
        true -> "string"
      end

    {:ok, {:set, %Tigela.Data.Model{key: key, type: type, value: value}}}
  end
end
