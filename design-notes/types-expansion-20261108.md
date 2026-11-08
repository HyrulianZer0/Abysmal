# TYPES expansion — 28 → 300 entries (Nov 8, 2026)

`scripts/enemy.gd` `TYPES` now holds one entry per bestiary row that has a
ROSTER model. Generator + per-entry provenance:
`~/workspace/build/types-expansion-20261108/generate_types.py` (reproducible),
`derivation.json` (per-entry field sources), `derivation_summary.json`
(median tables, flags). Pre-change backups of all 5 touched files are in
the same directory (`MANIFEST.txt`).

## The count — read this first (the brief's "277" is not the table total)

- **TYPES is now 300 entries: 28 staged (untouched, byte-identical) + 272 new.**
- The brief said "final count (must be 277)". That number is the count of
  **bestiary rows covered**, not the table total — and it is met: **277
  entries now cover bestiary rows** (272 new + the 5 MODELS-only already in
  TYPES: zombie, pixie, harpy, oni, banshee). A table total of 277 would
  require deleting 23 live staged types (slime, bat, skeleton, rat, …),
  which spawn, have voice mappings, and are pinned by tests — so it was
  not done.
- Why 272 new, not 277: ROSTER has **277 bestiary-path keys**, of which 5
  are the golem variants (golem-fire/ice/stone/storm/water) — variants of
  the Clay Golem, not INDEX creatures. 272 = the ROSTER bestiary-path keys
  that are INDEX creatures (271 joined by name + `wolf_bestiary` = Wolf).
- Distinct INDEX creatures covered: **296 of 300**. Uncovered (4):
  **Hellhound** (no ROSTER row, no model), **Vampire Bat**, **Revenant**,
  **Brigand** (ROSTER rows exist but their models are Phase-1/PS1 wires,
  not `/bestiary/` models; their ROSTER notes mark them roster-only /
  future wire-up). Adding those 3 is a small follow-up if the director
  wants them.
- **Golem variants (5) deliberately excluded** from TYPES: not bestiary
  creatures, no INDEX row, no behavior-spec section, and the
  variant-selection mechanism is still undecided. They stay ROSTER-only.
- Double-covered creatures (2): **Cave Frog** (`frog` staged + `cave-frog`
  new) and **Cave Wasp** (`wasp` staged + `cave-wasp` new). The new entries
  use the family median, which lands within 1–3 points of the staged
  counterparts — a good sanity check on the rule. (Wolf is NOT double:
  staged `wolf` is "Cave Wolf", which is not an INDEX row; `wolf_bestiary`
  is the INDEX "Wolf". Ghost/"Wraith" likewise has no INDEX row.)

## Method — how every field was derived (no invented stats)

Sources: `design-notes/model-guides/INDEX.md` full-mapping table (300 rows:
name/family/archetype dir), `scripts/monster_models.gd` ROSTER (model path),
`design-notes/behavior-specs.md` (all 300 creatures have Move + Attack
lines — all 272 new entries got both), the 28 staged TYPES rows.

| Field | Derivation |
|---|---|
| `name`, `family` | INDEX row, verbatim (base name, parenthetical "(also …)" stripped). 8 names keep diacritics (Ōmukade, Púca, Chōchin-obake, Jorōgumo, Cat Sìth, Mušḫuššu, Bhūta, Piśāca) — UTF-8 in the .gd file, same as the existing "Japanese Yōkai" family strings. |
| `model` | ROSTER model path, verbatim. All 272 files verified on disk. |
| `hp`/`atk`/`def`/`xp`/`gold` | **Family median** of the staged rows in that family (round-half-up to whole numbers, matching the staged data's shape). Uncovered family → archetype-dir median; plant-fungal (no staged row in that dir) → global median. See tables below. |
| `band` | Family majority band; ties → D; uncovered family → D. No `Dp` among the new entries (only banshee is Dp). Band is data-only: `dungeon_gen` spawn tables are hardcoded, so spawning is unchanged. |
| `archetype` | Keyword map over the behavior-specs Attack+Move text (e.g. "spit/bolt/wail" → caster, "sting/venom" → venom skirmisher, "grab/constrict" → grappler/tank, "charge/ram" → charger, "swarm" → swarmer). Outputs restricted to the staged ARCHETYPES vocabulary (the 23 strings `staged_monsters_test` allows). Fallback = archetype-dir default. Per-entry keyword logged in `derivation.json`. |
| `behavior` | Behavior-specs Attack line, cleaned, capped at 110 chars at a word boundary. Unique across all 300 (checked); all > 20 chars. Style note: the 28 keep their hand-written paraphrases; the 272 are spec Attack lines, so they read slightly longer/more formal. |
| `sound_vocal` | Keyword map reusing one of the 28's PROCEDURAL vocal specs verbatim (e.g. "hiss" → snake's hiss, "wail" → banshee's wail, "roar" → orc's/drake's roar). Fallback = family representative's vocal, then dir representative's. No new vocal specs invented except one neutral for plant-fungal (see flags). |
| `sound_steps` | Dir locomotion rule: winged → "none (flies…)"; ghost-wisp → "none (floats…)"; blob-ooze → slime's squelch; worm-serpent → snake's slither; spider-arachnid → scorpion's chitin skitter; aquatic → "none (swims…)" if the spec mentions swimming, else frog's hop-thump; walkers → family rep's footstep file, else the dir default file. |
| `sound_attack` | `ranged` → skeleton_archer's bow twang; `caster` → pixie's dazzle chime (winged) or banshee's glass file; `flyer/brute` + fire → drake's fire-breath; else family rep's Kenney file, else dir rep's file, else `impactGeneric_light_000.ogg`. Every emitted `res://` sound path verified to exist on disk. |
| `color`/`mesh`/`squash` | Archetype-dir representative's values (slime, snake, wolf, skeleton, harpy, spider, frog, ghost, golem). Fallback-only fields (used only if the model fails to load — `_build_placeholder` returns false for unknown keys, then `_build_primitive` runs). Plant-fungal has no staged rep → flagged neutral (see flags). |
| `build` | The ROSTER key (same convention as the 25 wired staged types). |
| `anim`, `body_h` | Omitted, like all Wave 1/2/5 entries — the registry carries them (`_build_model` reads anim/target from `MonsterModels.for_type` first). |

## Family / dir / global median tables (hp / atk / def / xp / gold)

Family medians (12 families have staged rows):

| Family | n | hp | atk | def | xp | gold |
|---|---|---|---|---|---|---|
| Oozes & Slimes | 1 | 18 | 4 | 0 | 8 | 8 |
| Vermin & Cave Crawlers | 7 | 12 | 5 | 0 | 9 | 8 |
| The Undead | 5 | 22 | 7 | 0 | 16 | 15 |
| Beasts | 3 | 22 | 7 | 0 | 14 | 11 |
| Goblin-Kin & Cave Folk | 2 | 14 | 5 | 0 | 9 | 14 |
| Golems & Constructs | 1 | 45 | 8 | 3 | 22 | 16 |
| Demons, Devils & the Damned | 1 | 10 | 6 | 0 | 12 | 10 |
| Fey & Nature Spirits | 1 | 7 | 4 | 0 | 10 | 12 |
| Orcs, Trolls & Giant-Kin | 2 | 40 | 8 | 2 | 21 | 15 |
| Greek & Mediterranean Myth | 2 | 29 | 8 | 1 | 21 | 16 |
| Japanese Yōkai | 2 | 34 | 8 | 2 | 23 | 15 |
| Dragons & Great Serpents | 1 | 34 | 8 | 1 | 24 | 20 |

Dir medians (fallback for the 16 uncovered families): blob-ooze 18/4/0/8/8;
winged 12/6/0/11/12; biped-humanoid 30/6/1/18/14; quadruped-beast 17/6/0/11/8;
spider-arachnid 14/5/0/9/8; worm-serpent 20/6/0/12/10; aquatic 13/4/0/8/8
(frog only — Kappa is biped-humanoid in the INDEX); golem-construct
45/8/3/22/16; ghost-wisp 22/9/0/22/15 (banshee only). Global median (last
resort): 19/6/0/14/12.

New-entry distributions: band T 87 / D 185; archetype caster 52, ambusher
30, ranged 24, charger 24, pack skirmisher 23, brawler 21, brute 19,
grappler/tank 19, venom skirmisher 15, phase skirmisher 13, flyer/skirmisher
6, tank 6, swarmer 5, trapper/swarm 5, charger/brute 3, flyer/brute 3,
skirmisher 3, tank/regen 1.

## What fell back to a default (flags — all in `derivation.json`)

- **121 entries** in uncovered families → stats from the archetype-dir
  median (not their family's — their family has no staged row).
- **44 entries** in single-row families → the "median" is that one
  creature's stats. Worst cases: **Fey & Nature Spirits = pixie stats
  (7/4/0/10/12)** — Dryad / Elder Dryad at 7 HP is the most obviously
  wrong default; **Oozes = slime (18/4/0)**, **Golems = Clay Golem
  (45/8/3)**, **Demons = imp (10/6/0)**, **Dragons = drake (34/8/1)**.
  These five families want a director-set default before anyone tunes
  individual creatures.
- **9 entries** → global median (plant-fungal creatures in uncovered
  families: no family row and no dir row).
- **130 entries** → band default D (uncovered family, no majority to read).
- **47 entries** → archetype fell back to the dir default (no keyword in
  the spec text).
- **110 entries** → vocal fell back to the family rep's spec; **106** →
  dir rep's spec. (Keyword map fired for ~48; the rest reuse a staged
  vocal, flagged per entry.)
- **11 plant-fungal entries** → neutral look (Color(0.4, 0.55, 0.3), box,
  Vector3(0.8, 1.1, 0.8)), neutral steps (footstep_concrete_000), and
  **8** of them → neutral vocal ("low creak and leaf-rustle"); **9** →
  generic attack file (`impactGeneric_light_000.ogg`). These are the only
  newly written values in the whole expansion (everything else is copied
  from existing data) — they are the first things to replace with real
  plant/fungal specs.
- **0 invented stats**: every number is a median of staged rows; every
  sound is a staged file/spec reused verbatim; every behavior line is a
  spec Attack line.

## Test updates (4 files — all in the backup dir first)

- `tests/placeholder_models_test.gd`: `TYPES.size() == 28` → `== 300`
  (message + header comment updated).
- `tests/staged_monsters_test.gd`: size check `== all.size()` (28) →
  `== 300`; header note added. Per-entry checks still cover only the 28
  staged types.
- `tests/monster_models_test.gd`: the roster guard is **inverted** for
  bestiary rows — it used to assert "roster row has NO TYPES entry (no
  invented stats)". Now: bestiary-path rows MUST have a TYPES entry whose
  `model` matches the registry; non-bestiary rows and the 5 golem variants
  (`GOLEM_VARIANTS` const) must NOT have one. The old guard's premise
  (no staged type exists for roster rows) was retired by the director's
  Nov 7 decision.
- `tests/enemy_integration_test.gd`: **"bone-golem" removed from the banned
  list.** The ban's stated reason was "no matching staged type" — the Bone
  Golem now has a staged ROSTER type + model file
  (`bestiary/golem-construct/bone-golem.glb`, verified on disk), so the
  premise is obsolete. Cerberus / animated-cerberus / jalastram-voice-008
  stay banned.
- NOT touched (verified they don't need it): `voice_map_test` (its own
  28-entry voice table, unchanged), `wave3_spawn_test` (hardcoded spawn
  table of 28, unchanged), `model_balance_test` (skeleton/slime/bat pins),
  `enemy_integration_test`'s hardcoded 28-type triangle (iterates its own
  list, not TYPES).

## Test results (Godot 4.7.2 headless, `godot --headless --path . --script tests/<name>_test.gd`)

Baseline (before the change) vs after, same 11 suites:

| Suite | Before | After |
|---|---|---|
| placeholder_models | PASS | PASS |
| staged_monsters | PASS | PASS |
| monster_models | PASS | PASS |
| enemy_integration | 1 fail | 1 fail (flaky — see below) |
| wave3_spawn | PASS | PASS |
| wave3_soak | PASS | PASS (depth-1 table now 300 lines; bounds hold: worst TTK 12 ≤ 15, worst enemy TTK 6 ≥ 4, worst single hit 24.6 < 50) |
| voice_map | 3 fails | 1 fail (flaky — see below) |
| model_balance | PASS | PASS |
| behaviors | PASS | PASS |
| smoke | PASS | PASS |
| wave3_fallback | PASS | PASS |

**No regression.** The remaining failures are pre-existing container audio
flakiness, confirmed by re-runs: `enemy_integration` passed clean on one
re-run and failed "slime idle vocal plays" on the next (baseline had failed
"slime attack vocal plays" — same slime-vocal playback check, different
sub-check per run); `voice_map` swung 3 → 1 → 3 failures across runs
("play banshee death/idle", "voice calls actually playing" flip run to
run). The one **stable** failure in both baseline and after is
`voice_map`'s "all wired clips exist and load": 5 clips load null
(`rd1-burble_01/02`, `rd1-bug_01/02/03`) — the known container import wall
(no `.import` files headless), unrelated to TYPES. Full sweep of all 14
`*_test.gd` suites: 11 pass; the 3 failing suites are the ones above plus
`apex_bosses_test` (1 fail — "Typhon: abyssal unwired, dragon primary
resolves", the known pre-existing Nov 7 failure, separate item, untouched
by this change).

## Still open

- Hellhound (no model at all) + Vampire Bat / Revenant / Brigand
  (non-bestiary ROSTER models) have no TYPES entry — 4 of 300 INDEX rows
  uncovered. Director call whether to wire the 3 PS1/Phase-1 models.
- Golem variants (5) need the variant-selection mechanism decided before
  they get TYPES entries (if ever — they may stay ROSTER-only).
- Single-row family defaults (above) want director-set values, especially
  Fey (pixie stats on Dryads) and Oozes (slime stats on Primordial Ooze).
- Plant-fungal neutral look/steps/vocal/attack file are placeholders.
- New types are **not in any spawn table** (`dungeon_gen` tables are
  hardcoded to the 28) and have **no voice_map entries** (TYPE_VOICE stays
  28) — wiring them into spawning/voices is a separate systems step, not
  part of this expansion.
- Behavior strings for the 272 are spec Attack lines (longer than the 28's
  paraphrases) — a style pass is optional.
