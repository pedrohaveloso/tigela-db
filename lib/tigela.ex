defmodule Tigela do
  alias Tigela.Input
  alias Tigela.Data

  @prompt "> "

  def main(_) do
    IO.puts("--- Starting TigelaDB 0.0.1 ---")

    Data.Persistent.start()
    Data.Transaction.start()

    program()
  end

  def program() do
    command = IO.gets(@prompt) |> Input.Parser.command()

    case command do
      {:ok, value} ->
        command(value)
        |> case do
          {:ok, msg} -> IO.inspect(msg)
          {:error, reason} -> IO.puts("ERR \"#{reason}\"")
        end

      {:error, reason} ->
        IO.puts(reason)
    end

    program()
  end

  def command({:set, key, value}) do
    exists =
      if Data.Transaction.level() > 0 do
        exists = Data.Transaction.exists?(key)
        Data.Transaction.set(%Data{key: key, type: "string", value: value})
        if exists, do: true, else: Data.Persistent.exists?(key)
      else
        exists = Data.Persistent.exists?(key)
        Data.Persistent.set(%Data{key: key, type: "string", value: value})
        exists
      end

    {:ok, "#{exists} #{value}"}
  end

  def command({:get, key}) do
    value =
      if Data.Transaction.level() > 0 do
        Data.Transaction.get(key)
      else
        Data.Persistent.get(key)
      end

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
end
