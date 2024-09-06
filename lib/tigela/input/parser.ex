defmodule Tigela.Input.Parser do
  @commands ["BEGIN", "COMMIT", "ROLLBACK", "GET", "SET"]

  @key_regex "(?:'((?:\\\\'|[^'])*)'|(\\S+))"
  @value_regex "(?:(\"(?:\\\"|[^\"])+\")|(\\d+(?:\\.\\d+)?|TRUE|FALSE|\\S+))"

  @get_regex "^GET\\s+#{@key_regex}$"
  @set_regex "^SET\\s+#{@key_regex}\\s+#{@value_regex}$"

  @doc """

  ## Examples

      iex> Tigela.Input.Parser.command("SETA x 10")
      {:error, "No command SETA. Did you mean SET?"}
      iex> Tigela.Input.Parser.command("SET x 10")
      {:ok, {:set, %Tigela.Data{key: "x", type: "integer", value: "10"}}}
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
  @spec command(binary()) ::
          {:error, String.t()}
          | {:ok, {atom()} | {:get, String.t()} | {:set, Tigela.Data.t()}}
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

  defp parse_command(input, "SET") do
    @set_regex
    |> Regex.compile!()
    |> Regex.run(input)
    # TODO: improve this case.
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
    # TODO: improve this case.
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

  @spec no_command(String.t()) :: {:error, String.t()}
  defp no_command(command) do
    most_similar = command |> String.upcase() |> most_similar_command()

    most_similar_message =
      if is_nil(most_similar) do
        ""
      else
        "Did you mean #{most_similar}?"
      end

    {:error, "No command #{command}. #{most_similar_message}"}
  end

  @spec parse_set_value(String.t(), String.t()) ::
          {:ok, {atom(), Tigela.Data.t()}} | {:error, String.t()}
  defp parse_set_value(_, "NIL"), do: {:error, "NIL value cannot be entered"}

  defp parse_set_value(key, value) do
    type =
      cond do
        value == "TRUE" or value == "FALSE" -> "boolean"
        Integer.parse(value) != :error -> "integer"
        Float.parse(value) != :error -> "float"
        true -> "string"
      end

    {:ok, {:set, %Tigela.Data{key: key, type: type, value: value}}}
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
