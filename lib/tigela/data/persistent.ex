defmodule Tigela.Data.Persistent do
  @moduledoc """
  Persists key/value data in files.

  ## Examples

      iex> Tigela.Data.Transaction.start()
      :ok
  """

  @data_dir "./tmp/tigela_db/data"

  @write_file_error "Failed to write file"
  @delete_file_error "Failed to delete file"

  @doc """
  Performs operations necessary for data persistence to work.

  ## Examples

      iex> Tigela.Data.Persistent.start()
      :ok
  """
  @spec start() :: :ok
  def start() do
    File.mkdir_p!(@data_dir)

    :ok
  end

  @doc """
  Gets a value from persistent storage.

  ## Examples

      iex> Tigela.Data.Persistent.start()
      :ok
      iex> Tigela.Data.Persistent.get("x")
      nil
      iex> Tigela.Data.Persistent.set("x", "20")
      :ok
      iex> Tigela.Data.Persistent.get("x")
      "20"
  """
  @spec get(String.t()) :: String.t() | nil
  def get(key) when is_binary(key) do
    case File.read(file_path(key)) do
      {:ok, content} -> content
      {:error, _} -> nil
    end
  end

  @doc """
  Sets/updates a key/value in persistent storage.

  ## Examples

      iex> Tigela.Data.Persistent.start()
      :ok
      iex> Tigela.Data.Persistent.set("x", "20")
      :ok
      iex> Tigela.Data.Persistent.set("x", "10")
      :ok
  """
  @spec set(String.t(), String.t()) :: :ok | {:error, String.t()}
  def set(key, value) when is_binary(key) and is_binary(value) do
    case File.write(file_path(key), value) do
      :ok -> :ok
      {:error, _} -> {:error, @write_file_error}
    end
  end

  @doc """
  Deletes a key/value from persistent storage.

  ## Examples

      iex> Tigela.Data.Persistent.start()
      :ok
      iex> Tigela.Data.Persistent.set("x", "20")
      :ok
      iex> Tigela.Data.Persistent.delete("x")
      :ok
  """
  @spec delete(String.t()) :: :ok | {:error, String.t()}
  def delete(key) when is_binary(key) do
    case File.rm(file_path(key)) do
      :ok -> :ok
      {:error, _} -> {:error, @delete_file_error}
    end
  end

  @doc false
  @spec file_path(String.t()) :: String.t()
  defp file_path(key), do: "#{@data_dir}/#{key}"
end
