# Wave 2 — Model wiring (Worker 2A, Oct 29, 2026)

**Engine:** Godot 4.7.2 headless. **Scope:** `scripts/enemy.gd`
(model-builder sections only), `scripts/monster_models.gd` (NEW),
`tests/monster_models_test.gd` (NEW), updates to
`tests/staged_monsters_test.gd` + `tests/placeholder_models_test.gd`
(honest-state updates only), model `.import` files for wired models
only, and `assets/resources-phase1/models/vermin/evil-giant-rat/rat_full.blend`
+ `rat_full.glb` (fresh re-download + export, see §5).
**Untouched:** `setup()`, combat, scaling curves, spawn picker
(`dungeon_gen.gd` still returns slime/bat/skeleton only), all audio
files, `audio_manager.gd`, `scripts/behaviors.gd`, all stats
(hp/atk/def/xp/gold). **No APK, no release, no publish, no upload.**
Credits use **Aethelwarden Solas** only.

## 1. Import check — new Wave 1B GLBs (scratch project, Worker A method)

Editor import + GLTFDocument scene walk in `/tmp/wave2-import-check`
(also re-walked as editor-imported scenes — identical results).

| File | Import | Meshes | Skeleton | Clips | Result |
|---|---|---|---|---|---|
| `demons/flare-daemon/daemon4.glb` | PASS | 1 (9 surf) | 49 bones | 9: attack, die, hit, idle1 (0.00 s!), idle2 (0.00 s!), idleAnim, mightyAttack, spell, walk | CHECKED, rostered as Daemon (idleAnim is the real idle clip) |
| `beasts/troll-flare/Troll.glb` | PASS | 2 (7 surf) | 25 bones | 8 unnamed Actions | **WIRED to Troll** (ShadowPlane removed before measuring; see §2) |
| `undead/pirate-crewman-ghost/piratezombiemodel.glb` | PASS | 3 (7 surf) | 26 + 8 bones | 2 unnamed Actions | CHECKED, **NOT wired to Wraith** (see §4) |
| `undead/skeleton-with-rig/fgc_skeleton.glb` | PASS | 8 (8 surf) | 237 bones | 0 | CHECKED, **NOT wired** (see §4) |
| `dragons/dragon/dragon.glb` | PASS | 1 (2 surf) | none | BodyAction (0.00 s pose only) | CHECKED, **static only, NOT wired** (see §6) |
| `golems/fire-ice-stone-golem/golem.glb` | PASS | 1 (3 surf) | 44 bones | 7 (attack, attack2, die, flinch, idle, walk…) | **HELD — check only, never wired** (floats at y=+4.04, noted) |
| `demons/animated-cerberus/cerberus_v002_full.glb` | PASS | 1 (1 surf, texture embedded) | 49 bones | 5 (Attack, Idle, Walk, die, hit) | **HELD — check only, never wired** (AABB 9.41×10.32×17.36, y-min −6.49, matches Worker A) |

All 7 import cleanly. The two HELD files were verified and then left
alone: no registry entry, no TYPES key, no `.import` generated for
them in the real project.

## 2. Per-monster mapping (28 staged types)

Target = in-game size on the normalised axis after `_build_model()`
scaling. Every wired model is grounded (AABB min → y=0) except the
two hoverers. No model ships at raw import scale.

| Type | Model / form | Norm → target | Motion |
|---|---|---|---|
| Slime, Cave Bat, Skeleton | Live Quaternius (unchanged) | as before | clips |
| Cave Rat | **rat_full.glb** (fresh re-download, §5) | height → 0.42 m | Idle_001 / Attack_000 / Die / Walk |
| Giant Serpent | PS1 `enemy_cobracon.glb` + re-linked `enemy_cobracon.png` | height → 0.85 m | procedural slither |
| Goblin | OGA `goblin.glb` (39 bones, 0 clips) | height → 1.00 m | procedural breathe |
| Wraith | Gobkit `SheetGhost.glb` | height → 1.50 m, hover +0.35 | Idle / Attack / Death / Walk |
| Wild Boar | Gobkit `Boar.glb` | height → 0.85 m | idle / attack / dead / walk |
| Cave Scorpion | PS1 `enemy_scorpion.glb` + re-linked `enemy_scorpion.png` | height → 0.50 m | procedural skitter |
| Centipede | Gobkit `GeodeCentipede.glb` | **length (z) → 1.70 m** | idle / attack / move (no death clip) |
| Skeleton Archer | OGA `skull_monster.obj` (MTL texture links on import) | height → 1.40 m | procedural breathe |
| Imp | Gobkit `FattyImp.glb` | height → 1.00 m, hover +0.90 | idle / attack / move (no death clip) |
| Orc | Gobkit `OrcLegionary.glb` | height → 1.55 m | Idle / Attack / Death / Walk |
| Troll | FLARE `Troll.glb` (CC-BY 3.0) | height → 2.20 m | first unnamed Action clip (mapping NOT invented) |
| Minotaur | Gobkit `BrazenMinotaur.glb` | height → 1.75 m | idle / attack / move (no death clip) |
| Kappa | `snappa-kappa.glb` (21 bones, 0 clips; CC-BY 4.0 credit required if it ships) | height → 1.15 m | procedural breathe |
| Drake | Gobkit `Wyvern.glb` | height → 1.40 m | idle / attack / move (no death clip) |
| Cave Spider, Cave Wasp, Cave Frog, Cave Wolf, Zombie, Clay Golem, Kobold, Pixie, Harpy, Oni, Banshee | **Upgraded procedural** (existing distinct placeholders + new procedural idle motion, §3) | unchanged silhouettes | per-archetype idle profile |

Roster-only mappings (in `ROSTER_MODELS`, no TYPES entry, no
invented stats, no spawn): Vampire Bat (normal variant, wingspan →
1.70 m, hover +1.10, frost variant + statics + Plane removed),
Brigand (PS1 bandit, Plane removed, body texture re-linked),
Revenant (PS1, splayed 6.20 m rest width noted), Daemon (FLARE),
Pirate Ghost (own creature, ShadowPlane removed), Skeleton Outlaw
(FBX, 67 bones, "Default Take" clip), and the remaining PS1 pack
(cannae, cereptera, clod, helichard, janga, myocene, rattler,
tardigrade, ungulate — all texture re-linked).

## 3. What changed in code

- `scripts/monster_models.gd` (NEW): `MODELS` (14 wired) +
  `ROSTER_MODELS` (15 roster) + `HELD_MARKERS` blocklist +
  `is_held_path()`. Every entry carries the measured target, axis,
  y-offset, junk-node removals, texture, anim preference, and honest
  clip mapping (empty where clips are unnamed).
- `scripts/enemy.gd` (model-builder sections + motion only):
  - `_build_model()` now consults the registry: deletes junk nodes
    BEFORE measuring (Troll ShadowPlane 20×20 m; rat Planes +
    exploded Hair mesh), normalises on the registry axis to the
    registry target, grounds the AABB minimum, adds y_offset,
    re-links the registry PNG onto every duplicated surface material,
    forces `vertex_color_use_as_albedo` where a mesh carries vertex
    colours (Gobkit community imports leave one surface per model
    flagged off, which would render white), and accepts OBJ
    `ArrayMesh` resources (wraps them in a MeshInstance3D).
  - Baked PI yaw kept for all models (live convention); per-model
    facing still needs an editor eyeball pass — headless import
    cannot prove facing.
  - `_ready()` sets `_proc_motion` when no clip is playing (static
    wired models + all placeholders); `_process()` adds gentle idle
    motion (hover / scurry / skitter / slither / sway / breathe).
    Attack timing stays in `behaviors.gd` and death stays main.gd's
    0.22 s squash-and-vanish tween — this layer does not fight them.
    Live animated types are unaffected.
- `.import` generation (wired models + their textures only): the real
  project's `--import` aborts on the `.blend` files (headless Blender
  path unset), so imports were produced in a mirror project
  (`/tmp/wave2-mirror`, same res:// paths, no .blend files) and the
  resulting 20 `.import` files + `.godot/imported/` entries were
  copied into the real project. No `.import` was generated for any
  HELD, roster-only, or other worker's file.

## 4. Calls made (honest, recorded)

- **Pirate ghost → Wraith: REJECTED.** It imports as a zombie mesh +
  Gibs with a 20×20 m ShadowPlane, flat materials, and 2 unnamed
  clips; its "ghost" read depends on an alpha setting that does not
  survive in the GLB. Wraith uses Gobkit SheetGhost (a true ghost).
  Pirate ghost is rostered as its own creature.
- **Skeleton-with-rig → Skeleton variant: REJECTED.** Its 8 meshes
  are bone-visualisation geometry (BONES_RIBCAGE, BONES_ARM_L, …),
  237 bones, 0 clips, AABB 16.84×37.51×5.56 m — not a skinned body.
  It is not in the registry at all. Live Skeleton keeps Quaternius;
  Skeleton Archer uses the Crossbowman; Skeleton Outlaw is rostered.
- **Kenney zombie / protagonist: NOT wired.** The zombie FBX imports
  rigged (58 bones) but with 0 clips — its animations live in
  separate FBX files — and its rest pose is a T-pose statue. Wiring
  it static would be worse than the upgraded procedural zombie.
  Kenney remains a future animation-retargeting job, not a wire.
- **Stand-ins rejected, not wired:** Dingo → Wolf (canine, not wolf),
  Bee → Wasp (bee, not wasp), Eagle/Owl → Harpy (birds, not harpies),
  Gobkit minions → Goblin/Kobold (generic blobs, not goblin-kin),
  all 3DAssets.dev models (HELD), Gobkit Scorpion (recorded alternate
  to the PS1 scorpion — one mapping per type).
- **Troll / pirate-ghost / outlaw clips:** unnamed clips are played
  but never labelled idle/walk/attack. The test pins Troll to the
  first clip (`Action`) explicitly as "mapping not invented".
- **Bandit weapon texture:** `enemy_bandit_weapon.png` is NOT
  per-surface mapped (PS1 meshes are not named by part); roster-only,
  so it blocks nothing. Recorded gap.

## 5. Rat outcome — re-download SUCCEEDED

One attempt, from the OGA item page direct file
(`opengameart.org/sites/default/files/rat_2.blend`): **6,833,728
bytes** (matches the page's 6.8 MB), Blender 2.75, containing a full
rat — Armature + Body/Head/Eyes/Hair/Teeth meshes + 14 actions
(Attack, Die, Hit, Idle, Run, Stand, Walk, …). The staged
`rat.blend`/`rat.glb` (1,028,612-byte fragment: one camera + one
cylinder, 0 armatures) were left untouched. The fresh file was staged
as `rat_full.blend` and exported (Blender 4.5.3, same method as Wave
1B, one harmless "region type 4" warning) to `rat_full.glb`
(1,573,452 bytes, valid glTF, 7 meshes, 1 skin, 39 bones, 14 clips).
Import check: PASS with removals — the two 2×2 m ground Planes and
the exploded Hair mesh (15×17×25 m) are deleted on wiring; the
remaining body is sane (Body 1.17×1.41×4.48 m). Idle_000 is a 64.7 s
timeline, so Idle_001 (3.75 s) is the idle clip. **Cave Rat is wired
to the real rat; the cylinder is not wired anywhere.**

## 6. Dragon — static only, NOT wired

`dragons/dragon/dragon.glb`: imports PASS (1 mesh, 2 surfaces, no
skeleton, no UVs, 1 zero-length `BodyAction` pose clip, vertex
extents 281×444×631). It is **not wired as an enemy and not a Drake
replacement** (Drake uses the animated Gobkit Wyvern). Noted here as
a static-only asset: possible future decoration, after rescale
(±315 units) + UV unwrap + rigging from scratch.

## 7. PS1 texture re-link outcome

**Done in Godot materials, no Blender re-export needed.** All 13 PS1
GLBs carry UVs and StandardMaterial3D surfaces; only the texture
links were lost. `_build_model()` now sets the registry PNG as
`albedo_texture` on every duplicated surface material for the two
in-game PS1 wires (cobracon, scorpion), and all 13 PNG paths are
recorded in the registry (roster entries included). The new test
proves every surface of both in-game PS1 wires has a texture after
spawn — no grey static enemy ships. (Bandit weapon-texture split: see
§4.)

## 8. Test results (Godot 4.7.2, headless)

- `tests/monster_models_test.gd` — **ALL PASS** (NEW: registry shape,
  file existence, HELD/stand-in bans, per-type spawn at target size,
  grounding/hover, junk removal, clip presence, texture re-link,
  procedural motion on/off, motion smoke check).
- `tests/staged_monsters_test.gd` — **ALL PASS** (honest-claim check
  updated: wired types have a model key, procedural types must not).
- `tests/placeholder_models_test.gd` — **ALL PASS** (loops now cover
  the 11 procedural types; ghost translucency check moved to the
  banshee — SheetGhost is opaque; facing/sleep/silhouette checks kept).
- `tests/model_balance_test.gd`, `tests/sfx_hooks_test.gd`,
  `tests/audio_manager_test.gd`, `tests/smoke_test.gd`,
  `tests/texture_check.gd` — **ALL PASS** (the two "ERROR" lines in
  output are pre-existing harness noise: a deliberate
  DoesNotExist.fbx negative case, and resources-in-use at exit).
- Scene suites: `turn_based_scene` — **ALL PASS**;
  `facing_backstab_scene` — **ALL PASS**;
  `depth_scale_scene` — **ALL PASS** (3000 s virtual soak, exit 0;
  it exceeds the 120 s per-scene harness limit, so it was re-run
  with a 600 s timeout).

## 9. What remains unmapped / future work

- **Procedural (11):** spider, wasp, frog, wolf, zombie, golem,
  kobold, pixie, harpy, oni, banshee — upgraded placeholders with
  idle motion; real models still needed (true spider, wasp, frog,
  wolf, zombie-with-animations, oni, banshee above all).
- **Roster-only (15):** need TYPES entries + balance + spawn wiring
  by a future task (no stats invented here).
- **Visual pass (editor, not headless):** per-model facing (baked PI
  yaw), goblin/kappa bind poses, Troll clip identification (which
  Action is idle/walk/attack), SheetGhost sparse-indices warnings
  (import succeeds; the GLTFDocument path logs them), bandit weapon
  texture split, PS1 limb pivots (procedural limb animation was not
  attempted — root bob/sway only).
- **Credits (for the parent):** FLARE Troll (CC-BY 3.0, VWolfdog) and
  snappaKappa (CC-BY 4.0, MNDV.ecb, after crisisworks) carry
  REQUIRED attribution if they ship; Crossbowman Skeleton is CC-BY
  4.0 (CoinCoin). Everything else wired is CC0.
- **No-spawn contract holds:** `dungeon_gen._pick_type()` untouched;
  wired models are reachable only by spawning a type directly (as
  the tests do), not by gameplay.
