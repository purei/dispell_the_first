# Dispell

### Requirements

[Install Elixir 1.5](https://elixir-lang.org/install.html)

### Installation
```sh
git clone https://github.com/purei/dispell.git
git clone https://github.com/purei/spellstone_xml.git # Agent that deals w/ card data
cd dispell
```

### Config for Discord
[Make config/secret.exs ](https://github.com/purei/dispell/commit/fffae9c0263cda333754ef354d978db066f6074c#diff-d15ef3a32a8374f092d16ea84fdeaad3) and supply Discord App token

### Preparing
```sh
# Prepare dependencies
mix deps.get

# Delete the database anytime you change the schema in Database.ex
# rm -r Mnesia.nonode@nohost/

# Create a fresh database
mix amnesia.create -d Database

# Hacky fix for very first time operation.
# To download the data the first time,
cd ../spellstone_xml
mix deps.get
# Make directory for XML files
mkdir remote_xml
# Run the xml app in a REPL
iex -S mix
# Download the full library
iex(1) > Librarian.downloadFullLibrary() # Download all XML data to filesystem
# Ctrl-c-a to kill REPL
cd ../dispell
# Move the data we downloaded to the main app
mv ../spellstone_xml/remote_xml .
```

### Run Bot in Development
```sh
# Run Dispell in REPL
iex -S mix

# Download new XML data to filesystem
iex(1) > Librarian.downloadFullLibrary() # NOTE: Only need to use if data changes

# If you edit code, Recompile changes and hot reload
iex(2)> recompile()
# NOTE: If new commands (Cogs.def) are added, data is changed, or mix.exs is changed,
# for now: must restart REPL
```
