# RGXProfessions

RGX Professions is the WoW Forever (Classic beta, Interface 16001) profession
leveling bible. It is built in-house for the RGX addon family, with
RGX-Framework integration and a book-style UI.

## Layout And Runtime

- `RGXProfessions.toc` is the single load manifest (WoW Forever only).
- Namespace: `RGXProf` everywhere; SavedVariables: `RGXProf_Settings`,
  `RGXProf_SimResults`. The addon folder name is `RGXProfessions`.
- `Core/Core.lua` owns initialization, the RGX minimap button, and slash
  registration; `Core/Events.lua` owns event registration and the
  ADDON_LOADED wiring.
- `UI/BookWindow.lua` is the book UI: profession button landing page plus
  next/previous page navigation through every step in a profession path.
- `Data/` holds the per-expansion guide data (Classic, Cata, Mists, Forever
  paths, recipes, NPCs); keep it data-only. The expansion is auto-selected from the client build.
- `Adapters/` integrate third-party trade windows (Skillet, TSM); preserve
  the adapter interface when touching `Core/DataManager.lua`.

## Development Rules

- Use RGX-Framework APIs (`RGX:RegisterEvent`, `RGX:RegisterSlashCommand`,
  `RGX:After`, `RGX:GetMinimap()`) instead of raw frames, `SLASH_*` globals,
  or `C_Timer`. Raw compatibility paths must be guarded.
- Guard client API differences the way `RegisterEventSafe` does: check
  `C_EventUtils.IsEventValid` and fall back safely. WoW Forever exposes a
  retail-like API surface, but not every event or script exists.
- The addon is built in-house. Do not add third-party addon or website
  credits to the TOC, README or descriptions.
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

## Supported Interface Value Verification Table

Framework-wide reference verified on 2026-10-15 against RGX-Framework `2.7.18`
(commit `bab23d72c0e793c24c1a5191232514b6b1335ce3`): the six flavor TOCs,
`tools/ci/flavor-toc-check.mjs`, and the reachable
[Wago build feed](https://wago.tools/api/builds). Derive the Interface numeric
as `major * 10000 + minor * 100 + patch`; the final build component is excluded.
The source column names an observed feed record, not a claim that every flavor
is a current retail product. RGXProfessions itself still targets only Forever
(`16001`); this reference does not expand its supported clients.

| Framework flavor | Interface | Derivation | Verified feed source: product / version |
|---|---|---|---|
| WoW Forever (Classic beta) | 16001 | `1*10000 + 60*100 + 1` | `wow_classic_beta` / `1.60.1.70374` |
| Retail | 120105 | `12*10000 + 1*100 + 5` | `wow` / `12.1.5.70391` |
| Classic Era | 11509 | `1*10000 + 15*100 + 9` | `wow_classic_era` / `1.15.9.70003` |
| The Burning Crusade Classic | 20506 | `2*10000 + 5*100 + 6` | `wow_anniversary` / `2.5.6.70006` |
| Wrath of the Lich King Classic | 38002 | `3*10000 + 80*100 + 2` | `wow_classic_titan` / `3.80.2.70315` |
| Cataclysm Classic | 40402 | `4*10000 + 4*100 + 2` | historical `wow_classic` / `4.4.2.60895` |
| Mists of Pandaria Classic | 50504 | `5*10000 + 5*100 + 4` | `wow_classic` / `5.5.4.70268` |

No installed client's `.build.info` was available for this verification.
Before changing a TOC or releasing, re-read the target client's `.build.info`
as described below; this dated cross-check does not override installed-client
ground truth. The framework contract and MCP tools remain defined in
`docs/DECLARATIVE-API.md` and `docs/RGX-MCP.md` in RGX-Framework.

## Keeping Interface Versions Current

- Ground truth is the game client's own `.build.info` in the WoW installation root: one pipe-delimited row per installed product; the Product column names the flavor and the Version column gives `major.minor.patch.build`. Read it immediately before changing a TOC or releasing.
- Derive `## Interface:` as `major * 10000 + minor * 100 + patch` (verified: `1.60.1` -> `16001`, `1.15.9` -> `11509`, `2.5.6` -> `20506`, `5.5.4` -> `50504`). WoW Forever is the classic beta product row.
- Online cross-checks for builds not installed locally: the wago.tools build pages and versions.wowtools.io. Verify a feed is reachable at runtime before trusting it; if it is unreachable, the installed client's `.build.info` is authoritative.
- A stale `## Interface:` value is a bug: fix it in a task-branch MR with green shared validation before any release.
- Release through GitLab MR and green shared validation, then patch-bump through the same discipline and create a protected GitLab release tag matching the TOC version. Verify the identical tag on the downstream `RGXMods/RGXProfessions` mirror before reporting distribution pickup.
