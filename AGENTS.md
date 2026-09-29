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

## Building With RGX-Framework

- Contract first: build new addon behavior from the declarative `RGXAddon(name, opts)` table using only keys the framework ships today. Read `docs/DECLARATIVE-API.md` in `rgxmods/warcraft/RGX-Framework` before writing code; tier 4 keys are future targets, not runtime features. Use `onInit` and addon-scoped methods only where the shipped declarative surface genuinely cannot express the behavior.
- MCP tool loop: before writing UI, timer, event, aura, or slash code, run the rgx-framework MCP tools in order: `rgx_get_contract` -> `rgx_generate_addon` -> `rgx_validate_addon` -> `rgx_audit_lua`. Compare generated Lua with existing integration, validate the actual opts table, and audit every changed Lua file. Never hand-roll what the framework ships.
- Prefer framework subsystems over raw WoW API (the `RGX:RegisterEvent`, `RGX:RegisterSlashCommand`, and `RGX:After` style integrations named above): timers and repeating schedules, event registration, slash commands, minimap button, saved-settings database, aura watching, UI controls and dropdowns, colors, fonts, theming, tooltips, and sound. Keep the existing guarded compatibility paths deliberate; never strip them silently to satisfy an audit.
- Forbidden patterns that fail `rgx_audit_lua` and must not appear in new code: raw `C_Timer`, manual event frames, `SLASH_` globals, unguarded `SetAttribute`, raw aura plumbing, and raw hook reassignment.
- Validation: Lua 5.1 (`luac5.1 -p`) and XML (`xmllint`) must pass through the shared CI include before every MR, and the root README stays nonempty and substantive.
- Dependencies: keep `## RequiredDeps: RGX-Framework` and any `## X-RGX-Framework-MinVersion` accurate against the framework version line, and match the TOC SavedVariables names (`RGXProf_Settings`, `RGXProf_SimResults`) with the declarative `dbName` values.
- Repo facts: this addon targets WoW Forever only (interface `16001`) and uses `/prof` (`/prof icon on|off`) as its command surface. The TOC owns the `vX.Y.Z` version and the full load list. Recheck facts in the TOC and README when they change.

## Keeping Interface Versions Current

- Ground truth is the game client's own `.build.info` in the WoW installation root: one pipe-delimited row per installed product; the Product column names the flavor and the Version column gives `major.minor.patch.build`. Read it immediately before changing a TOC or releasing.
- Derive `## Interface:` as `major * 10000 + minor * 100 + patch` (verified: `1.60.1` -> `16001`, `1.15.9` -> `11509`, `2.5.6` -> `20506`, `5.5.4` -> `50504`). WoW Forever is the classic beta product row.
- Online cross-checks for builds not installed locally: the wago.tools build pages and versions.wowtools.io. Verify a feed is reachable at runtime before trusting it; if it is unreachable, the installed client's `.build.info` is authoritative.
- A stale `## Interface:` value is a bug: fix it in a task-branch MR with green shared validation before any release.
- Release through GitLab MR and green shared validation, then patch-bump through the same discipline and create a protected GitLab release tag matching the TOC version. Verify the identical tag on the downstream `RGXMods/RGXProfessions` mirror before reporting distribution pickup.
