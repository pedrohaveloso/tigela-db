defmodule Tigela.Data.Model do
  @moduledoc """
  Data type model.

  ## Examples

      iex> %Tigela.Data.Model{key: "x", type: "string", value: "foo"}
      %Tigela.Data.Model{key: "x", type: "string", value: "foo"}
  """

  defstruct [:key, :type, :value]

  @type t :: %Tigela.Data.Model{}
end
