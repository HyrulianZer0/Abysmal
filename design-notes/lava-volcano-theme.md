# ABYSMAL — Lava/Volcano theme (sixth theme set)
Producer/Director: Aethelwarden Solas
Status: WIRED 2026-11-08 — lava theme wired into scripts/dungeon_view.gd (per-theme THEMES dictionary, random per-floor selection, LINEAR filter + emissive floor/ceiling, cap lift 1.3). First fully staged theme set with fallback tiers; the template for the other five themes when they get sourced.

## The set

Location: `assets/textures/dungeon/lava/`

| File | Source | Role |
|---|---|---|
| `wall_diff_1k.jpg` | Poly Haven `volcanic_rock_tiles` (Charlotte Baglioni), CC0 | Wall — dark basalt. Same file as `ember/wall_diff_1k.jpg` |
| `floor_diff_1k.jpg` | ambientCG `Lava004` Color map, CC0, procedural | Floor — molten lava flow (the signature) |
| `floor_emissive_1k.jpg` | ambientCG `Lava004` Emission map, CC0 | The floor's glow |
| `ceiling_diff_1k.jpg` | ambientCG `Lava003` Color map, CC0, procedural | Ceiling — dark cooling crust, ember fissures |
| `ceiling_emissive_1k.jpg` | ambientCG `Lava003` Emission map, CC0 | The fissures' glow |
| `accent_diff_1k.jpg` | Poly Haven `tarred_gravel` (Dimitrios Savva), CC0 | Accent — ash-dark gravel: ember beds / ash patches. Same file as `ember/floor_diff_1k.jpg` |
| `fallback/512/`, `fallback/256/` | Lanczos downscales of all six maps | Signed tiers: High 1K, Medium 512 (starting standard), Low 256 |
| `LICENSE.txt`, `TREATMENT-REPORT.json` | — | License record; measured averages + seam metrics |

Palette (measured average RGB): wall (61,54,49), accent (63,59,54),
ceiling (78,55,59), ceiling emissive (42,13,8), floor (172,68,46),
floor emissive (162,57,32). Family: basalt near-blacks + ember
oranges. No regrade was applied — the sources already unify; forcing
one would only cost quality. Seam diffs 5.0–10.1 (mean absolute
channel difference across tile edges, 0–255 scale) — seamless PBR
sources; the engine's per-instance tint + deterministic bucketing
breaks up any residual tiling.

## Coverage — which dungeon surfaces

- **Floor:** `floor_diff` (molten) with emission. The theme's
  signature — the floor glows.
- **Walls:** `wall_diff` (basalt).
- **Ceiling:** `ceiling_diff` (cooling crust) with emission on the
  fissures. Ceiling slabs reuse the cap set in the engine today, so
  the ceiling texture doubles as the wall-top cap texture — see the
  cap-lift note in the hook below.
- **Wall-top caps:** use `ceiling_diff` (dark crust). The 1.9x
  albedo lift the engine applies to caps needs review for lava: it
  was tuned for black brick that crushed to void; dark crust lifted
  1.9x may wash the ember fissures out. Suggested: cap lift ~1.2–1.4
  for this theme. Wiring-time call.
- **Doors:** UNCHANGED (wood doors). Open: lava theme could use dark
  basalt door slabs instead — director call, not decided.
- **Accents/props:** `accent_diff` (ash gravel) for ember beds, ash
  patches, scorched floor variation. Lava-flow channels: `floor_diff`
  on accent slabs (same material as the floor).
- **Lighting (wiring time):** glow comes from the emission maps +
  warm point lights, not from the diffuse alone. Suggested: warm
  orange point lights over lava floors, dim red ambient.

## Relation to ember/

`ember/` ("Ember Foundry", staged Oct 27) is a DIFFERENT brainstorm
look: dark volcanic rock + gritty floor, no lava. `lava/` is the
sixth theme set, the full volcano: molten floor, ember ceiling, glow
maps. The two share two source files (`volcanic_rock_tiles` as wall,
`tarred_gravel` as accent/floor) — basalt is basalt; the sets differ
in the lava surfaces, not the rock.

## Code hook — WIRED 2026-11-08

`scripts/dungeon_view.gd` now carries a per-theme `THEMES` dictionary
(`"mossy_dark"` + `"lava"`), each with walls/floors/caps + weights,
cap lift, filter flag, and emission maps. `build_floor(gen,
theme_override := "")` picks the theme per floor — random among the
available sets (director call, Nov 8) unless forced by name (tests
force it). Bucketing/weights underneath are unchanged. `texture_check`
asserts both themes (mossy_dark: all prior checks; lava: 4 multimeshes,
LINEAR + roughness 1.0, floor emission 1.0, ceiling emission 0.5, cap
lift 1.3, ceiling slabs over every open cell) — ALL PASS Nov 8.

What was implemented (lava):
1. **LINEAR filter** for lava materials (per-material; mossy_dark
   stays NEAREST).
2. **Floor material:** `emission_enabled = true`,
   `emission_texture = floor_emissive_1k`, energy 1.0 (tune on device).
3. **Ceiling material:** separate `_ceil_mats` (caps and ceilings no
   longer share one material), `ceiling_emissive_1k` at energy 0.5
   (tune on device).
4. **Cap lift 1.3** for lava caps + ceilings (mossy_dark keeps 1.9).
5. **Theme selection: random** per floor (50/50 with two sets).
6. **Texture resolution:** theme entries are path strings; `_load_theme_tex`
   loads via the importer first, direct-decode fallback second (this
   container's Godot does not import new files — verified Nov 8 — so the
   lava JPGs resolve via the fallback here; on a real editor run the
   importer path is used). Hand-written `.import` files exist for all six
   lava JPGs (md5 path hashes, fresh uids) so a real editor run imports
   them normally. If a theme's textures fail entirely, the floor falls
   back to mossy_dark with a warning — never a broken floor.

Still open (wiring-time / director):
- **Doors:** wood as-is (unchanged); basalt slabs still a director call.
- **Cap lift + emission energy:** tune on device.
- **Quality tiers:** wire `fallback/512` (default) and `fallback/256`
  when the Quality setting work lands.
- **Theme weights:** random is 50/50 with two sets; weight lava rarer
  later if the director wants.

## What is still open

- Theme selection rule — DECIDED Nov 8: random per floor.
- Doors in the lava theme (wood as-is vs basalt slabs) — director
  call.
- Cap lift value for lava caps — set 1.3 at wiring; tune on device.
- Emission energy values — set floor 1.0 / ceiling 0.5 at wiring;
  tune on device.
- No verified obsidian surface found (Poly Haven has no obsidian
  texture; the `lava` slug 404s) — the set does not need one; basalt
  + crust carry it. Recorded as a sourcing gap, not a hole.
- The other five themes (Flooded Deep, Bone Wastes, Fungal Grotto,
  Void Scar, Storm Spire) are still inspiration-only; lava is the
  first fully staged sixth set and the template for them (same folder
  shape + fallback tiers).

## Sources (all CC0, verified 2026-11-08)

- Poly Haven `volcanic_rock_tiles` — https://polyhaven.com/a/volcanic_rock_tiles — CC0
- Poly Haven `tarred_gravel` — https://polyhaven.com/a/tarred_gravel — CC0
- ambientCG `Lava004` — https://ambientcg.com/view?id=Lava004 — CC0 1.0,
  verified on https://docs.ambientcg.com/license/
- ambientCG `Lava003` — https://ambientcg.com/view?id=Lava003 — CC0 1.0,
  same license page
- Note: ambientCG `Lava004` was listed "skipped" in the Nov 4
  theme-download pass — that pass was Poly Haven diffuse-only
  (ambientCG "not needed: Poly Haven covered every staged
  variation"), not a license/quality rejection. Verified here on its
  own merits.
