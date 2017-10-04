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
      creators = Creator.where id == message.author.id
      if creators do
        [ admin | _ ] = Amnesia.Selection.values(creators)

        Cogs.say "Creating command '"<>cmd<>"' with "<>content
        admin |> Creator.set_command(cmd, content)
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
      creators = Creator.where id == message.author.id
      if creators do
        Command.delete command # no helpful response
        Cogs.say "If '"<>command<>"' used to exist it doesn't now."
      else
        Cogs.say "Only admins may delete"
      end
    end
  end

  @doc """
  Dump (Admin-only) shows the raw content; useful to look at the JSON of an embed
  """
  Cogs.def dump, do: nil
  Cogs.def dump(command) do
    Amnesia.transaction do
      creators = Creator.where id == message.author.id
      if creators do
        contents = Command.where cmd == command, select: content
        if contents do
          [content | _] = Amnesia.Selection.values(contents)
          Cogs.say content
        else
          Cogs.say "Nothing named '"<>command<>"' to dump"
        end
      else
        Cogs.say "Only admins may dump"
      end
    end
  end
end
