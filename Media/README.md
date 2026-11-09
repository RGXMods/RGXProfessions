# Media Assets

Brand and icon assets for **RGX | Professions**.

The addon folder keeps its assets in `Media/` (capital **M**) because the TOC
points at that path:

```toc
## IconTexture: Interface\AddOns\RGXProfessions\Media\RGXIcon.tga
```

Do not add a second `media/` directory next to `Media/`. The two differ only by
case, so they collide on case-insensitive filesystems (Windows and macOS) and
break the in-game icon path.

## Files

| File | Size | Format | Use |
|---|---|---|---|
| `RGXIcon.tga` | 64x64 | Targa, 32-bit | **In-game icon.** Referenced by `## IconTexture:` in `RGXProfessions.toc` and by the minimap button in `Core/Core.lua`. |
| `RGXLogo.png` | 400x400 | PNG, opaque | **Brand logo.** The gold/purple RGX mark the addon shows in its own window header. Used by `README.md`, `docs/description.html`, `wago_description.md`, and as the source for the CurseForge project logo. |

Nothing else belongs in this folder. Do not add masked, rounded, or recoloured
variants of an existing mark; CurseForge, Wago, and Discord each crop or mask
the square themselves.

## Where the brand logo comes from

`RGXLogo.png` is a 400x400 Lanczos downscale of the 1254x1254 gold/purple
master (`purplegoldrgxlogo.png`). That art is the one the addon actually
renders: the book window header loads
`Interface\AddOns\RGX-Framework\media\square.tga`, and `square.tga` is the gold
cube with the purple X.

Note that `RGX-Framework/media/square.png` and `round.png` are **not** the same
palette: those high-resolution renditions are the newer cyan/pink variant. The
client loads the `.tga` files, so the `.tga` palette — purple body, gold edges —
is the one players see in game. When in doubt, trust the `.tga` the TOC or the
code points at.

`RGXIcon.tga` is a separate, older mark: the pink/cyan cube used for the addon
list icon and the minimap button. It is not the brand logo and should not be
used in descriptions or README art.

## Colour

The addon is branded by two colours and nothing else:

- Primary **RGX red** `#8B1538`
- Accent **coral** `#ED6B85`

Both are defined once in `UI/Theme.lua` and are the colours used by the
framework's RGX Material Round style for this addon. The logo art is the one
exception: it is the gold/purple mark shipped with the framework, not a
recolour of the interface palette.

## Distribution logo

The CurseForge project logo is uploaded by hand through the Authors site and
served by CurseForge at
`https://media.forgecdn.net/avatars/2188/794/639297992679825015.png`. The square
master (`RGXLogo.png`) is what gets uploaded; CurseForge stores its own 400x400
copy.

## Related

- `docs/description.html` - CurseForge project description
- `wago_description.md` - Wago project description
- `README.md` - repository README
