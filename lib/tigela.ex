defmodule Tigela do
  @moduledoc """
  Tigela is a key-value database designed to be used via command-line terminal
  with basic functions such as SET/GET and recursive transactions.

  This module receives user inputs and processes them according to the context.

  For more details on how to use it, please read the project's README.
  """

  alias Tigela.Data
  alias Tigela.Parser
  alias Tigela.Processor

  @prompt "> "
  @title "———— TigelaDB (v0.0.1) ————"

  @doc false
  @spec main(any()) :: no_return()
  def main(_) do
    IO.puts(@title)

    Data.Persistent.start()
    Data.Transaction.start()

    program()
  end

  @doc false
  @spec program() :: no_return()
  defp program() do
    case IO.gets(@prompt) do
      :eof -> exit(:normal)
      {:error, _} -> puts_error("Unknown error")
      command -> command |> process() |> response()
    end

    program()
  end

  @doc """
  Receives input commands, processes them, and performs the desired operation.

  ## Examples

      iex> Tigela.Data.Persistent.start()
      :ok
      iex> Tigela.Data.Transaction.start()
      :ok
      iex> Tigela.process("SET name Pedro")
      {:ok, "FALSE Pedro"}
      iex> Tigela.process("GET name")
      {:ok, "Pedro"}
  """
  @spec process(String.t()) :: {:error, String.t()} | {:ok, String.t()}
  def process(command) do
    with {:ok, parsed_command} <- Parser.command(command),
         {:ok, message} <- Processor.run_command(parsed_command) do
      {:ok, message}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  @doc false
  @spec response(tuple()) :: :ok
  defp response(response) do
    case response do
      {:ok, message} -> puts_message(message)
      {:error, reason} -> puts_error(reason)
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
