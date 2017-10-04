defmodule Commands.Creator do
  @moduledoc """
  Bot Commands concerned with Listing/Adding/Removing creators.
  """
  use Alchemy.Cogs
  use Amnesia
  use Database
  alias Database.User

  @doc """
  Creators replies with the list of creators known to this bot.
  """
  Cogs.def creators do
    Amnesia.transaction do
      selection = User.where true,
        select: entry

      listing = selection
      |> Amnesia.Selection.values
      |> Enum.map(fn(x) -> x.username end)

      if Enum.count(listing) > 0 do
        Cogs.say("Creators: " <> Enum.join(listing, ", "))
      else
        Cogs.say "We are creatorless."
      end
    end
  end

  def transaction_bless(creator, mentions) do
    # Get all creators before the blessing
    creators_before = User.where(true, select: username)
      |> Amnesia.Selection.values
      |> MapSet.new

    # Go through the mentions, and cast bless on each
    # FIXME don't cast; handle reply
    mentions
    |> Enum.each(&User.bless_user(creator, &1))

    # Get mentioned usernames and make them a set
    users_mentioned =
      mentions
      |> Enum.map(fn(x) -> x.username end)
      |> MapSet.new

    # Mentioned users that weren't in the original set were newly blessed
    MapSet.difference(users_mentioned, creators_before)
    |> MapSet.to_list
  end

  @doc """
  Bless makes anyone mentioned a creator.  May only be done by a creator.
  """
  Cogs.def bless do
    # Ignore if no Discord user is mentioned
    if Enum.count(message.mentions) > 0 do
      Amnesia.transaction do
        users = User.where id == message.author.id,
          select: entry
        # Admin-only
        if users do
          new_creators = transaction_bless(message.author, message.mentions)
          case new_creators do
            [] ->
              Cogs.say "No one was blessed."
            list ->
              Cogs.say "Blessed " <> Enum.join(list, ", ")
          end
        else
          Cogs.say "Only admins may bless."
        end
      end
    end
  end

  def transaction_unbless(creator, mentions) do
    # Get all unblessable creators
    unblessables =
      if User.where parent == creator and entry == creator do
        # If progenitor, you may unbless everyone, including yourself.
        # FIXME make progenitor? fn
        User.where true
      else
        # Otherwise, you may unbless only those you sired
        User.where creator == parent
      end
      |> Amnesia.Selection.values

    # Filter unblessables by those mentioned
    # Result: mentioned database users that may be unblessed by this creator
    unblessed =
      unblessables
      |> Enum.filter(fn(x) -> Enum.all?(mentions, fn(y) -> Map.equal?(y,x.entry) end) end)

    # Go through the unblessed, and cast a delete
    # FIXME don't cast; handle reply
    unblessed
    |> Enum.each(&User.delete/1)

    # Return names of unblessed
    unblessed
    |> Enum.map(fn(x) -> x.username end)
  end

  @doc """
  Unbless mentioned users; they are removed as creators.
  The unblessor may unbless only those that they blessed.
  Progenitor may unbless everyone, including self.
  """
  Cogs.def unbless do
    # Ignore if no Discord user is mentioned
    if Enum.count(message.mentions) != 0 do
      Amnesia.transaction do
        users = User.where id == message.author.id
        # Admin-only
        if users do
          removed_creators = transaction_unbless(message.author, message.mentions)
          case removed_creators do
            [] ->
              Cogs.say "No one was unblessed."
            list ->
              Cogs.say "Unblessed " <> Enum.join(list, ", ")
          end
        else
          Cogs.say "Only admins may unbless."
        end
      end
    end
  end


  @doc """
  Progenitor makes the user a creator if there are no other creators.
  """
  Cogs.def progenitor do
    Amnesia.transaction do
      if User.count() == 0 do
        User.bless_user(message.author, message.author)
        Cogs.say "You are the beginning."
      else
        Cogs.say "The primogenitor exists."
      end
    end
  end

end
