defmodule Tigela do
  import Tigela.Input.Parser

  def main(_) do
    command("SET 'x x' \"name wo\"rld\"")
    |> IO.inspect()

    command("SET 'x x' name")
    |> IO.inspect()

    command("SET 'x' \"name world\"")
    |> IO.inspect()

    command("SET x 10")
    |> IO.inspect()

    command("SET z TRUE")
    |> IO.inspect()

    command("GET z TRUE")
    |> IO.inspect()

    command("GET z")
    |> IO.inspect()

    command("SET x x x x x FALSE")
    |> IO.inspect()
  end
end
