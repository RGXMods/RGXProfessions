# RGX Professions

|cff8B1538RGX|r Professions is the profession leveling bible for **WoW Forever** (the Classic beta client, Interface 16001). Browse every profession's full leveling path like a book: a button per profession, then page-by-page steps with recipes, materials, vendor locations, and notes. Requires `RGX-Framework`.

Derived from PLG (Profession Leveling Guide) by LirameiRav, updated from the original Retail version by Keg; Classic, Cata and Mists guides from wow-professions.com; the WoW Forever 1-300 routes, reagents, notes and tips from [WoWSoD Pro](https://wowsod.pro/wow-forever/professions/leveling) (Wowhead Forever data, final pre-launch skill-up colours, regenerated with `tools/gen-forever-guides.py`). Rebranded and extended for the RealmGX addon suite with RGX-Framework integration (events, slash commands, minimap, timers).

## Features

- **The Book** — a single window with a button per profession. Click one to read its leveling path step by step.
- **Step list navigation** — every step in the path is a card in the list: skill range, recipe link and icon, alternate routes, craft counts, and the full material list with have/need counts.
- **Vendor and trainer knowledge** — steps that need purchases show the vendor names for your faction.
- **Minimap button** — left-click opens the book; drag to move; Ctrl+Right-click hides (`/prof icon on` restores it).
- **Live trade-window guide** — when a profession window is open, the classic step-by-step guide appears beside it, exactly like PLG.
- **No profession window required** — `/prof show <name>` opens any guide directly; skills are read from your character.

## Installation

1. Install [RGX-Framework](https://github.com/RGXMods/RGX-Framework) (required dependency).
2. Copy the `RGXProfessions` folder to `World of Warcraft\_classic_beta_\Interface\AddOns\`.
3. `/reload` or restart the client, and enable both addons.

## Commands

| Command | Effect |
|---|---|
| `/prof` | Open or close the professions book |
| `/prof book` | Open the book |
| `/prof show` | Open the trade-window guide, or the profession menu if no window is open |
| `/prof show <profession>` | Open the guide for a specific profession (partial names OK) |
| `/prof preview <profession> <skill>` | Show the preview-steps window for a simulated skill |
| `/prof icon on/off` | Show or hide the minimap button |

## Language support

RGXProfessions is fully localized for all twelve WoW client locales: enUS (base), deDE, esES, esMX, frFR, itIT, koKR, ptBR, ptPT, ruRU, zhCN, and zhTW. Every user-visible addon string is served from the locale table (`Constants/Localization.lua`), selected by the client's `GetLocale()` with automatic fallback to enUS for any missing key.

## Compatibility

- WoW Forever beta (Interface 16001, Classic data set).
- The bundled data also contains Cataclysm and Mists paths for future flavor builds; the client auto-selects its data set.

## Support

Part of the [RealmGX](https://realmgx.com) community project. Join us at discord.gg/N7kdKAHVVF.

## WoW Forever guides

All 12 professions carry the current Forever data: the eight crafting professions have full 1-300 routes with expected craft counts, skill-up colours, where each recipe comes from (trainer, vendor, quest or new in Forever) and per-craft reagents; Fishing, Herbalism, Mining and Skinning have gathering brackets with Alliance and Horde zones. `/prof tips <profession>` prints what Forever changed, tips and kit for a profession. Re-run `tools/gen-forever-guides.py --fetch` to refresh the data.
