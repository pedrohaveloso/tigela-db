defmodule Tigela.Transaction do
  use Agent

  defstruct level: 0, transactions: []

  @spec start_link() :: {:error, any()} | {:ok, pid()}
  def start_link() do
    Agent.start_link(
      fn -> %Tigela.Transaction{} end,
      name: __MODULE__
    )
  end

  def begin() do
    Agent.update(__MODULE__, fn map ->
      Map.put(map, :level, Map.get(map, :level, 0) + 1)
      |> Map.put(:transactions, Map.get(map, :transactions, []) ++ [%{}])
    end)
  end

  def rollback() do
    if level() > 0 do
      Agent.update(__MODULE__, fn map ->
        level = Map.get(map, :level, 1)

        Map.put(map, :level, level - 1)
        |> Map.put(
          :transactions,
          Enum.take(Map.get(map, :transactions, []), level - 1)
        )
      end)
    end
  end

  @spec level() :: integer()
  def level() do
    Agent.get(__MODULE__, fn map -> Map.get(map, :level) end)
  end

  @spec get(Map.key()) :: Map.value()
  def get(key) do
    get(level() - 1, key)
  end

  defp get(level, key) do
    value =
      Agent.get(
        __MODULE__,
        fn map ->
          Map.get(map, :transactions, [])
          |> Enum.at(level, %{})
          |> Map.get(key, nil)
        end
      )

    cond do
      level > 0 && value == nil -> get(level - 1, key)
      true -> value
    end
  end

  @spec set(Map.key(), Map.value()) :: :ok
  def set(key, value) do
    level = level() - 1

    Agent.update(__MODULE__, fn map ->
      transactions =
        Map.get(map, :transactions, [])
        |> List.update_at(level, fn last ->
          Map.put(last, key, value)
        end)

      Map.put(map, :transactions, transactions)
    end)
  end
end
