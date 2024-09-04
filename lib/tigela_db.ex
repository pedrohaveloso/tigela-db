defmodule TigelaDB do
  def main(_args) do
    program()
  end

  @prompt "> "

  @set_command "SET"
  @set_syntax "<key> <value>"

  @get_command "GET"
  @get_syntax "<key>"

  @begin_command "BEGIN"
  @rollback_command "ROLLBACK"
  @commit_command "COMMIT"

  def program() do
    unless File.exists?("./tmp") do
      File.mkdir("./tmp")
    end

    unless File.exists?("./tmp/database") do
      File.mkdir("./tmp/database")
    end

    read_command = IO.gets(@prompt) |> String.trim() |> String.split()
    command_name = read_command |> Enum.at(0, "") |> String.upcase()

    case command_name do
      @get_command -> get(tl(read_command))
      @set_command -> set(tl(read_command))
      "" -> puts_error("Empty command")
      _ -> puts_error("No command #{read_command}")
    end

    program()
  end

  @spec set(list()) :: :ok
  def set(arguments) do
    case Enum.count(arguments) do
      2 ->
        [key | value] = arguments
        set(key, value)

      _ ->
        puts_error("#{@set_command} #{@set_syntax}", :syntax)
    end
  end

  @spec set(String.t(), String.t()) :: :ok
  def set(key, value) do
    exists = if File.exists?("./tmp/database/#{key}"), do: "TRUE", else: "FALSE"

    File.write!("./tmp/database/#{key}", value)

    puts_msg("#{exists} #{value}")
  end

  @spec get(list()) :: :ok
  def get(arguments) when is_list(arguments) do
    case Enum.count(arguments) do
      1 -> get(hd(arguments))
      _ -> puts_error("#{@get_command} #{@get_syntax}", :syntax)
    end
  end

  @spec get(binary()) :: :ok
  def get(key) when is_binary(key) do
    case File.read("./tmp/database/#{key}") do
      {:ok, value} -> puts_msg(value)
      {:error, _} -> puts_msg("NIL")
    end
  end

  @spec puts_error(String.t(), :none | :syntax) :: :ok
  def puts_error(error, type \\ :none) do
    type_msg =
      case type do
        :syntax -> " - Syntax Error"
        _ -> ""
      end

    IO.puts("ERR \"#{error}#{type_msg}\"")
  end

  @spec puts_msg(String.t()) :: :ok
  def puts_msg(msg) do
    IO.puts(msg)
  end
end
