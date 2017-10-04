defmodule Commands.Custom do

  use Alchemy.Cogs
  use Database
  use Amnesia

  # When creating a custom command, split the command from the content
  def cmd_parser(string) do
    Regex.split(~r/\s+/, string, [parts: 2])
  end

  @doc """
  Create (Admin-only) overwrites/creates the custom command 'cmd' with 'content'
  """
  Cogs.set_parser :create, &Commands.Custom.cmd_parser/1

  Cogs.def create(cmd, content) do
    Amnesia.transaction do
      users = User.where id == message.author.id
      if users do
        [ admin | _ ] = Amnesia.Selection.values(users)

        Cogs.say "Creating command '"<>cmd<>"' with "<>content
        admin |> User.set_command(cmd, content)
      else
        Cogs.say "Only admins may create"
      end
    end
  end

  @doc """
  Delete (Admin-only) tries to delete a custom command named 'cmd'
  """
  Cogs.def delete(command) do
    Amnesia.transaction do
      users = User.where id == message.author.id
      if users do
        case Command.delete command do
          :ok ->
            Cogs.say "Deleted custom command '"<>command<>"'"
          err ->
            Cogs.say "Nothing named '"<>command<>"' to delete"
        end
      else
        Cogs.say "Only admins may delete"
      end
    end
  end

  @doc """
  Dump (Admin-only) shows the raw content; useful to look at the JSON of an embed
  """
  Cogs.def dump(command) do
    Amnesia.transaction do
      users = User.where id == message.author.id
      if users do
        cmds = Amnesia.Selection.values(Command.where cmd == command)
        if cmds do
          case Enum.fetch cmds, 0 do
            {:ok, msg} ->
              Cogs.say msg.content
            err ->
              IO.warn err
          end
        else
          Cogs.say "Nothing named '"<>command<>"' to dump"
        end
      else
        Cogs.say "Only admins may dump"
      end
    end
  end
end
