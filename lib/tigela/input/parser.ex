defmodule Tigela.Input.Parser do
  @commands ["BEGIN", "COMMIT", "ROLLBACK", "GET", "SET"]

  @key_regex "(?:'((?:\\\\'|[^'])*)'|(\\S+))"
  @value_regex "(?:\"((?:\\\"|[^\"])+)\"|(\\d+(?:\\.\\d+)?|TRUE|FALSE|\\S+))"

  @get_regex "^GET\\s+#{@key_regex}$"
  @set_regex "^SET\\s+#{@key_regex}\\s+#{@value_regex}$"

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
    # TODO...
    regex = Regex.compile!(@set_regex)

    case Regex.run(regex, input) do
      [_, key, "", value, ""] ->
        parse_set_value(key, value)

      [_, "", key, value, ""] ->
        parse_set_value(key, value)

      [_, key, "", "", value] ->
        parse_set_value(key, value)

      [_, "", key, "", value] ->
        parse_set_value(key, value)

      [_, key, "", value] ->
        parse_set_value(key, value)

      _ ->
        {:error, "SET <key> <value> - Syntax error"}
    end
  end

  defp parse_command(input, "GET") do
    # TODO...
    regex = Regex.compile!(@get_regex)

    case Regex.run(regex, input) do
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

  defp parse_set_value(key, value) do
    parsed_value =
      case value do
        "TRUE" ->
          true

        "FALSE" ->
          false

        value when is_binary(value) ->
          case Integer.parse(value) do
            {int_value, ""} ->
              int_value

            _ ->
              case Float.parse(value) do
                {float_value, ""} -> float_value
                _ -> value
              end
          end
      end

    {:ok, {:set, key, parsed_value}}
  end

  # defp parse_value(value) do
  #   cond do
  #     value == "TRUE" -> true
  #     value == "FALSE" -> false
  #     Regex.match?(~r/^\d+$/, value) -> String.to_integer(value)
  #     true -> value
  #   end
  # end

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
