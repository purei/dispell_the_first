defmodule Commands do
  @moduledoc """
  Discord Bot Commands
  """
  use Alchemy.Cogs
  use Amnesia
  use Database

  @doc """
  Basic ping response.
  """
  Cogs.def ping do
    Cogs.say "pong!"
  end

  @doc """
  Help shows a blurb about each command -- keep this up to date
  """
  Cogs.def help, do: Cogs.say "!commands to see available commands, then !help <cmd>"
  Cogs.def help(cmd) do
    response = case cmd do
      "ping" -> "Check if the bot is alive"
      "commands" -> "Shows all available commands"
      "creators" -> "Shows all usernames that may create"
      "progenitor" -> "If there are no creators, become the first"
      "bless" -> "(Admin) Mentioned user is allowed to create custom commands: ex. !bless @AEnterprise"
      "unbless" -> "(Admin) Mentioned user, if sired by the unblessor, is removed as a creator, ex. !unbless @purei"
      "create" -> "(Admin) Creates a custom command with the given content: ex. !create info Don't do that!"
      "delete" -> "(Admin) Deletes a custom command: ex. !delete info"
      "dump" -> "(Admin) Dumps the raw content of a custom command, useful for modifying a complex embed: ex. !dump info"
    end
    Cogs.say response
  end

  @doc """
  Commands displays all of the commands the server knows.
  """
  Cogs.def commands do
    # Get hardcoded commands
    hardcoded = Cogs.all_commands()

    cmd_list = Enum.map(hardcoded, fn ({k,_v}) -> k end) #fn ({k,v}) -> k<>"/"<>to_string(elem(v,1)) end
    cmds = Enum.join(cmd_list, ", ")

    # Get all of the custom commands
    response = Amnesia.transaction do
      selection = Command.where true, select: cmd

      Enum.join(Amnesia.Selection.values(selection), ", ") # response is comma separated list of command names
    end
    # Mash 'em together and say it
    Cogs.say "Command List\n Core: "<>cmds<>"\n Custom: "<>response
  end

end
