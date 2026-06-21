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

## Adding a game

Start from `db.json.example` and edit to your needs. Copy entries from the [wiki](https://github.com/Trihedraf/Save-Game-Link/wiki) or create your own.
