defmodule Tigela.Processor do
  @moduledoc """
  Processes, manages and runs commands.
  """

  alias Tigela.Data

  @doc """
  Receives a parsed command and runs it. Returns a success or error message.

  ## Examples

      iex> data = %Tigela.Data.Model{key: "x", type: "string", value: "foo"}
      %Tigela.Data.Model{key: "x", type: "string", value: "foo"}
      iex> Tigela.Processor.run_command({:set, data})
      {:ok, "FALSE foo"}
  """
  @spec run_command(tuple()) :: {:ok | :error, String.t()}
  def run_command({:set, %Data.Model{key: key, type: type, value: value}}) do
    exists =
      if Data.Transaction.level() > 0 do
        exists = Data.Transaction.exists?(key) || Data.Persistent.exists?(key)
        Data.Transaction.set(%Data.Model{key: key, type: type, value: value})
        exists
      else
        exists = Data.Persistent.exists?(key)
        Data.Persistent.set(%Data.Model{key: key, type: type, value: value})
        exists
      end

    {:ok, "#{if exists, do: "TRUE", else: "FALSE"} #{value}"}
  end

  def run_command({:get, key}) do
    data =
      if Data.Transaction.level() > 0 do
        Data.Transaction.get(key) || Data.Persistent.get(key)
      else
        Data.Persistent.get(key)
      end

    value = if data == nil, do: "NIL", else: data.value

    {:ok, value}
  end

  def run_command({:begin}) do
    Data.Transaction.begin()
    {:ok, Data.Transaction.level()}
  end

  def run_command({:rollback}) do
    case Data.Transaction.rollback() do
      :ok -> {:ok, Data.Transaction.level()}
      {:error, reason} -> {:error, reason}
    end
  end

  def run_command({:commit}) do
    case Data.Transaction.commit() do
      {:ok, nil} ->
        {:ok, Data.Transaction.level()}

      {:ok, data} ->
        Enum.each(data, fn {key, %{"type" => type, "value" => value}} ->
          Data.Persistent.set(%Data.Model{key: key, type: type, value: value})
        end)

        {:ok, Data.Transaction.level()}

      {:error, reason} ->
        {:error, reason}
    end
  end
end
