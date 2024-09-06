defmodule Tigela.ProcessorTest do
  use ExUnit.Case

  alias Tigela.Processor

  doctest Processor

  setup do
    File.rm_rf("./tmp/tigela_db/")
    Tigela.Data.Persistent.start()
    Tigela.Data.Transaction.start()

    :ok
  end
end
