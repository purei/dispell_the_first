defmodule Commands do
  @moduledoc """
  Discord Bot Commands
  """
  alias Alchemy.Embed
  use Alchemy.Cogs
  use Amnesia
  use Database

  require Logger

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
    map = CardData.search_name(body)

    {map, coef} = Enum.fetch!(map, 0)

    Logger.info Kernel.inspect({"search", message.author.username, body, map.name, map.id, coef})

    displayCard(map, message)
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
    |> Enum.join("\n ")

    Logger.info Kernel.inspect({"fuzzy", message.author.username, body, nearby})

    Cogs.say "Possibles for '"<>body<>"':\n " <> nearby
  end


  @hack %{"frostbreath"=>"365880677993807873",
  "fervor"=>"365880678123962368",
  "iceshatter"=>"365880678153322497",
  "hex"=>"365880678157647874",
  "heal"=>"365880678161842187",
  "ignite"=>"365880678170099716",
  "freeze"=>"365880678279151616",
  "hinder"=>"365880678375620608",
  "fury"=>"365880678426083348",
  "imbue"=>"365880678627278858",
  "invisibility"=>"365880678690193411",
  "nullify"=>"365880678711164931",
  "puncture"=>"365880678719553537",
  "rejuvenate"=>"365880678803439629",
  "legion"=>"365880678824411136",
  "infect"=>"365880678883000320",
  "mystic_barrier"=>"365880678962954240",
  "poison_bolt"=>"365880679076200448",
  "siphon"=>"365880679285653506",
  "storm_legion"=>"365880679298367489",
  "shield"=>"365880679357218818",
  "scorchbreath"=>"365880679357218828",
  "silence"=>"365880679449362433",
  "taunt"=>"365880679801683971",
  "vengeance"=>"365880679818330113",
  "swiftness"=>"365880679818461196",
  "valor"=>"365880680066056193",
  "thornshield"=>"365880680078639124",
  "venom"=>"365880680372109314",
  "berserk"=>"365880705739259907",
  "arcane_shot"=>"365880705852637184",
  "avian_barrier"=>"365880705986854912",
  "barrage"=>"365880706062221312",
  "bind"=>"365880706200633344",
  "corrupt"=>"365880706221473793",
  "corrosive"=>"365880706250964993",
  "burn"=>"365880706410217482",
  "counterburn"=>"365880706653618176",
  "dark_hex"=>"365880706880241674",
  "drain"=>"365880706993487882",
  "eagle_eye"=>"365880707047751680",
  "enhance"=>"365880707110928394",
  "enrage"=>"365880707165192194",
  "empower"=>"365880707182231552",
  }

  def displaySkill(skill) do
    base = CardData.get_skill(skill.id)

    icon = case base.icon do
      nil -> "- "
      _ -> "<:" <> base.icon <> ":" <> @hack[base.icon] <> "> "
    end

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

    icon <> full_name <> affinity <> value <> delay

  end


  def displayCard(map, message) do
    url = "https://cdn.rawgit.com/TheSench/SIMSpellstone/gh-pages/res/cardImages/"
    name = url<>map.picture<>".jpg"

    subtypes_suffix = case map.subtypes do
      [] -> ""
      sts -> " " <> Enum.join(Enum.map(sts, fn(x)->
        t = CardData.get_type(x)
        t.name
      end), ", ")
    end

    stats =
      "Attack: **" <> Integer.to_string(map.attack) <>
      "**\nHealth: **" <> Integer.to_string(map.health) <>
      "**\nDelay: **" <> Integer.to_string(map.delay) <>
      "**\n\n"

    color = case map.type do
      1 -> 0x0000FF
      2 -> 0xFF0000
      3 -> 0x00FF00
      _ -> 0xAAAAAA
    end

    set = CardData.get_set(map.set)

    rarity = case map.rarity do
      1 -> "Common"
      2 -> "Rare"
      3 -> "Epic"
      4 -> "Legendary"
      5 -> "Mystic"
      _ -> "???"
    end
    title = rarity <> subtypes_suffix

    assets = "https://cdn.rawgit.com/TheSench/SIMSpellstone/gh-pages/res/cardAssets/"
    fusion = case map.id do
      x when x >= 20000 -> "Quadfuse.png"
      x when x >= 10000 -> "Dualfuse.png"
      _ -> "Singlefuse.png"
    end
    skills_template = Enum.reduce(map.skills, "", fn(x, acc) -> acc <> displaySkill(x) <> "\n" end)

    embed =
      %Embed{}
      |> Embed.author(name: map.name, icon_url: assets <> fusion)
      |> Embed.title(title)
      |> Embed.description(stats<>skills_template)
      |> Embed.thumbnail(name)
      |> Embed.color(color)
      |> Embed.footer(text: set.name <> " Set")

    {:ok, _} = Alchemy.Client.send_message(message.channel_id, nil, [embed: embed])
  end

end
