defmodule Tigela.Transaction do
  @moduledoc """
  Implements an in-memory transaction system.

  Transactions can be nested, and the module supports handling key/value pairs
  within the context of these transactions.

  ## Examples

      iex> Tigela.Transaction.start()
      :ok
  """

  use Agent

  defstruct level: 0, stack: []

  @no_active_transaction_error "No active transaction"

  @doc """
  Initiates transaction state. It must be started before using any other
  function in the module.

  ## Examples

      iex> Tigela.Transaction.start()
      :ok
  """
  @spec start() :: :ok
  def start() do
    Agent.start_link(
      fn -> %Tigela.Transaction{} end,
      name: __MODULE__
    )

    :ok
  end

  @doc """
  Starts a new empty transaction and puts it on the stack.

  ## Examples

      iex> Tigela.Transaction.start()
      :ok
      iex> Tigela.Transaction.begin()
      :ok
  """
  @spec begin() :: :ok
  def begin() do
    update_state(fn state ->
      level = state.level + 1
      transactions = [%{} | state.stack]
      %Tigela.Transaction{state | level: level, stack: transactions}
    end)
  end

  @doc """
  ## Examples
  Rolls back a transaction, deleting all its data.

      iex> Tigela.Transaction.start()
      :ok
      iex> Tigela.Transaction.rollback()
      {:error, "No active transaction"}
      iex> Tigela.Transaction.begin()
      :ok
      iex> Tigela.Transaction.rollback()
      :ok
  """
  @spec rollback() :: :ok | {:error, String.t()}
  def rollback() do
    case level() do
      0 -> {:error, @no_active_transaction_error}
      _ -> perform_rollback()
    end
  end

  @doc """
  Commits the data of a transaction. It returns a map with the data if the
  transaction it commits is the last.

  ## Examples

      iex> Tigela.Transaction.start()
      :ok
      iex> Tigela.Transaction.commit()
      {:error, "No active transaction"}
      iex> Tigela.Transaction.begin()
      :ok
      iex> Tigela.Transaction.begin()
      :ok
      iex> Tigela.Transaction.commit()
      {:ok, nil}
      iex> Tigela.Transaction.commit()
      {:ok, %{}}
  """
  @spec commit() :: {:ok, map() | nil} | {:error, String.t()}
  def commit() do
    case level() do
      0 ->
        {:error, @no_active_transaction_error}

      1 ->
        {:ok, apply_changes()}

      _ ->
        merge_transactions()
        {:ok, nil}
    end
  end

  @doc false
  @spec apply_changes() :: map()
  defp apply_changes() do
    key_values = get_current_transaction()
    perform_rollback()
    key_values
  end

  @doc false
  @spec merge_transactions() :: :ok
  defp merge_transactions() do
    update_state(fn state ->
      [last_transaction | transactions] = state.stack
      [previous_transaction | transactions] = transactions

      merged_transaction = Map.merge(previous_transaction, last_transaction)

      %Tigela.Transaction{
        state
        | level: state.level - 1,
          stack: [merged_transaction | transactions]
      }
    end)
  end

  @doc """
  Returns the current transaction level (number of active transactions).

  ## Examples

      iex> Tigela.Transaction.start()
      :ok
      iex> Tigela.Transaction.level()
      0
      iex> Tigela.Transaction.begin()
      :ok
      iex> Tigela.Transaction.level()
      1
      iex> Tigela.Transaction.begin()
      :ok
      iex> Tigela.Transaction.level()
      2
      iex> Tigela.Transaction.commit()
      {:ok, nil}
      iex> Tigela.Transaction.level()
      1
  """
  @spec level() :: integer()
  def level() do
    get_state(fn state -> state.level end)
  end

  @doc """
  Gets a value from the transactions.

    ## Examples

      iex> Tigela.Transaction.start()
      :ok
      iex> Tigela.Transaction.get("x")
      nil
      iex> Tigela.Transaction.begin()
      :ok
      iex> Tigela.Transaction.set("x", "hello")
      :ok
      iex> Tigela.Transaction.get("x")
      "hello"
  """
  @spec get(String.t()) :: String.t() | nil
  def get(key) when is_binary(key) do
    level = level()

    case level do
      0 -> nil
      _ -> get(level(), 0, key)
    end
  end

  @doc false
  @spec get(integer(), integer(), String.t()) :: String.t() | nil
  defp get(level, index, key) do
    value =
      get_state(fn state ->
        state.stack
        |> Enum.at(index, %{})
        |> Map.get(key)
      end)

    if index >= level - 1 || !is_nil(value) do
      value
    else
      get(level, index + 1, key)
    end
  end

  @doc """
  Sets a key/value to the current transaction.

  ## Examples

      iex> Tigela.Transaction.start()
      :ok
      iex> Tigela.Transaction.set("x", "hello")
      {:error, "No active transaction"}
      iex> Tigela.Transaction.begin()
      :ok
      iex> Tigela.Transaction.set("x", "hello")
      :ok
  """
  @spec set(String.t(), String.t()) :: :ok | {:error, String.t()}
  def set(key, value) when is_binary(key) and is_binary(value) do
    case level() do
      0 ->
        {:error, @no_active_transaction_error}

      _ ->
        update_state(fn state ->
          updated_transactions =
            List.update_at(state.stack, 0, &Map.put(&1, key, value))

          %Tigela.Transaction{state | stack: updated_transactions}
        end)

        :ok
    end
  end

  @doc false
  @spec perform_rollback() :: :ok
  defp perform_rollback() do
    update_state(fn state ->
      new_level = state.level - 1
      new_transactions = tl(state.stack)
      %Tigela.Transaction{state | level: new_level, stack: new_transactions}
    end)
  end

  @doc false
  @spec update_state((%Tigela.Transaction{} -> %Tigela.Transaction{})) :: :ok
  defp update_state(fun) do
    Agent.update(__MODULE__, fun)
  end

  @doc false
  @spec get_state((%Tigela.Transaction{} -> a)) :: a when a: var
  defp get_state(fun) do
    Agent.get(__MODULE__, fun)
  end

  @doc false
  @spec get_current_transaction() :: map()
  defp get_current_transaction() do
    get_state(fn state ->
      List.first(state.stack, %{})
    end)
  end
end
