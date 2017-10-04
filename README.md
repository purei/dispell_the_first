# Dispell

### Installation

[Install Elixir 1.5](https://elixir-lang.org/install.html)

```sh
cd dispell
mix deps.get

# Delete the database anytime you change the schema in Database.ex
# rm -r Mnesia.nonode@nohost/

# Create a fresh database
mix amnesia.create -d Database

```

### Config for Discord
[Make config/secret.exs ](https://github.com/purei/dispell/commit/fffae9c0263cda333754ef354d978db066f6074c#diff-d15ef3a32a8374f092d16ea84fdeaad3) and supply Discord App token

### Run Bot in Development
```sh
# Run Dispell in REPL
iex -S mix

# Recompile and hot reload
iex(1)> recompile()
# NOTE: must ctrl-c-a to restart REPL if new commands are added; recompile won't load a new Cogs.def.
# Also, if mix.exs is changed, must restart REPL
```
