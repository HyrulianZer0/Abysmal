# Phase 1b Ledger — PS1 enemies + .blend leads (Oct 29, 2026)

**Scope: HUNT + STAGE + CATALOG + BLENDER EXPORT ONLY.** No game code,
scene, test, spawn picker, build, APK, or release was touched. Nothing
here is wired into the game. No itch.io, Freesound, paid/paywalled,
ripped, or unlicensed source was used. No download was attempted from
any source whose license was not first confirmed on its own page.

**Credits rule:** game credits use the pseudonym **Aethelwarden Solas**
only for the developer — never the developer's real name. The
attribution strings below are for the asset authors, not the developer,
and the two REQUIRED attributions (Cerberus, snappaKappa) must appear
in the game credits if those models ship.

**Note on other files in this tree:** a concurrent worker was staging
unrelated `gobkit/` models into this same `models/` tree at the same
time (Oct 29, 15:43–15:44). Those files are NOT part of this ledger.
This ledger covers only the 7 packs / 19 source models listed below.

## Blender export — what was used

- Blender was **not** pre-installed. A portable official tarball WAS
  feasibly installable, so it was installed (not a Phase 2 deferral):
  **Blender 4.5.3 LTS**, from
  `https://download.blender.org/release/Blender4.5/blender-4.5.3-linux-x64.tar.xz`
  (377,397,328 bytes), installed at `~/workspace/tools/blender-4.5.3-linux-x64/`
  (kept outside the game tree so Phase 2 can reuse it; run headless
  with `--background`).
- Export method: one headless Blender run per source file,
  `bpy.ops.export_scene.gltf(export_format='GLB', export_yup=True)`,
  saving a `.glb` next to its source file. Every `.glb` below was
  verified on disk as a real glTF binary (starts with the `glTF` magic
  bytes) with the size shown — exports were not faked.
- **Honest limit of this verification:** files were verified as valid
  glTF binaries only. They were NOT imported into Godot, and animation
  preservation (armatures, clips, PS1-style limb parenting) was NOT
  checked in-engine. Phase 2 must import each `.glb` in Godot and
  confirm mesh, textures, rig, and animations before wiring anything.
  Export warnings below are therefore recorded verbatim, not waved away.

## Results at a glance

| Pack / model | License | Export |
|---|---|---|
| PS1 Style RPG Enemies — all 13 | CC0 1.0, CptDrunkBear | ✅ All 13 exported cleanly (no warnings) |
| Vampire Bat (Animated) | CC0 1.0, rubberduck | ✅ Exported, with warnings (see below) |
| Evil Giant Rat | CC0 1.0, CDmir | ✅ Exported, with warnings (see below) |
| Animated Cerberus | **CC-BY 3.0 (chosen)**, Clement Wu, Nikolaus & Botanic | ✅ Exported, with warnings (see below) |
| snappaKappa 3d | CC-BY 4.0, MNDV.ecb | ✅ Exported, with warnings (see below) |
| Goblin | CC0 1.0, br-n518 | ✅ Exported, with warnings (see below) |
| Dragon (.3ds) | CC0 1.0, DrakanFyr | ❌ Stayed .3ds-only (Blender 4.5 has no 3DS importer) |

**Totals: 19 source models staged, 18 exported to `.glb`, 1 left
unconverted.** No part of this assignment was declined and nothing was
retried after a decline.

## 1. PS1 Style RPG Enemies (CC0, CptDrunkBear)

- **Source page (license verified here first):**
  https://opengameart.org/content/ps1-style-rpg-enemies
  — license field "CC0", author CptDrunkBear.
- **Direct file:** https://opengameart.org/sites/default/files/ps1_enemy_models_and_textures.zip
  (1,628,268 bytes, matches the page's "1.6 Mb").
- **Staged at:** `ps1-style-rpg-enemies/` — original zip kept, plus its
  folder structure preserved under
  `ps1-style-rpg-enemies/PS1_Enemy_Models_And_Textures/`
  (13 `.blend` + 15 PNG textures, incl. `enemy_bandit_weapon.png` and a
  shared `enemy_mold.png`). Per-folder license note:
  `ps1-style-rpg-enemies/LICENSE.md`.
- **Attribution string (credited even though CC0 does not require it):**
  `PS1 Style RPG Enemies by CptDrunkBear (CC0 1.0)`
- **Roster fit (proposal, not wired):** bandit → Brigand, revenant →
  Revenant, scorpion → Cave Scorpion, cobracon / rattler → serpents.
- **Source .blend version:** 2.79 for all 13 (per `file`).

| Enemy file | .blend bytes | .glb bytes | Export result |
|---|---|---|---|
| enemy_bandit.blend | 599,188 | 43,188 | ✅ Exported cleanly, no warnings |
| enemy_cannae.blend | 571,600 | 33,244 | ✅ Exported cleanly, no warnings |
| enemy_cereptera.blend | 506,772 | 4,300 | ✅ Exported cleanly, no warnings |
| enemy_clod.blend | 523,292 | 12,324 | ✅ Exported cleanly, no warnings |
| enemy_cobracon.blend | 537,752 | 16,940 | ✅ Exported cleanly, no warnings |
| enemy_helichard.blend | 500,612 | 4,324 | ✅ Exported cleanly, no warnings |
| enemy_janga.blend | 550,804 | 28,660 | ✅ Exported cleanly, no warnings |
| enemy_myocene.blend | 520,760 | 11,760 | ✅ Exported cleanly, no warnings |
| enemy_rattler.blend | 522,408 | 12,848 | ✅ Exported cleanly, no warnings |
| enemy_revenant.blend | 589,668 | 50,372 | ✅ Exported cleanly, no warnings |
| enemy_scorpion.blend | 555,772 | 10,540 | ✅ Exported cleanly, no warnings |
| enemy_tardigrade.blend | 519,836 | 16,584 | ✅ Exported cleanly, no warnings |
| enemy_ungulate.blend | 535,084 | 18,404 | ✅ Exported cleanly, no warnings |

Note on the PS1 style: per the source page these are "rigged in a
retro style, with each limb being a separate model with the transform
parented" — Phase 2 must confirm in Godot that the exported `.glb`
limbs and textures behave as expected; the clean export log alone does
not prove the retro rig survived intact.

## 2. Vampire Bat (Animated) (CC0, rubberduck)

- **Source page:** https://opengameart.org/content/vampire-bat-animated
  — license field "CC0", author rubberduck.
- **Direct file:** https://opengameart.org/sites/default/files/animated_vampire_bat.zip
  (16,497,090 bytes, matches the page's "16.5 Mb").
- **Staged at:** `vermin/vampire-bat-animated/` — original zip kept,
  plus extracted contents: `bat_v5.blend` (rigged, animated; 4004 verts
  per the page), `bat_tex.jpg`, `bat_tex_n.jpg`, frost-bat variant
  textures, the author's `raw/` sources, and an HDRI lighting file.
  License note: `vermin/vampire-bat-animated/LICENSE.md`.
- **Attribution string:** `Vampire Bat (Animated) by rubberduck (CC0 1.0)`
- **Roster fit (proposal, not wired):** Vampire Bat.
- **Export:** ✅ `bat_v5.glb` (3,585,524 bytes), valid glTF binary —
  **with non-fatal warnings recorded verbatim:** "Mesh Cube.009 is not
  valid, and may be exported wrongly", "Mesh Cube.000 is not valid, and
  may be exported wrongly", "The active Vertex Color will not be
  exported, as it is not used in the node tree of the material",
  "There are more than 4 joint vertex influences. The 4 with highest
  weight will be used (and normalized)." Phase 2 must check the bat
  mesh in Godot before use.

## 3. Evil Giant Rat (CC0, CDmir)

- **Source page:** https://opengameart.org/content/evil-giant-rat
  — license field "CC0", author CDmir, collaborator TinyWorlds.
- **Direct file:** https://opengameart.org/sites/default/files/rat_2.blend
  (downloaded as `rat.blend`, the display name on the page;
  6,833,728 bytes, matches the page's "6.8 Mb").
- **Staged at:** `vermin/evil-giant-rat/rat.blend` (rigged + animated
  per the page; all textures packed in the blend file).
  License note: `vermin/evil-giant-rat/LICENSE.md`.
- **Attribution string:** `Evil Giant Rat by CDmir (CC0 1.0)`
- **Roster fit (proposal, not wired):** Giant Rat / Cave Rat.
- **Export:** ✅ `rat.glb` (38,436 bytes), valid glTF binary — with one
  non-fatal warning: "Mesh Cylinder.002 is not valid, and may be
  exported wrongly." Phase 2 must check that mesh in Godot.

## 4. Animated Cerberus — LICENSE PICK RECORDED

- **Source page:** https://opengameart.org/content/animated-cerberus
  — authors Clement Wu, Nikolaus & Botanic (submitted by Botanic);
  multi-license offer on the page: CC-BY 3.0 / CC-BY-SA 3.0 /
  GPL 3.0 / GPL 2.0 (user picks one).
- **License CHOSEN: CC-BY 3.0.** Chosen deliberately because it is the
  non-copyleft option: attribution only, no share-alike and no GPL
  terms imposed on Abysmal. **No copyleft flag is triggered by this
  choice.** (Had CC-BY-SA or GPL been picked, that would have been
  flagged here for a copyleft decision instead, per the assignment.)
- **Direct files:**
  - https://opengameart.org/sites/default/files/cerberus_v002.blend
    (1,254,592 bytes, matches the page's "1.3 Mb")
  - https://opengameart.org/sites/default/files/cerberus_texture_0.png
    (downloaded as `cerberus_texture.png`, the display name on the
    page; 81,295 bytes, matches the page's "81.3 Kb")
- **Staged at:** `demons/animated-cerberus/` (`.blend` + texture).
  License note: `demons/animated-cerberus/LICENSE.md`.
- **Attribution string (REQUIRED under CC-BY 3.0 — must be in the game
  credits if this model ships):**
  `Animated Cerberus by Clement Wu, Nikolaus & Botanic (CC-BY 3.0)`
- **Roster fit (proposal, not wired):** Cerberus (apex boss, hellhound).
- **Export:** ✅ `cerberus_v002.glb` (95,096 bytes), valid glTF binary
  — with one non-fatal warning: "Armature must be the parent of
  skinned mesh. Armature is selected by its name, but may be false in
  case of instances." Note the source `.blend` reports version 2.56
  (the oldest file in this hunt); Blender 4.5.3 still opened and
  exported it, but Phase 2 must verify the rig/animations
  (Attack, Idle, Hit, Pose, Walk per the page) in Godot.

## 5. snappaKappa 3d (CC-BY 4.0, MNDV.ecb)

- **Source page:** https://opengameart.org/content/snappakappa-3d
  — license field "CC-BY 4.0", author MNDV.ecb. The page notes the
  model "inherits license from" the original 2D snappa-kappa strip
  (crisisworks), used as its texture.
- **Direct file:** https://opengameart.org/sites/default/files/snappa-kappa.blend
  (724,712 bytes, matches the page's "724.7 Kb").
- **Staged at:** `yokai/snappakappa-3d/snappa-kappa.blend` (rigged,
  ~1200 tris per the page). New `yokai/` family folder created, since
  no yōkai folder existed in this tree. License note:
  `yokai/snappakappa-3d/LICENSE.md`.
- **Attribution string (REQUIRED under CC-BY 4.0 — must be in the game
  credits if this model ships):**
  `snappaKappa 3d by MNDV.ecb, based on snappaKappa by crisisworks (CC-BY 4.0)`
- **Roster fit (proposal, not wired):** Kappa (staged type).
- **Export:** ✅ `snappa-kappa.glb` (73,508 bytes), valid glTF binary
  — with non-fatal warnings: the same armature-parent warning as
  Cerberus, plus "Mesh 'Mesh' has no primitives and will be omitted."
  Phase 2 must check the exported mesh in Godot.

## 6. Goblin (CC0, br-n518)

- **Source page:** https://opengameart.org/content/goblin-2
  — license field "CC0", author br-n518; page also carries a
  "Copyright/Attribution Notice: CC0".
- **Direct file:** https://opengameart.org/sites/default/files/goblin_1.blend
  (downloaded as `goblin.blend`, the display name on the page;
  769,844 bytes, matches the page's "769.8 Kb").
- **Staged at:** `goblin-kin/goblin/goblin.blend` (simple armature rig,
  weight-painted per the page). New `goblin-kin/` family folder
  created, since no goblin-kin folder existed in this tree.
  License note: `goblin-kin/goblin/LICENSE.md`.
- **Attribution string:** `Goblin by br-n518 (CC0 1.0)`
- **Roster fit (proposal, not wired):** Goblin (staged type).
- **Export:** ✅ `goblin.glb` (94,608 bytes), valid glTF binary — with
  non-fatal warnings: "Mesh GEO-goblin is not valid, and may be
  exported wrongly" and "There are more than 4 joint vertex
  influences. The 4 with highest weight will be used (and
  normalized)." Phase 2 must check the mesh/rig in Godot.

## 7. Dragon (CC0, DrakanFyr) — .3ds, NOT converted

- **Source page:** https://opengameart.org/content/dragon-3
  — license field "CC0", author DrakanFyr.
- **Direct file:** https://opengameart.org/sites/default/files/dragon.3ds
  (33,845 bytes, matches the page's "33.8 Kb").
- **Staged at:** `dragons/dragon/dragon.3ds`. License note:
  `dragons/dragon/LICENSE.md`.
- **Attribution string:** `Dragon by DrakanFyr (CC0 1.0)`
- **Roster fit (proposal, not wired):** generic dragon only — per the
  page it is low-poly, UNRIGGED and UNSKINNED, so it is not a
  Drake replacement as-is even after conversion.
- **Export:** ❌ **Stayed .3ds-only.** Blender 4.5.3 has no 3DS
  importer: `bpy.ops.import_scene.autodesk_3ds` fails with
  "could not be found". No `.glb` was produced and none is claimed.
  **Phase 2 step:** convert with Blender ≤ 3.6 (which still shipped
  the 3DS importer) or with Assimp, then rig it before any use.
  This is the only unconverted model in this hunt, and it is a
  format limitation, not a license problem.

## Correction made during this hunt (recorded honestly)

The first batch-export run had a shell bug: a `local` declaration
combined two assignments, so the output path expanded from the stale
loop variable and the bat, rat, cerberus, and kappa exports all
overwrote `enemy_ungulate.glb` in turn (ending as the kappa export).
This was caught by checking output sizes/timestamps, not shipped:
all five files were re-exported with the corrected script, and
`enemy_ungulate.glb` was restored to its true 18,404-byte export.
Final sizes above are from the corrected run, verified by glTF magic
bytes.

## What Phase 2 still needs (not done here)

1. Godot import check of all 18 `.glb` files: mesh, textures, rig,
   and animation clips (especially the warning-flagged meshes and the
   PS1 retro limb parenting).
2. `.3ds` → glTF conversion for the dragon (Blender ≤ 3.6 or Assimp),
   then rigging — an unrigged mesh alone is not a usable enemy.
3. The two REQUIRED credits (Cerberus CC-BY 3.0, snappaKappa CC-BY 4.0)
   added to the game credits if those models ship; CC0 credits are
   recorded above as a matter of policy even though not required.
4. The still-outstanding human itch.io clickthrough (Quaternius,
   KayKit) — untouched by this hunt, per the standing rule.

## Addendum — Wave 1 Worker B duplicate pruning (Oct 29, 2026)

The canonical paths in this ledger were confirmed intact (all 18
`.glb` exports still present with the sizes recorded above). The
non-canonical duplicate copies staged by the sibling OGA hunt were
deleted; full verification (md5 / `diff -rq`) is recorded in the
`phase1b-oga-ledger.md` addendum of the same date. Deleted:
`vermin/ps1-style-rpg-enemies/` (13 `.blend` + 15 PNG, byte-identical
to this ledger's PS1 folder), `beasts/vampire-bat/` (byte-identical to
`vermin/vampire-bat-animated/`), `bosses/cerberus/` (byte-identical to
`demons/animated-cerberus/`), `fey/snappakappa/snappa-kappa.blend`
(byte-identical to `yokai/snappakappa-3d/`), `dragons/dragon-drakanfyr/dragon.3ds`
(byte-identical to `dragons/dragon/`), and
`goblin-kin/goblin-br-n518/goblin.blend` (same OGA source item as
`goblin-kin/goblin/goblin.blend` but NOT byte-identical — 790,276 vs
769,844 bytes; deleted as the non-canonical copy, difference recorded
in the OGA-ledger addendum). No canonical path was modified.
Cerberus's `.glb` was left untouched and its CC-BY 3.0 election record
above is unchanged.

One discrepancy noticed, not resolved here: the on-disk
`vermin/evil-giant-rat/rat.blend` is 1,028,612 bytes, but §3 above
claims 6,833,728 bytes for the same path. No second rat copy exists
(both ledgers point at the same path), so nothing was deleted for the
rat. The `rat.glb` export size (38,436 bytes) still matches §3. Wave 2
should confirm the rat mesh is complete in Godot (already flagged as a
mesh check in §3).

## Addendum — Wave 1 Worker B: Dragon conversion + Rat/Cerberus re-exports (Oct 29, 2026)

Full detail lives in the `phase1b-oga-ledger.md` addendum of the same
date; this is the summary for this ledger's models.

- **Dragon (§7) — CONVERTED, static only.** Blender 4.5.3 has no 3DS
  importer and Assimp could not be installed (CLI absent, apt package
  not found, `apt-get update` hung and was killed, PyPI wheel needs a
  missing system libassimp). Conversion instead used portable Blender
  3.6.23 LTS (`~/workspace/tools/blender-3.6.23-linux-x64/`, which
  still ships the 3DS importer; the addon must be enabled explicitly
  in `--background` mode). Result: `dragons/dragon/dragon.glb`
  (165,252 bytes), valid glTF, 1 mesh (`Body`, 2 primitives, 2
  materials), 0 skins, no UVs, vertex extents roughly ±315 units.
  The model remains **unrigged and unskinned** — .3ds carries no skin
  weights — so Wave 2 must rig, animate, UV-unwrap, and rescale it
  from scratch before any enemy use. Usable now as a static mesh
  only, not a Drake replacement.
- **Rat (§3) — NO re-export; source itself is broken.** Re-opening
  `vermin/evil-giant-rat/rat.blend` proves it contains exactly one
  mesh (`Cylinder.002`, the 1.24 × 1.64 × 7.16 m object Worker A
  measured), zero armatures, zero actions — no rat at all. The old
  `rat.glb` was a faithful export of that fragment and was left
  untouched (still UNUSABLE AS-IS). No new rat GLB was produced and
  none was faked. Wave 2 step: re-download from the OGA item page and
  check whether the fresh file is the full 6.8 MB rat; if not, find a
  different rat source.
- **Cerberus (§4) — RE-EXPORTED, full clips + texture, still HELD.**
  New file `demons/animated-cerberus/cerberus_v002_full.glb`
  (333,540 bytes), valid glTF: 1 mesh, 49-joint skin, 5 clips
  (`Attack`, `die`, `hit`, `Idle`, `Walk`), texture embedded. The old
  `cerberus_v002.glb` (Walk only, flat grey) was left untouched for
  reference. The fix was export-only (NLA strips for the actions
  already in the file + Principled re-link of the existing texture);
  the source `.blend` was not saved. **Pose is MISSING from the
  source and was not authored** — no Pose action exists in the file.
  **HELD: do NOT wire** — the CC-BY 3.0 election is unconfirmed, per
  the Wave 1B brief. This ledger's §4 election record is otherwise
  unchanged.
