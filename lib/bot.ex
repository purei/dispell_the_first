defmodule Bot do
  alias Alchemy.Client

  # child_spec and start_link allows the Bot to act as a supervised Worker
  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]},
      type: :worker,
      restart: :permanent,
      shutdown: 500
    }
  end

  def start_link(_opts) do
    # Starting the client must load a genserver that Cogs expects?
    run = Client.start(Application.get_env(:dispell, :token))

    # Load our commands
    use Commands
    use Commands.Creator
    use Commands.Custom
    use CustomCommands

    # Return the client to the supervisor
    run
  end

end
