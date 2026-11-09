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
| `RGXIcon.tga` | 64x64 | Targa, 32-bit | **In-game icon.** Referenced by `## IconTexture:` in `RGXProfessions.toc`. |
| `RGXIconSquare.tga` | 128x128 | Targa, 32-bit | Square source art for the book-and-cross mark. |
| `RGXIcon.png` | 64x64 | PNG | PNG rendition of the in-game icon, for web and documentation use. |
| `RGXIconSquare.png` | 512x512 | PNG | **CurseForge project logo.** Upload this file as the project icon on CurseForge (CurseForge requires a PNG of at least 200x200). Also the square artwork used in the README and the distribution descriptions. |
| `RGXIconRound.png` | 512x512 | PNG | Circular-masked rendition of the square artwork, for round avatar and badge use. |

## How the PNG renditions were made

`RGXIcon.png` is a direct conversion of `RGXIcon.tga`.

`RGXIconSquare.png` and `RGXIconRound.png` are 4x Lanczos upscales of
`RGXIconSquare.tga` (128x128 source), with a light unsharp pass so the flat
edges stay readable at CurseForge's project-logo size. Replace them with a
512x512 master if a higher-resolution source ever exists; keep the file names
so the descriptions keep working.

## Colour

The addon is branded by two colours and nothing else:

- Primary **RGX red** `#8B1538`
- Accent **coral** `#ED6B85`

Both are defined once in `UI/Theme.lua` and are the colours used by the
framework's RGX Material Round style for this addon.

## Related

- `docs/description.html` - CurseForge project description
- `wago_description.md` - Wago project description
- `README.md` - GitHub README
