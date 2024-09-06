defmodule Tigela do
  alias Tigela.Input
  alias Tigela.Data

  @prompt "> "

  def main(_) do
    IO.puts("———— Starting TigelaDB (v0.0.1) ————")

    Data.Persistent.start()
    Data.Transaction.start()

    program()
  end

  def program() do
    case IO.gets(@prompt) do
      :eof ->
        exit("Bye bye")

      {:error, _} ->
        puts_error("Unknown error")

      command ->
        command
        |> Input.Parser.command()
        |> case do
          {:ok, value} ->
            case command(value) do
              {:ok, message} -> puts_message(message)
              {:error, reason} -> puts_error(reason)
            end

          {:error, reason} ->
            puts_error(reason)
        end
    end

    program()
  end

  def command({:set, %Tigela.Data{key: key, type: type, value: value}}) do
    exists =
      if Data.Transaction.level() > 0 do
        exists = Data.Transaction.exists?(key)
        Data.Transaction.set(%Data{key: key, type: type, value: value})
        if exists, do: true, else: Data.Persistent.exists?(key)
      else
        exists = Data.Persistent.exists?(key)
        Data.Persistent.set(%Data{key: key, type: type, value: value})
        exists
      end

    {:ok, "#{if exists, do: "TRUE", else: "FALSE"} #{value}"}
  end

  def command({:get, key}) do
    data =
      if Data.Transaction.level() > 0 do
        Data.Transaction.get(key)
      else
        Data.Persistent.get(key)
      end

    value = if data == nil, do: "NIL", else: data.value

    {:ok, value}
  end

  def command({:begin}) do
    Data.Transaction.begin()
    {:ok, Data.Transaction.level()}
  end

  def command({:rollback}) do
    case Data.Transaction.rollback() do
      :ok -> {:ok, Data.Transaction.level()}
      {:error, reason} -> {:error, reason}
    end
  end

  def command({:commit}) do
    case Data.Transaction.commit() do
      {:ok, nil} ->
        {:ok, Data.Transaction.level()}

      {:ok, data} ->
        Enum.each(data, fn {key, %{"type" => type, "value" => value}} ->
          Data.Persistent.set(%Data{key: key, type: type, value: value})
        end)

        {:ok, Data.Transaction.level()}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @spec puts_error(String.t()) :: :ok
  defp puts_error(reason) do
    IO.puts("ERR \"#{reason}\"")
  end

  @spec puts_message(String.t()) :: :ok
  defp puts_message(message) do
    IO.puts(message)
  end
end
