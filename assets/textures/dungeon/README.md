# Dungeon variation textures (STAGED ONLY — not wired in)

Staged 2026-10-27. No game code was changed, no build/export was made.
All textures: Poly Haven, **CC0 1.0**, diffuse/color map only, 1K
(1024×1024 JPG). Per-folder `LICENSE.txt` gives the exact Poly Haven
asset slug and author where verified. Total: 44 files, 27,536,532
bytes (~26.3 MiB) under `assets/textures/dungeon/` — 24 files Oct 27
+ 20 lava files Nov 8 (6 maps, LICENSE, treatment report, 12
fallback-tier files). The lava set adds ambientCG (CC0 1.0) as a
second source and stages two Emission maps — the documented
exception to diffuse-only, because the lava theme's glow is its
identity (see `design-notes/lava-volcano-theme.md`).

## Mapping to dungeon looks

Locked design context (design-notes/morning-briefing-2026-10-11.md,
design-notes/monster-resources-zones-brainstorm.md): the main abyss
today is dark brick + moss; gathering zones are Forest (wood),
Caverns (stone/metal), Swamp (herbs), each both a guild-dispatch
destination and personally delveable. Other themes below are brainstorm
options (depth bands / variant floors / side areas — undecided).

| Variation folder | Wall | Floor | Ceiling | Suits |
|---|---|---|---|---|
| `brick/` | mixed_brick_wall | patterned_brick_floor | slumped_mortar_brick | Main abyss, worn-brick variant; Gilded Ruin fallback |
| `stone/` | stone_wall_04 | monastery_stone_floor | stone_block_wall | Main abyss stone variant; Caverns (worked stone) |
| `mossy_dark/` | mossy_brick | mossy_cobblestone | random_bricks_thick | **Main abyss as it is today** (dark brick + moss) — closest match to the live look |
| `cavern/` | rock_face_03 | cobblestone_floor_04 | rustic_stone_wall | **Gathering: Caverns** — rough granite, ore-vein country (torchlight on rough rock, not cold brick) |
| `forest/` | pine_bark | forest_ground_04 | = wall (bark) | **Gathering: Forest** — bark walls, leaf-litter floor |
| `swamp/` | worn_rock_natural_01 | forest_ground_06 | bark_brown_01 | **Gathering: Swamp** — damp bank rock, wet ground, root/cypress overhead |
| `frozen/` | marble_rock_02 | snow_01 | = wall | Brainstorm: **Frozen Vault** — see caveat below |
| `ember/` | volcanic_rock_tiles | tarred_gravel | rock_boulder_dry | Brainstorm: **Ember Foundry** — dark volcanic rock + gritty floor (no lava-glow texture staged; glow would come from lighting at wiring time) |
| `lava/` | volcanic_rock_tiles | Lava004 molten | Lava003 crust | **Sixth theme: Lava/Volcano** — molten floor + ember ceiling, glow maps staged (see `design-notes/lava-volcano-theme.md`). First fully tiered set (1K + 512 + 256 fallbacks). Built Nov 8, 2026. |
| `gilded/` | marble_mosaic_tiles | grey_cartago_01 | = wall (mosaic) | Brainstorm: **Gilded Ruin** — faded marble + mosaic, sunken grandeur |

Not covered (no suitable CC0 file found or deliberately left out):
Flooded Deep (no wet/algae stone staged), Bone Wastes (no bone wall),
Fungal Grotto (no mycelium wall), Void Scar (no void/black stone),
Thornwild (forest/ + mossy_dark cover it approximately), Storm Spire.
These need a future sourcing pass, not a stretch pick now.

## Style caveat — read before wiring

The live game uses hand-drawn 256×256 **pixel-art** textures
(`assets/textures/flakdeau/`, CC0). These staged sets are **photoreal
1K scans**. They will NOT match the pixel look if dropped in raw.
A future push must decide one of: (a) use them as-is for a deliberate
realistic-variant look, (b) downscale + posterize/pixelize them to the
256px pixel family, or (c) keep them as reference and hand-paint pixel
versions. Do not silently mix them into the live rotation.

Also: `dungeon_view.gd` applies `TEXTURE_FILTER_NEAREST` to every
texture material (keeps pixel art crisp). For photoreal textures that
filter will look crunchy up close; a wiring push using these as-is
should switch these materials to linear filtering.

## How the game references textures today (wiring note)

File: `scripts/dungeon_view.gd` (class `DungeonView`, Node3D).
Wired Nov 8, 2026: a per-theme `THEMES` dictionary — `"mossy_dark"`
(the live flakdeau look) + `"lava"` (sixth set). The theme for each
floor is picked RANDOMLY at `build_floor()` time (director call, Nov 8);
tests force a theme by name via `build_floor(gen, "lava")`.

- `mossy_dark` — 5 wall textures, weights [45,30,10,10,5]; 2 floor
  textures, weights [60,40]; 2 cap textures, weights [65,35]; cap lift
  1.9x; `TEXTURE_FILTER_NEAREST`; no emission. Cells are bucketed by
  deterministic position hash, one MultiMesh per variant.
- `lava` — 1 wall (basalt), 1 floor (molten + emissive, energy 1.0),
  1 cap/ceiling (crust + emissive, energy 0.5); cap lift 1.3x;
  `TEXTURE_FILTER_LINEAR`. Caps and open-cell ceilings share the cap
  textures but get SEPARATE materials (caps: lift only; ceilings: lift
  + ceiling emission).
- `_make_tex_material(tex, linear)` — StandardMaterial3D, albedo
  texture, white albedo, roughness 1.0, filter per theme.
- `_load_theme_tex(path)` — importer first, direct-decode fallback
  second (this container's Godot does not import new files; the lava
  JPGs resolve via the fallback here, via the importer on a real editor
  run). Hand-written `.import` files exist for all six lava JPGs.
  If a theme's textures fail entirely, the floor falls back to
  mossy_dark with a warning.
- Doors are separate slabs with their own door textures/UV rects
  (`DOOR_TEX_CLOSED/LOCKED/OPEN`, `DOOR_UV_*`) — wood as-is in every
  theme (basalt door slabs still a director call).
- Ceiling slabs reuse the cap set, so a variation with no separate
  ceiling file (forest, frozen, gilded) is already expressible: point
  that variation's cap list at its wall texture.

Adding a theme = one more `THEMES` entry (walls/floors/caps +
weights, cap lift, filter flag, emission maps). Follow-ups: quality
tiers (`fallback/512` default, `fallback/256` low) when the Quality
setting work lands; theme weights if random 50/50 is not wanted.

## Skipped sources (honest list)

- **Quaternius packs** — needs a human itch.io clickthrough; outstanding
  per the task brief, not worked around, nothing taken from it.
- **ambientCG** — CC0 and direct-downloadable in principle, but not
  needed: Poly Haven covered every staged variation, so no second
  source was pulled in.
- **Poliigon / textures.com / CGTrader / Fab / itch.io PSX pack** —
  account, paywall, or clickthrough gates, or non-CC0 terms; skipped.
- **Poly Haven slugs probed and missing (404, not staged):**
  `forest_ground_01`, `forest_leaves_02`, `ice_wall`, `glacier_ice`,
  `frozen_lake`, `ice_01`, `snow_ground` — hence no true ice texture
  for Frozen Vault (pale marble stands in, see caveat in `frozen/`
  LICENSE.txt) and no leaf-canopy ceiling for Forest.
- **Poly Haven API** (`api.polyhaven.org`) returned a 522 during this
  pass; downloads used the direct `dl.polyhaven.org` file URLs, which
  worked, and every file was verified as a real 1024×1024 JPEG after
  download — no file is claimed that was not verified on disk.
