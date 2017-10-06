# Dispell

### Requirements

[Install Elixir 1.5](https://elixir-lang.org/install.html)

### Installation
```sh
git clone git@github.com:purei/dispell.git
cd dispell
mix deps.get
```

### Config for Discord
[Make config/secret.exs ](https://github.com/purei/dispell/commit/fffae9c0263cda333754ef354d978db066f6074c#diff-d15ef3a32a8374f092d16ea84fdeaad3) and supply Discord App token

### Preparing
```sh
# Delete the database anytime you change the schema in Database.ex
# rm -r Mnesia.nonode@nohost/

# Create a fresh database
mix amnesia.create -d Database

# Make directory for XML files
mkdir remote_xml
```

### Run Bot in Development
```sh
# Run Dispell in REPL
iex -S mix
# Ctrl-c-a to kill REPL

iex(1) > Librarian.downloadFullLibrary() # Download all XML data to filesystem
# NOTE: Only use if data changes

iex(2)> recompile() # Recompile changes and hot reload
# NOTE: If new commands - Cogs.def - are added, or mix.exs is changed, must restart REPL
```
