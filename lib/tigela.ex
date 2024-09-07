defmodule Tigela do
  alias Tigela.Data
  alias Tigela.Parser
  alias Tigela.Processor

  @prompt "> "
  @title "———— TigelaDB (v0.0.1) ————"

  @spec main(any()) :: no_return()
  def main(_) do
    IO.puts(@title)

    Data.Persistent.start()
    Data.Transaction.start()

    program()
  end

  @spec program() :: no_return()
  defp program() do
    case IO.gets(@prompt) do
      :eof -> exit(:normal)
      {:error, _} -> puts_error("Unknown error")
      command -> process(command)
    end

    program()
  end

  @spec process(String.t()) :: {:error, String.t()} | {:ok, String.t()}
  def process(command) do
    with {:ok, parsed_command} <- Parser.command(command),
         {:ok, message} <- Processor.run_command(parsed_command) do
      puts_message(message)
      {:ok, message}
    else
      {:error, reason} ->
        puts_error(reason)
        {:error, reason}
    end
  end

  @doc false
  @spec puts_error(String.t()) :: :ok
  defp puts_error(reason) do
    IO.puts("ERR \"#{reason}\".")
  end

  @doc false
  @spec puts_message(String.t()) :: :ok
  defp puts_message(message) do
    IO.puts(message)
  end
end
