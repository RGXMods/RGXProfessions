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
