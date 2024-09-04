defmodule Tigela do
  def main(_args) do
    Tigela.Transaction.start_link()

    Tigela.Transaction.begin()
    Tigela.Transaction.set("hello", "world")
    Tigela.Transaction.set("mal", "bem")
    Tigela.Transaction.begin()
    Tigela.Transaction.set("hello", "man")
    IO.puts(Tigela.Transaction.get("hello"))
    Tigela.Transaction.commit()
    content = Tigela.Transaction.commit()
    IO.inspect(content)
    IO.puts(Tigela.Transaction.get("hello"))

    # unless File.exists?("./tmp") do
    #   File.mkdir("./tmp")
    # end

    # unless File.exists?("./tmp/database") do
    #   File.mkdir("./tmp/database")
    # end

    # Tigela.State.start_link()

    # program()
  end

  @prompt ">"

  @set_command "SET"
  @set_syntax "#{@set_command} <key> <value>"

  @get_command "GET"
  @get_syntax "#{@get_command} <key>"

  @begin_command "BEGIN"
  @begin_syntax "#{@begin_command}"

  @rollback_command "ROLLBACK"
  @rollback_syntax "#{@rollback_command}"

  @commit_command "COMMIT"
  @commit_syntax "#{@commit_command}"

  def program() do
    read_command = IO.gets("#{@prompt} ") |> String.trim() |> String.split()
    command_name = read_command |> Enum.at(0, "") |> String.upcase()

    program()
  end

  def get_from_transaction(key) do
  end

  def get_from_persistent(key) do
  end
end
