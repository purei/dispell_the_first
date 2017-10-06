defmodule Commands do
  @moduledoc """
  Discord Bot Commands
  """
  alias Alchemy.Embed
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
      "creators" -> "Shows all creator names"
      "progenitor" -> "If there are no creators, become the first"
      "search" -> "Search cards for given name; capitalize first letter if you are certain of it: ex. !search steel vs !search Steel"
      "fuzzy" -> "Return 6 results, closest by the Jaro distance of card name"
      "bless" -> "(Admin) Mentioned creator is allowed to create custom commands: ex. !bless @AEnterprise"
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

  @doc """
  Search compares the given text to each card name
  returns the closest by Jaro distance, displays an embed
  uses TheSench's github site for image urls
  """
  Cogs.set_parser :search, &List.wrap/1 # all words
  Cogs.def search body do
    map = CardData.search_name(String.capitalize(body))
    IO.inspect {body, map}
    map
    |> Enum.fetch!(0)
    |> elem(0)
    |> displayCard(message)
  end

  @doc """
  Fuzzy compares the given text to each card name
  returns the names of the 6 closest card names by Jaro distance
  """
  Cogs.set_parser :fuzzy, &List.wrap/1 # &Regex.split(~r/\s+/, &1, [parts: 2])
  Cogs.def fuzzy body do
    nearby = CardData.search_name(body, 6)
    |> Enum.map(fn(x) ->
      map = elem(x, 0)
      map.name
    end)
    Cogs.say "Possibles for '"<>body<>"':\n " <> Enum.join(nearby, "\n ")
  end

  def displaySkill(skill) do
    base = CardData.get_skill(skill.id)

    full_name = case skill.all do
      1 -> base.name <> " All"
      _ -> base.name
    end

    delay = case skill.timer do
      nil -> ""
      x -> " Every **" <> Integer.to_string(x) <> "** "
    end

    value = case skill.value do
      nil -> ""
      x -> " **" <> Integer.to_string(x) <> "** "
    end

    affinity = case skill.affinity do
      nil -> ""
      x ->
        type = CardData.get_type(x)
        " " <> type.name
    end

    "- " <> full_name <> affinity <> value <> delay

  end

  def displayCard(map, message) do
    url = "https://cdn.rawgit.com/TheSench/SIMSpellstone/gh-pages/res/cardImages/"
    name = url<>map.picture<>".jpg"
    sts = Enum.map map.subtypes, fn(x) ->
      t = CardData.get_type(x)
      t.name
    end
    title = "_" <> map.name <> "_ -- " <> Enum.join(sts, ", ")
    stats =
      "Attack: **" <> Integer.to_string(map.attack) <>
      "**, Health: **" <> Integer.to_string(map.health) <>
      "**, Delay: **" <> Integer.to_string(map.delay) <> "**\n"
    color = case map.type do
      1 -> 0x0000FF
      2 -> 0xFF0000
      3 -> 0x00FF00
      _ -> 0xAAAAAA
    end
    finished_template = Enum.reduce(map.skills, stats, fn(x, acc) -> acc <> displaySkill(x) <> "\n" end)

    embed =
      %Embed{}
      |> Embed.title(title)
      |> Embed.description(finished_template)
      |> Embed.thumbnail(name)
      |> Embed.color(color)

    {:ok, _} = Alchemy.Client.send_message(message.channel_id, nil, [embed: embed])
  end

end
