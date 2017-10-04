# NOTE: no defmodule Database.  Amnesia will let us 'defdatabase'
use Amnesia

defdatabase Database do
	alias Database.User

	# User table keyed by id, a snowflake defined by Discord.
	deftable User, [:id, :username, :entry, :parent], type: :ordered_set do

		@type t :: %User{
			id: non_neg_integer,
			username: String.t, # for convenience
			entry: Alchemy.User.t,
			parent: Alchemy.User.t
		}

		def bless_user(parent, entry) do
			%User{ id: entry.id, username: entry.username, entry: entry, parent: parent }
				|> User.write
		end

	end

end
