defmodule Commands do
  @moduledoc """
  Discord Bot Commands
  """
  use Alchemy.Cogs

  @doc """
  Basic ping response.
  """
  Cogs.def ping do
    Cogs.say "pong!"
  end

end
