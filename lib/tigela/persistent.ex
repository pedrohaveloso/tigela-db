defmodule Tigela.Persistent do
  @data_dir "./tmp/database/data"

  @spec start() :: :ok
  def start() do
    unless File.exists?(@data_dir), do: File.mkdir_p(@data_dir)

    :ok
  end

  @spec get(String.t()) :: String.t() | nil
  def get(key) do
    case File.read("#{@data_dir}/#{key}") do
      {:ok, content} -> content
      _ -> nil
    end
  end

  @spec set(String.t(), String.t()) :: :ok | :error
  def set(key, value) do
    case File.write("#{@data_dir}/#{key}", value) do
      :ok -> :ok
      _ -> :error
    end
  end
end
