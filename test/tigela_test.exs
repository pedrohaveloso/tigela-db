defmodule TigelaTest do
  use ExUnit.Case

  setup do
    File.rm_rf("./tmp/tigela_db/data")
    :ok
  end

  doctest Tigela.Data.Transaction
  doctest Tigela.Data.Persistent
end
