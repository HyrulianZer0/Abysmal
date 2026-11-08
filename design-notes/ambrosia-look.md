# Ambrosia — the look (decided Nov 7, 2026)

## The decision

Ambrosia looks like a **rainbow crystal cluster** — close to how it looks
in Immortals Fenyx Rising (the game James meant; he couldn't recall the
exact crystal they use) and close to the rainbow animation on the pack
page. Not an exact copy of either — something close to both ideas.
James's word, Nov 7: "If you think the crystal is the right fit, then
lets do it." It is the right fit:

- It is literally a rainbow crystal cluster — the Fenyx look he described.
- CC0 1.0, no attribution required (credited anyway, per policy).
- Normal + height maps ship with it, so it has depth and light in-engine
  instead of being a flat sticker.
- 30 rotations per sprite = the page's rainbow animation, recreated as a
  slow spin in-game.
- Three sizes cover the jobs: 96px world cluster, 64px mid, 48px HUD/icon.

## Source

Polyy.AI "[FREE] 2D Crystal and Ore Sprites – 25 Pack" (itch.io),
CC0 1.0, "don't resell unmodified". Full pack (902 files, 73 MB) sits
in `~/workspace/browser_downloads/crystal_and_ore_sprites_25_pack.zip`.
Only the rainbow cluster is staged in the project; the other 24
crystals stay in the ZIP, unused.

## Staged files — `assets/textures/ambrosia/`

| File | What |
|---|---|
| `ambrosia-rainbow-cluster-96px.png` | World cluster sheet, 768×384 (30 rotation frames @ 96px) |
| `ambrosia-rainbow-cluster-64px.png` | Mid sheet, 512×256 |
| `ambrosia-rainbow-cluster-48px.png` | HUD/icon sheet, 384×192 |
| `*-normal.png` (48/64/96) | Normal maps, imported with `compress/normal_map=1` |
| `*-height.png` (48/64/96) | Height maps |

All nine carry hand-made `.import` siblings (path hash = md5 of the
`res://` path, fresh uids), mirroring the project's texture imports.

## Animation

Each sheet holds the cluster at 30 rotations. Play the frames slowly
for the spin, or rotate the node — frame cycling matches the page's
rainbow animation; node rotation is cheaper. Pick when the pickup is
built. The sprite James was shown first: the 96px studio nopalette
sheet (the clean full-color take).

## What this does NOT decide

- Where Ambrosia spawns or how it is earned (sourcing mechanics open).
- Any refine point (Fenyx uses the Kylix of Athena; Abysmal's equivalent
  is undecided — the Temple is the ascension home, but the refine step
  itself is not designed).
- Costs (first Fenyx upgrade = 6; Abysmal's numbers are undecided).
- The pickup entity, spawn logic, and HUD treatment (systems work).

## Canon it sits in

Ambrosia is the divine ascension currency: rebirth → Temple (Nov 7:
Abyssal Token retired, Ambrosia replaces it as the ascension gate).
It is NOT a health pickup. Credit line (credits doc): Polyy.AI,
CC0 1.0.
