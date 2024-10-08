defmodule Tigela.Data.Persistent do
  @moduledoc """
  Persists key/value data in files.

  ## Examples

      iex> Tigela.Data.Transaction.start()
      :ok
  """

  @data_dir "./tmp/tigela_db"
  @data_file "./tmp/tigela_db/data.tdb"
  @data_file_regex ~r/^\[([^\]]+)\](.+)\[==λ==\](.+)$/

  @doc """
  Performs operations necessary for data persistence to work.

  ## Examples

      iex> Tigela.Data.Persistent.start()
      :ok
  """
  @spec start() :: :ok
  def start() do
    File.mkdir_p(@data_dir)

    :ok
  end

  @doc """
  Gets a value from persistent storage.

  ## Examples

      iex> Tigela.Data.Persistent.start()
      :ok
      iex> Tigela.Data.Persistent.get("x")
      nil
      iex> Tigela.Data.Persistent.set(%Tigela.Data.Model{key: "x", type: "string", value: "foo"})
      :ok
      iex> Tigela.Data.Persistent.get("x")
      %Tigela.Data.Model{key: "x", type: "string", value: "foo"}
  """
  @spec get(String.t()) :: Tigela.Data.Model.t() | nil
  def get(key) when is_binary(key) do
    data =
      read_data_file()
      |> Map.get(key, nil)

    case data do
      nil -> nil
      _ -> %Tigela.Data.Model{key: key, type: data["type"], value: data["value"]}
    end
  end

  @doc """
  Sets/updates a key/value in persistent storage.

  ## Examples

      iex> Tigela.Data.Persistent.start()
      :ok
      iex> Tigela.Data.Persistent.set(%Tigela.Data.Model{key: "x", type: "string", value: "foo"})
      :ok
  """
  @spec set(Tigela.Data.Model.t()) :: :ok | {:error, atom()}
  def set(data) do
    data = filter_set_data(data)

    read_data_file()
    |> Map.put(data.key, %{"type" => data.type, "value" => data.value})
    |> write_data_file()
  end

  @spec set(Tigela.Data.Model.t()) :: Tigela.Data.Model.t()
  defp filter_set_data(data) do
    data
    |> Map.put(:key, String.replace(data.key, "[==λ==]", "?"))
    |> Map.put(:value, String.replace(data.value, "[==λ==]", "?"))
  end

  @doc """
  Informs whether a key exists.

  ## Examples

      iex> Tigela.Data.Persistent.start()
      :ok
      iex> Tigela.Data.Persistent.exists?("x")
      false
      iex> Tigela.Data.Persistent.set(%Tigela.Data.Model{key: "x", type: "string", value: "foo"})
      :ok
      iex> Tigela.Data.Persistent.exists?("x")
      true
  """
  @spec exists?(String.t()) :: boolean()
  def exists?(key) when is_binary(key) do
    read_data_file()
    |> Map.has_key?(key)
  end

  @doc """
  Deletes a key/value from persistent storage.

  ## Examples

      iex> Tigela.Data.Persistent.start()
      :ok
      iex> Tigela.Data.Persistent.set(%Tigela.Data.Model{key: "x", type: "string", value: "foo"})
      :ok
      iex> Tigela.Data.Persistent.delete("x")
      :ok
  """
  @spec delete(String.t()) :: :ok
  def delete(key) when is_binary(key) do
    read_data_file()
    |> Map.delete(key)
    |> write_data_file()

    :ok
  end

  @doc false
  @spec read_data_file() :: map()
  defp read_data_file() do
    case File.read(@data_file) do
      {:ok, content} ->
        content
        |> String.split("\n", trim: true)
        |> Enum.reduce(%{}, fn line, acc ->
          case Regex.run(@data_file_regex, line) do
            [_, type, key, value] ->
              Map.put(acc, key, %{"type" => type, "value" => value})

            _ ->
              acc
          end
        end)

      _ ->
        %{}
    end
  end

  @doc false
  @spec write_data_file(map()) :: :ok | {:error, atom()}
  defp write_data_file(content) do
    content =
      content
      |> Enum.map(fn {key, %{"type" => type, "value" => value}} ->
        "[#{type}]#{key}[==λ==]#{value}"
      end)
      |> Enum.join("\n")

    File.write(@data_file, content)
  end
end
