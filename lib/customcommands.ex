defmodule CustomCommands do

  alias Alchemy.Client
  use Alchemy.Events
  use Amnesia
  use Database

@doc """
!create test
{ "title": "Recent Dev Posts - most recent Sept 27",
  "url": "https://www.kongregate.com/forums/17305-general/topics/912751-dev-arena-fix-runecrafting-update",
  "color": 3447003,
  "fields": [{
    "name": "Fields",
    "value": "They can have different fields with small headlines."
  }],
  "footer": {"text": "by Mennen"}
}

Use something like https://jsonlint.com to help write valid JSON.
"""

  Events.on_message(:handle_msg)

  # Handle all messages to find custom commands
  def handle_msg message do
    case message.content do
      # If the command begins with !! ...
      "!!" <> attempted_cmd ->
        # {:ok, _message} = Client.send_message(message.channel_id, "Trying "<>attempted_cmd)

        Amnesia.transaction! do
          # Check the CustomCommand table for the cmd
          selection = Command.where cmd == attempted_cmd

          # Get the first value off the selector;
          # should only be one as table is uniquely keyed on command names
          if selection do
            [head | _ ]  = Amnesia.Selection.values(selection)
            content = head.content

            # Attempt to decode JSON as an embed, and send as one
            # if fail, send as plain text
            case Poison.decode(content,
                as: %Alchemy.Embed{
                  fields: [%Alchemy.Embed.Field{}],
                  author: %Alchemy.Embed.Author{},
                  image: %Alchemy.Embed.Image{},
                  provider: %Alchemy.Embed.Provider{},
                  footer: %Alchemy.Embed.Footer{},
                  thumbnail: %Alchemy.Embed.Thumbnail{},
                  video: %Alchemy.Embed.Video{}
                }) do

              {:ok, embed} ->
                embed_stamped = Alchemy.Embed.timestamp embed, DateTime.utc_now()
                Client.send_message(message.channel_id, "", [embed: embed_stamped])
              {:error, _msg} ->
                Client.send_message(message.channel_id, content)
              a -> IO.warn a
                # apparently there are odd errors that aren't a 2-tuple,
                # show them in red to the console
            end

          end
        end

      # Ignore if doesn't start with !!
      _ -> nil
    end
  end
end
