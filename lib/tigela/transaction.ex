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

  @spec begin() :: :ok
  def begin() do
    update_state(fn state ->
      level = Map.get(state, :level, 0) + 1
      transactions = Map.get(state, :transactions, []) ++ [%{}]

      state
      |> Map.put(:level, level)
      |> Map.put(:transactions, transactions)
    end)
  end

  @spec rollback() :: :ok
  def rollback() do
    level = level()

    if level > 0 do
      rollback(level)
    end

    :ok
  end

  defp rollback(level) do
    update_state(fn state ->
      level = level - 1

      state
      |> Map.put(:level, level)
      |> Map.update(:transactions, [], &Enum.take(&1, level))
    end)
  end

  def commit() do
    level = level()

    if level > 1 do
      update_state(fn state ->
        state
        |> Map.update(:transactions, [], fn transactions ->
          [
            last_transaction,
            previous_transaction
            | transactions
          ] = Enum.reverse(transactions)

          transaction = Map.merge(previous_transaction, last_transaction)

          transactions ++ [transaction]
        end)
        |> Map.put(:level, level - 1)
      end)
    else
      key_values =
        get_state(fn state ->
          state |> Map.get(:transactions) |> Enum.at(0)
        end)

      rollback()

      key_values
    end
  end

  @spec level() :: integer()
  def level() do
    get_state(fn state -> Map.get(state, :level) end)
  end

  @spec get(Map.key()) :: Map.value()
  def get(key) do
    get(level() - 1, key)
  end

  defp get(level, key) do
    value =
      get_state(fn state ->
        state
        |> Map.get(:transactions, [])
        |> Enum.at(level, %{})
        |> Map.get(key)
      end)

    if level > 0 && is_nil(value) do
      get(level - 1, key)
    else
      value
    end
  end

  @spec set(Map.key(), Map.value()) :: :ok
  def set(key, value) do
    level = level() - 1

    update_state(fn state ->
      state
      |> Map.update(:transactions, [], fn transactions ->
        List.update_at(transactions, level, &Map.put(&1, key, value))
      end)
    end)
  end

  @spec update_state(fun()) :: :ok
  defp update_state(fun) do
    Agent.update(__MODULE__, fun)
  end

  @spec get_state((Agent.state() -> a)) :: a when a: var
  defp get_state(fun) do
    Agent.get(__MODULE__, fun)
  end
end
