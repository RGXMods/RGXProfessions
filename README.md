# RGX Professions

|cff8B1538RGX|r Professions is the profession leveling bible for **WoW Forever** (the Classic beta client, Interface 16001). Browse every profession's full leveling path like a book: a button per profession, then page-by-page steps with recipes, materials, vendor locations, and notes. Requires `RGX-Framework`.

Derived from PLG (Profession Leveling Guide) by LirameiRav, updated from the original Retail version by Keg; default guides from wow-professions.com. Rebranded and extended for the RealmGX addon suite with RGX-Framework integration (events, slash commands, minimap, timers).

## Features

- **The Book** — a single window with a button per profession. Click one to read its leveling path page by page.
- **Next/Previous navigation** — every step in the path is a page: skill range, recipe link and icon, alternate routes, craft counts, and the full material list with have/need counts.
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
| `/plg` | Legacy alias for the same commands |

## Language support

RGXProfessions is fully localized for all twelve WoW client locales: enUS (base), deDE, esES, esMX, frFR, itIT, koKR, ptBR, ptPT, ruRU, zhCN, and zhTW. Every user-visible addon string is served from the locale table (`Constants/Localization.lua`), selected by the client's `GetLocale()` with automatic fallback to enUS for any missing key.

## Compatibility

- WoW Forever beta (Interface 16001, Classic data set).
- The bundled data also contains Cataclysm and Mists paths for future flavor builds; the client auto-selects its data set.

## Support

Part of the [RealmGX](https://realmgx.com) community project. Join us at discord.gg/N7kdKAHVVF.
