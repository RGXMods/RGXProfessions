# RGXProfessions

RGX Professions is the WoW Forever (Classic beta, Interface 16001) profession
leveling bible. It is a fork of PLG (Profession Leveling Guide) by LirameiRav
(guides from wow-professions.com), rebranded into the RGX addon family with
RGX-Framework integration and a new book-style UI.

## Layout And Runtime

- `RGXProfessions.toc` is the single load manifest (WoW Forever only).
- Namespace: `RGXProf` everywhere; SavedVariables: `RGXProf_Settings`,
  `RGXProf_SimResults`. The addon folder name is `RGXProfessions`.
- `Core/Core.lua` owns initialization, the RGX minimap button, and slash
  registration; `Core/Events.lua` owns event registration and the
  ADDON_LOADED wiring.
- `UI/BookWindow.lua` is the book UI: profession button landing page plus
  next/previous page navigation through every step in a profession path.
- `Data/` is the ported PLG data (Classic, Cata, Mists paths, recipes, NPCs);
  keep it data-only. The expansion is auto-selected from the client build.
- `Adapters/` integrate third-party trade windows (Skillet, TSM); preserve
  the adapter interface when touching `Core/DataManager.lua`.

## Development Rules

- Use RGX-Framework APIs (`RGX:RegisterEvent`, `RGX:RegisterSlashCommand`,
  `RGX:After`, `RGX:GetMinimap()`) instead of raw frames, `SLASH_*` globals,
  or `C_Timer`. Raw compatibility paths must be guarded.
- Guard client API differences the way `RegisterEventSafe` does: check
  `C_EventUtils.IsEventValid` and fall back safely. WoW Forever exposes a
  retail-like API surface, but not every event or script exists.
- Preserve the PLG attribution in the TOC and README; the wow-professions.com
  guides and PLG code are the upstream source.
- Keep `RGXProfessions.toc` and the addon version constant synchronized when
  changing versions.

## Testing And Release

There is no build step or automated test suite. Install with RGX-Framework on
the WoW Forever beta and verify: `/prof` opens the book, every profession
button opens its path, next/previous paging works, materials and vendors
render, the minimap button toggles via `/prof icon on|off`, and opening a real
profession window still shows the live guide. Stable releases use `vX.Y.Z`
tags in GitLab, mirrored to GitHub.
