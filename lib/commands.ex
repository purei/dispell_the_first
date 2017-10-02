defmodule Commands do
  @moduledoc """
  Documentation for Commands.
  """
  use Alchemy.Cogs

  Cogs.def ping do
    Cogs.say "pong!"
  end

  @doc """
  Hello world.

  ## Examples

      iex> Dispell.hello
      :world

  """
  def hello do
    :world
  end

end
