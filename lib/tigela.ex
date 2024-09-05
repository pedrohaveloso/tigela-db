defmodule Tigela do
  def main(_args) do
    Tigela.Transaction.start()
    Tigela.Persistent.start()

    program()
  end

  @prompt ">"

  @set_command "SET"
  @set_syntax "#{@set_command} <key> <value>"

  @get_command "GET"
  @get_syntax "#{@get_command} <key>"

  @begin_command "BEGIN"
  @begin_syntax "#{@begin_command}"

  @rollback_command "ROLLBACK"
  @rollback_syntax "#{@rollback_command}"

  @commit_command "COMMIT"
  @commit_syntax "#{@commit_command}"

  def program() do
    # ...

    program()
  end

  @spec get(String.t()) :: String.t()
  def get(key) do
    value =
      if Tigela.Transaction.level() > 0 do
        Tigela.Transaction.get(key)
      end

    if is_nil(value) do
      Tigela.Persistent.get(key)
    else
      value
    end
  end
end
