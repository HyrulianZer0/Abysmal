# Wave 2b — AI-model + election-golem wiring (Oct 29, 2026)

**Engine:** Godot 4.7.2 headless. **Scope:** `scripts/monster_models.gd`
(registry entries + HELD-marker update), `scripts/enemy.gd` (TYPES
`model` keys only — no stats, no `setup()`, no combat, no scaling
curves), 4 test files (honest-state updates only), `.import` +
`.godot/imported/` sidecars for the 3 wired models only, 7 Blender
re-exported `*_godot.glb` conversion artifacts, and this doc.
**Untouched:** `setup()`, combat, scaling curves, spawn picker,
`scripts/apex_bosses.gd`, `scripts/behaviors.gd`,
`scripts/voice_map.gd`, `scripts/dungeon_gen.gd`, all audio, all
drops. **No APK, no release, no publish, no upload.** Credits use
**Aethelwarden Solas** only. No AI-use disclaimer text is added
here — the approved disclaimer lives in
`design-notes/credits-and-attribution.md` and is not duplicated.

## 0. Decisions this wave rests on (Oct 29, 2026)

- James APPROVED the 3DAssets.dev AI-generated models **in
  principle** — the Wave 2/4 hold on them is LIFTED — but he has
  **NOT visually reviewed them**. Every model wired here is
  therefore flagged **VISUAL REVIEW REQUIRED** (registry note +
  §3 table below): it must get his in-editor eyeball pass before
  shipping. Headless checks below prove import, scale, clips, and
  materials — they cannot prove a model *looks* like its creature.
- James CONFIRMED the CC-BY 3.0 elections "to its fullest extent"
  (attribution-only terms) for Fire/Ice/Stone Golem and Bone Golem.
  The golem wire below uses the election model; its REQUIRED
  attribution is recorded in the registry note and in §3.
- Cerberus is NOT this wave's scope (apex boss, separate worker):
  no Cerberus file is wired, referenced, or touched here, and
  `animated-cerberus` stays a HELD marker.

## 1. Blender re-export pass (Blender 4.5.3, portable)

Wave 4's verdict was re-verified file by file before any wiring:
all 7 failing originals carry `extensionsRequired:
KHR_mesh_quantization` (Godot 4.7.2 does not support it), and
StoneGardenGolem carries no required extension. Blender 4.5.3
imports all 7 cleanly and re-exports them with the quantization
stripped. Originals are untouched; conversions sit beside them as
`*_godot.glb` so the provenance stays visible.

| Model (original) | Blender import | Re-export | Converted file | Quantization after |
|---|---|---|---|---|
| CityWolf.glb | PASS (7 meshes, 3 actions) | PASS (216,056 B) | `beasts/3dassets/CityWolf_godot.glb` | gone (extRequired: none) |
| CellarSpider.glb | PASS (2 meshes, 0 actions) | PASS (244,420 B) | `vermin/3dassets/CellarSpider_godot.glb` | gone |
| GoblinScavenger.glb | PASS (17 meshes, 4 actions) | PASS (638,124 B) | `goblin-kin/3dassets/GoblinScavenger_godot.glb` | gone (EXT_texture_webp remains, see §4) |
| SkeletonWarrior.glb | PASS (19 meshes, 4 actions) | PASS (795,092 B) | `undead/3dassets/SkeletonWarrior_godot.glb` | gone (EXT_texture_webp remains) |
| CornSnake.glb | PASS (4 meshes, 0 actions) | PASS (141,888 B) | `dragons/3dassets/CornSnake_godot.glb` | gone (EXT_texture_webp remains) |
| EasternDragon.glb | PASS (6 meshes, 0 actions) | PASS (249,380 B) | `dragons/3dassets/EasternDragon_godot.glb` | gone |
| WesternDragon.glb | PASS (6 meshes, 0 actions) | PASS (294,968 B) | `dragons/3dassets/WesternDragon_godot.glb` | gone |
| StoneGardenGolem.glb | n/a (already parses) | n/a (used as-is, not wired — see §3) | — | none ever |

Re-export quirk, recorded not hidden: the converted GLBs keep
Blender's normalized mesh data with the real size carried on node
scales (e.g. CityWolf head scale 0.273, torso 0.582). Godot
composes those scales on import, and `enemy.gd` normalisation
preserves node scales (same as the Wave 2 PS1 rattler note) — the
mirror-project measurements in §2 are post-composition scene
sizes, so the quirk changes nothing in game.

## 2. Godot import verification (mirror project, then real project)

The real project's `--import` still aborts on the `.blend` files
(headless Blender path unset — same as Wave 2; the run printed
the Blender-path ERROR and exited 0 without producing new
`.import` files), so — per the Wave 2 method — imports were
produced in a mirror project (`/tmp/wave2b-mirror`, same res://
paths, no `.blend` files) and the resulting `.import` files +
`.godot/imported/` entries were copied into the real project for
the 3 wired models only. Mirror import: exit 0 for all 8 files,
one benign WARNING ("load-time scene is not defined in the glTF2
file. Picking the first scene") on one file — import succeeds
regardless. No ERROR lines that matter. All measurements below
are the editor-imported scenes walked headlessly (meshes,
skeletons, AnimationPlayer clips, textured surfaces, scene AABB).

| Model (as imported) | Import | Meshes | Skeleton | Clips | Textured surf | Scene AABB (m, x × y × z) |
|---|---|---|---|---|---|---|
| CityWolf_godot.glb | PASS | 7 | none (node anims only) | idle, head-turn, tail-wag (1 ch each) | 0/7 (1 flat-colour material) | 0.52 × 0.99 × 2.09, min y 0.00 |
| CellarSpider_godot.glb | PASS | 2 | none | none (static) | 0/2 (flat colours) | 0.60 × 0.21 × 0.44, min y 0.00 |
| GoblinScavenger_godot.glb | PASS | 17 | none (node anims only) | idle, arm-swing, weapon-raise, head-turn | 3/17 (webp texture survives) | 0.48 × 1.17 × 0.38, min y 0.00 |
| SkeletonWarrior_godot.glb | PASS | 19 | none (node anims only) | idle, arm-swing, weapon-raise, head-turn | 13/19 (webp textures survive) | 0.61 × 1.97 × 0.37, min y 0.00 |
| CornSnake_godot.glb | PASS | 4 | none | none (static) | 3/4 (webp texture survives) | 0.25 × 0.07 × 0.23, min y 0.00 |
| EasternDragon_godot.glb | PASS | 6 | none | none (static) | 0/6 (flat colours) | 4.96 × 3.12 × 6.63, min y 0.00 |
| WesternDragon_godot.glb | PASS | 6 | none | none (static) | 0/6 (flat colours) | 13.33 × 4.46 × 6.61, min y 0.00 |
| StoneGardenGolem.glb (original) | PASS | 4 | none | none (static) | 0/4 (flat colours) | 1.44 × 1.70 × 0.51, min y 0.00 |
| Fire/Ice/Stone golem.glb (original, no re-export needed) | PASS | 1 (3 surf) | 44 bones | idle, attack, attack2, die, flinch, walk (+ ArmatureAction_001 full timeline, unused) | 0/3 (flat 'iceBaked' grey) | 5.54 × 6.22 × 3.48, min y **+4.04 (floats — grounding fixes it)** |
| BoneGolem OBJ (original) | PASS with 1 ERROR line | 1 (ArrayMesh) | none | none (static) | 0/1 — **its .mtl file is missing** (`Bone_Golem.mtl` referenced by the OBJ is not staged), so the staged `Bone_Golem_Diffuse.png` is NOT linked on import | 6.61 × 4.27 × 1.43, min y −0.01 (splayed rest pose) |

No wired model ships at raw import scale: every wire is
height-normalised in `enemy.gd` exactly as Wave 2 did.

## 3. What got wired — and what got flagged, not wired

### WIRED (3) — all flagged VISUAL REVIEW REQUIRED before shipping

| Type | Model | Norm → target | Motion | Why this read |
|---|---|---|---|---|
| Cave Spider | 3DAssets.dev CellarSpider, re-exported (`CellarSpider_godot.glb`, CC0, AI-generated) | height → 0.50 m (scorpion parity; leg span ~1.42 m) | static + procedural skitter | A true spider: dark-iron long-legged body (6672 verts) + teal magic accent (2640 verts). Replaces the procedural spider. |
| Cave Wolf | 3DAssets.dev CityWolf, re-exported (`CityWolf_godot.glb`, CC0, AI-generated) | height → 0.85 m (boar parity; body length ~1.79 m) | idle clip only (head-turn / tail-wag exist but are NOT claimed as attack/walk/death — no such clips exist; attack timing lives in behaviors.gd) | A true wolf: 7 meshes (head / torso / 4 paws / tail), quadruped proportions. Replaces the procedural wolf. |
| Clay Golem | Fire/Ice/Stone Golem (`golem.glb`, CC-BY 3.0 election confirmed Oct 29) | height → 1.90 m | idle / attack / die / walk (honestly named clips) | A true golem, animated and skinned (44 bones) — strictly better than the procedural golem AND the static garden ornament. REQUIRED attribution if it ships: **"Fire/Ice/Stone Golem by umask007"**. OPEN EYEBALL QUESTION: its material is flat ice-baked pale grey, not clay — if James wants a clay read specifically, this wire is the thing to revisit on visual review. The +4.04 m raw float is fixed by grounding (box-min to 0), proven by the spawn test. |

### FLAGGED, NOT WIRED (7) — each with its reason, no forced fits

| Model | Reason not wired |
|---|---|
| StoneGardenGolem (original, parses fine) | Garden-ornament read confirmed on re-check: pale moss-green / bark / leaf / mint-glow flat materials, only 0.51 m deep (flat-backed ornament), static, untextured. Wrong for the Clay Golem, and now doubly unnecessary beside the animated election golem. |
| GoblinScavenger (re-exported, imports fine) | Redundant and worse than the incumbent: the Goblin already has the OGA goblin.glb (skinned, 39 bones). The Scavenger is unskinned node-animation only, carries a weapon, and is unreviewed. Displacing a better goblin with it would be a downgrade. |
| SkeletonWarrior (re-exported, imports fine) | Redundant: the live Skeleton keeps Quaternius and the Skeleton Archer uses the Crossbowman. A second, unskinned, node-animated skeleton warrior adds nothing to either slot. |
| CornSnake (re-exported, imports fine) | Wrong read: a realistic corn snake (small, flat, 0.25 × 0.07 × 0.23 m, static) is NOT a better dungeon serpent than the incumbent PS1 cobracon (raised cobra). Judged honestly, not forced. |
| EasternDragon / WesternDragon (re-exported, import fine) | No matching staged type in the 28 (Drake already has the animated Gobkit Wyvern; a dragon is not a drake wire), both static, generic, unreviewed. Western raw wingspan 13.33 m would normalise fine — scale was never the blocker; the read was. |
| Bone Golem (OBJ, imports with a missing-MTL ERROR) | No matching staged type (there is no Bone Golem in the 28), static, splayed 6.61 m rest width, and its texture is unlinked because `Bone_Golem.mtl` is not staged. It stays a future/variant item, not a forced fit onto the Clay Golem (which already has the better animated election golem). Its CC-BY 3.0 election is confirmed, so the blocker is fit, not license — REQUIRED attribution if ever wired: **"Bone Golem by Mophs (concept Nubux)"**. |

HELD markers after this wave: `animated-cerberus` and `bone-golem`
only. `3dassets` and `fire-ice-stone-golem` were REMOVED from
`HELD_MARKERS` because the holds behind them were lifted (AI
approval in principle; golem election confirmed) — the test suite
now enforces the two remaining holds instead, and
`enemy_integration_test.gd`'s source scan was updated the same
way. Cerberus is never named in any wired path.

## 4. Notes and gaps (honest)

- **EXT_texture_webp survives Blender re-export** on the three
  textured conversions (GoblinScavenger, SkeletonWarrior,
  CornSnake) and Godot imports them (textured-surface counts in
  §2 prove it). All three are flagged, not wired, so this blocks
  nothing — but any future wire of a webp-textured conversion
  should re-check texture delivery on a real device build.
- **No model here is skinned except the election golem.**
  CityWolf / CellarSpider / GoblinScavenger / SkeletonWarrior
  animations are node-transform tracks (1–2 channels), not
  skeletal clips. Wolf claims only its idle clip for exactly that
  reason.
- **Per-model facing still needs the editor eyeball pass** (same
  baked-PI-yaw caveat as Wave 2 — headless import cannot prove
  which way a model faces). This joins the visual-review flag on
  every wired model above.
- **Converted files for flagged models are kept** (`*_godot.glb`
  beside each original). They are conversion artifacts proving the
  re-export pass worked; they carry NO `.import` sidecar in the
  real project and no registry entry, so nothing can load them by
  accident.
- **StoneGardenGolem and Bone Golem have no `.import` in the real
  project** (mirror-only verification), matching the Wave 2 rule
  that sidecars are generated for wired models only.
- **Bone Golem's missing MTL** is a staging gap to fix if it is
  ever wired: stage `Bone_Golem.mtl` (or re-link the Diffuse PNG
  in Godot materials, as Wave 2 did for the PS1 pack).

## 5. Coverage counts (28 staged types)

- Live Quaternius (unchanged): 3 — Slime, Cave Bat, Skeleton.
- Wave 2 wired: 14 — Rat, Giant Serpent, Goblin, Wraith, Wild
  Boar, Cave Scorpion, Centipede, Skeleton Archer, Imp, Orc,
  Troll, Minotaur, Kappa, Drake.
- **Wave 2b wired: 3 — Cave Spider, Cave Wolf, Clay Golem.**
- **Real models total: 20 of 28.**
- **Still procedural: 8 of 28** — Cave Wasp, Cave Frog, Zombie,
  Kobold, Pixie, Harpy, Oni, Banshee (upgraded placeholders with
  procedural idle motion, as before).

## 6. Test results (Godot 4.7.2, headless)

Script suites — ALL PASS (15/15, exit 0 each):

- `tests/monster_models_test.gd` — ALL PASS (updated: WIRED 17,
  PROCEDURAL 8, ANIMATED adds wolf + golem; new section pins the
  VISUAL REVIEW flag on all 3 Wave 2b notes, the golem's REQUIRED
  attribution string, and the 3DAssets.dev source naming on
  spider/wolf).
- `tests/staged_monsters_test.gd` — ALL PASS (WIRED_TYPES 17).
- `tests/placeholder_models_test.gd` — ALL PASS (PROCEDURAL 8;
  TYPES-size string 3 + 17 + 8; composite sleep-tint check moved
  wolf → zombie, since wolf is a wired model now).
- `tests/enemy_integration_test.gd` — ALL PASS (source-scan ban
  list updated: `fire-ice-stone-golem` + `3dassets` removed per
  the lifted holds; `animated-cerberus`, `bone-golem`, flagged
  audio, and Cerberus still banned).
- `tests/apex_bosses_test.gd` — ALL PASS (untouched; apex files
  untouched, Cerberus absent).
- `tests/model_balance_test.gd`, `tests/sfx_hooks_test.gd`,
  `tests/audio_manager_test.gd`, `tests/smoke_test.gd`,
  `tests/texture_check.gd`, `tests/voice_map_test.gd`,
  `tests/behaviors_test.gd`, `tests/wave3_fallback_test.gd`,
  `tests/wave3_soak_test.gd`, `tests/wave3_spawn_test.gd` — ALL
  PASS. (The "resources still in use at exit" ERROR lines on
  scene runs are the pre-existing harness noise noted in Wave 2.)

Scene suites — run on FRESH saves (see note below):

- `tests/turn_based_scene.tscn` — ALL PASS (exit 0).
- `tests/facing_backstab_scene.tscn` — ALL PASS (exit 0).
- `tests/wave3_mainloop_scene.tscn` — ALL PASS (exit 0).
- `tests/depth_scale_scene.tscn` (600 s timeout,
  `--soak-virtual=3000 --soak-scale=16`) — ALL PASS (exit 0;
  3000 virtual seconds, 4 deaths with respawn, max depth 6,
  save round-trip PASS).

Fresh-save note (per the brief): the old shared-save fixture hash
(`5ab3b1260ff31e6114eb3f9ce57cc386`, Wave 3 doc) is GONE —
Wave 4's scene runs replaced `user://savegame.dat` with a
depth-test artifact. No suite here depends on that hash: each
scene run above deleted `user://savegame.dat` first (a backup of
the pre-run artifact was kept at `/tmp/wave2b/savegame-before-wave2b.dat`
only as a precaution), and no suite needed re-seeding.

## 7. What the next push needs

1. **In-editor eyeball pass on every wired Wave 2b model before
   shipping** — spider (leg/body read), wolf (facing, idle read),
   golem (facing, clay-vs-ice-stone read, clip identification
   beyond the honest names). This matters MORE, not less, now
   that the AI hold is lifted: James has not seen any of these.
2. **Credits screen entries** (parent's job, not code here):
   3DAssets.dev AI models (CC0) for spider + wolf, and the
   REQUIRED "Fire/Ice/Stone Golem by umask007" line for the
   golem. Bone Golem's "by Mophs (concept Nubux)" line is only
   needed if it is ever wired.
3. **Still procedural (8):** wasp, frog, zombie, kobold, pixie,
   harpy, oni, banshee still need true models; Bone Golem stays a
   future/variant candidate (fix its missing MTL first); the
   converted-but-flagged GoblinScavenger / SkeletonWarrior /
   CornSnake / dragons are NOT a backlog — they were judged and
   rejected for the reasons in §3, and re-proposing them needs a
   new read, not a re-run.
