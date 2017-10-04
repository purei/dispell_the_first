# NOTE: no defmodule Database.  Amnesia will let us 'defdatabase'
use Amnesia

defdatabase Database do
	alias Database.Creator

	# Forward declaration, for use in Command
	deftable Creator

	######################################################################
	# Command table keyed by command.
	deftable Command, [:cmd, :timestamp, :author, :content], type: :set, index: [:author] do

		#Nice to have, we declare a struct that represents a record in the database
		@type t :: %Command{
			cmd: String.t, # Table's main index, no spaces in a cmd
			timestamp: DateTime.t, # Tagged with a timestamp
			author: non_neg_integer, # Tagged with creator's Discord snowflake id
			content: String.t, # Message content; may be JSON describing an embed.
		}

		# Helper function to get the user from an author
		def author(self) do
      Creator.read(self.author)
    end

	end

	######################################################################
	# User table keyed by id, a snowflake defined by Discord.
	deftable Creator, [:id, :timestamp, :name, :entry, :parent], type: :ordered_set do

		@type t :: %Creator{
			id: non_neg_integer,
			timestamp: DateTime.t, # Tagged with a timestamp
			name: String.t, # for convenience
			entry: Alchemy.User.t, # The full struct Alchemy has of the Discord user
			parent: Alchemy.User.t # ^same, but for the parent
		}

		# Add a command and tag it with the creator
    def set_command(creator, command, content) do
      %Command{ cmd: command, timestamp: DateTime.utc_now, author: creator.id, content: content }
				|> Command.write
    end

		# Add a creator and tag it with the parent
		def bless_user(parent, entry) do
			%Creator{ id: entry.id, timestamp: DateTime.utc_now, name: entry.username, entry: entry, parent: parent }
				|> Creator.write
		end

	end

end
