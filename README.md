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

# Make directory for XML files
mkdir remote_xml

# To download the data the first time,
cd ../spellstone_xml
# Run the xml app in a REPL
iex -S mix
# Download the full library
iex(1) > Librarian.downloadFullLibrary() # Download all XML data to filesystem
# Ctrl-c-a to kill REPL
cd ../dispell
```

### Run Bot in Development
```sh
# Run Dispell in REPL
iex -S mix

iex(1) > Librarian.downloadFullLibrary() # Download all XML data to filesystem
# NOTE: Only use if data changes

iex(2)> recompile() # Recompile changes and hot reload
# NOTE: If new commands - Cogs.def - are added, data is changed, or mix.exs is changed,
# for now: must restart REPL
```
