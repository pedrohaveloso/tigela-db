defmodule Tigela.Input.Parser do
  @commands ["BEGIN", "COMMIT", "ROLLBACK", "GET", "SET"]

  # @spec command(String.t()) :: any()
  @doc """

  ## Examples

      iex> Tigela.Input.Parser.command("SETA x 10")
      {:error, "No command SETA. Did you mean SET?"}
      iex> Tigela.Input.Parser.command("SET x 10")
      {:ok, {:set, "x", 10}}
      iex> Tigela.Input.Parser.command("SET x x 10")
      {:error, "SET <key> <value> - Syntax error"}
      iex> Tigela.Input.Parser.command("GET x")
      {:ok, {:get, "x"}}
      iex> Tigela.Input.Parser.command("BEGIN")
      {:ok, {:begin}}
      iex> Tigela.Input.Parser.command("ROLLBACK")
      {:ok, {:rollback}}
      iex> Tigela.Input.Parser.command("COMMIT")
      {:ok, {:commit}}
  """
  def command(input) when is_binary(input) do
    input = String.trim(input)

    command =
      input
      |> String.split(" ")
      |> List.first()
      |> String.upcase()

    case command do
      "SET" -> parse_command(input, "SET")
      "GET" -> parse_command(input, "GET")
      "BEGIN" -> parse_command(input, "BEGIN")
      "COMMIT" -> parse_command(input, "COMMIT")
      "ROLLBACK" -> parse_command(input, "ROLLBACK")
      _ -> no_command(command)
    end
  end

  defp parse_command(input, "SET") do
    case Regex.run(~r/^SET\s+(['"]?)([\w\s]+)\1\s+(['"]?)(.+)\3$/, input) do
      [_, _, key, _, value] -> {:ok, {:set, key, parse_value(value)}}
      _ -> {:error, "SET <key> <value> - Syntax error"}
    end
  end

  defp parse_command(input, "GET") do
    case Regex.run(~r/^GET\s+(['"]?)([\w\s]+)\1$/, input) do
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

  @spec no_command(String.t()) :: {:error, String.t()}
  defp no_command(command) do
    most_similar = most_similar_command(command)

    most_similar_message =
      if is_nil(most_similar) do
        ""
      else
        "Did you mean #{most_similar}?"
      end

    {:error, "No command #{command}. #{most_similar_message}"}
  end

  defp parse_value(value) do
    cond do
      value == "TRUE" -> true
      value == "FALSE" -> false
      Regex.match?(~r/^\d+$/, value) -> String.to_integer(value)
      true -> value
    end
  end

  @spec most_similar_command(String.t()) :: String.t() | nil
  defp most_similar_command(input) do
    {command, distance} =
      Enum.reduce(@commands, {nil, 0}, fn valid, {command, distance} ->
        current_distance = String.jaro_distance(valid, input)

        cond do
          command == nil -> {valid, current_distance}
          current_distance > distance -> {valid, current_distance}
          true -> {command, distance}
        end
      end)

    if distance > 0.5, do: command, else: nil
  end
end