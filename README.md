# Save Game Link

Link game saves using NTFS junctions for easy portability and backups. Keep your game saves in a synced/movable folder and link them back to where games expect them.

## Setup

```
git clone https://github.com/Trihedraf/Save-Game-Link.git
cd Save-Game-Link
```

## Usage

```
sgl.ps1                  List all games
sgl.ps1 -All             Process all games
sgl.ps1 -GameName <name> Process a specific game
sgl.ps1 -Check           Check all (or specific game with -GameName) links without making changes
sgl.ps1 -Help            Show help
sgl.ps1 -DatabasePath    Path to database file (default: .\db.json)"
```

## How it works

Save files live in `data/` under this folder. When you run the script, it creates directory junctions (NTFS symlinks) from each game's folder in `data/` to the expected save location.

This lets you keep the your saves in a synced folder or on a portable drive. The junctions can be recreated on any PC running Windows or in a different location by running the script again.

## GOGGAMES environment variable

Some GOG games store saves in their install folder. If your install isn't in the default location, use `env-gog.ps1` to set the `GOGGAMES` user environment variable so games can find themselves.

```
env-gog.ps1 -Check              Show the environment variable current value
env-gog.ps1 -Set "C:\GOG Games" Set the environment variable to a path (prompts if path not provided)
env-gog.ps1 -Remove             Remove the environment variable
env-gog.ps1 -Help              Show help
```

## Adding a game

Start from `db.json.example` and edit to your needs. Copy entries from the [wiki](https://github.com/Trihedraf/Save-Game-Link/wiki) or create your own.

Each path entry can optionally include `"type": "file"` if the target is a single file instead of a directory. Defaults to `"dir"` (directory junction) when omitted.
