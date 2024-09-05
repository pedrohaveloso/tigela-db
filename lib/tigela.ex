defmodule Tigela do
  def main(_) do
    parse("SET 'x x' \"name world\"")
    |> IO.inspect()

    parse("SET 'x x' name")
    |> IO.inspect()

    parse("SET 'x' \"name world\"")
    |> IO.inspect()

    parse("SET x 10")
    |> IO.inspect()

    parse("SET z TRUE")
    |> IO.inspect()

    parse("SET x x x x x FALSE")
    |> IO.inspect()
  end

  @set_command_regex ~r/^SET\s+(?:'([^']+)'|(\S+))\s+(?:"([^"]+)"|(\d+(?:\.\d+)?|TRUE|FALSE|\S+))$/

  def parse(input) do
    case Regex.run(@set_command_regex, input) do
      [_, key, "", value, ""] ->
        parse_value(key, value)

      [_, "", key, value, ""] ->
        parse_value(key, value)

      [_, key, "", "", value] ->
        parse_value(key, value)

      [_, "", key, "", value] ->
        parse_value(key, value)

      [_, key, "", value] ->
        parse_value(key, value)

      value ->
        IO.inspect(value)
        # IO.puts(a)
        # IO.puts(b)
        # IO.puts(c)
        # IO.puts(d)
        # IO.puts(e)

        {:error, "invalid"}
    end
  end

  defp parse_value(key, value) do
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

    {:ok, key, parsed_value}
  end
end
