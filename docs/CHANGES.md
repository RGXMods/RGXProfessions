## v0.4.7 - 2026-11-12

Requires **RGX-Framework 2.18.0 or later**.

- The options page is laid out as two columns of cards (Chat and Minimap, then Guide), sized to their rows, with no lone tab row above them. Rows fill each card and the page lays itself out again once the client has sized it.
- The chat prefix is no longer an option: it is the branded RGX prefix and the settings page no longer offers a box for it.
- Every chat line the addon prints (slash commands, errors, notes) now goes through the shared RGX chat, so it carries the one standard prefix and obeys the Chat switch. The "[RGXProf]" tag that was written into the message strings is gone.
- The minimum framework version is now 2.18.0, which the card header switches need.

## v0.4.6 - 2026-11-12

Requires **RGX-Framework 2.18.0 or later**.

- The options page follows the RGX standard: three cards (Chat, Minimap, Guide), each with a switch in its header that turns the whole card on or off, and tick boxes for the options inside.
- New options: open the book when a profession window opens, and close it when the profession window closes. The guide already opens to the profession whose window is open.
- The book now tracks your live skill on its own. Before, it only refreshed after the trade-window guide had been built, so with that guide off a skill-up did not update an open book.

## v0.4.5 - 2026-11-11

Requires **RGX-Framework 2.17.0 or later**.

- Fixed the options page failing to build at login ("attempt to call a nil value" in OptionsWindow.lua): it called the strings table as a function.
- The interface style follows the choice made on the RGX-Framework settings page (Theme tab) while "Apply the framework theme to addons" is on; the addon's colours stay its own in every style. Otherwise it keeps RGX Material Round.
- Chat messages use the framework's shared chat voice ("icon - [Professions] message"), following the chat output, login message and chat prefix settings.
- The options page opens with the framework's shared General card (minimap button, Addons menu, chat output, login message, chat prefix), the same as the other RGX addons.

## v0.4.4 - 2026-11-11

Requires **RGX-Framework 2.17.7 or later**.

- The window header titles no longer show a stray `|r` before "Professions" or the profession name.
- The options panel is built in the RGX Material Round style, with "RGX Mods" and "by DonnieDice" in its header like the other RGX addons.

## v0.4.3 - 2026-11-11

Requires **RGX-Framework 2.16.0 or later**.

- Recipe icons use the crafted item for all 92 item-producing spells in the Forever guides, including Light Armor Kit and the Forever-only recipes. Enchants retain their spell icons.
- Item-only steps no longer mistake an item class ID for an icon when the icon is unavailable.

## v0.4.2 - 2026-11-10

Requires **RGX-Framework 2.16.0 or later**.

- Leatherworking and Herbalism show their own profession icons.
- The Brilliant Smallfish recipe shows the fish instead of a rune.
- Recipe slots no longer show a question-mark placeholder.
- Removed third-party credits and source references; the addon is built in-house.

## v0.4.1 - 2026-11-09

Requires **RGX-Framework 2.16.0 or later**.

- "Recipe location" (the card that was "Where to get it") is translated in all twelve client languages.

## v0.4.0 - 2026-11-09

Requires **RGX-Framework 2.16.0 or later**.

- The title reads "RGX | Professions" everywhere (guide, settings, chat prefix, Addons menu); the pipe no longer prints a stray "r".
- Grey on grey: titles and highlights use a light grey instead of pink, and the red stays as the outline.
- Right click goes back: from a profession page to the profession list.
- The guide opens to the profession whose window is open (setting "Open to the profession window", on by default), and switches when a profession window opens while the guide is up.
- The window opens at 820x470 and grows to fit a taller page, keeping its top edge in place; a window you resize yourself is left alone.
- Step list: finished steps are dimmed, the step you are on is bright, and each range keeps its skill-up colour.
- "Where to get it" is now "Recipe location".
- Settings page: new "Minimap and Addons menu" card (minimap icon and a switch for the Addons menu entry), a "Guide" card, and a chat option to turn the loaded message at login off. Chat messages use the branded prefix unless you set your own.

## v0.3.4 - 2026-11-09

Requires **RGX-Framework 2.15.2 or later**.

- Settings live in the game's options panel now: one page of framework cards with the minimap toggle, guide auto-open, recipe clicks, chat output and chat prefix. The gear in the header, `/prof settings` and the minimap menu all open that page instead of a separate window.
- Chat messages use a configurable prefix (default "RGX Professions") and can be turned off entirely.
- The Materials to Max lock button shows its state: accent-tinted locked icon, dimmed unlocked icon, and a titled tooltip ("Locked" / "Unlocked") that explains what clicking does.

## v0.3.3 - 2026-11-09

Requires **RGX-Framework 2.15.2 or later**.

- Brand logo is the in-game gold/purple mark that the window header shows; the derived cyan/pink and square-plus variants are gone.
- The package ships the WoW Forever data set only (Interface 16001). Cataclysm and Mists trees are excluded; Classic NPC tables stay because Forever uses them.
- New guide page, Materials to Max overlay and settings window from v0.3.2 are unchanged.
- Release pipeline runs from tags through the shared RGX workflow; CurseForge packages tagged commits.

## v0.3.2 - 2026-11-07

Requires **RGX-Framework 2.15.2 or later**.

- New guide page with a "next up" card, live material counts, item tooltips and click-to-pin.
- Compact, resizable, scalable Materials to Max overlay with a lock.
- Settings window (gear in the book) with a minimap icon on/off switch.
- Recipe and reagent icons use the spell and item APIs WoW Forever provides.
- Built on the framework's RGX Material Round style in RGXProfessions' own colours.
