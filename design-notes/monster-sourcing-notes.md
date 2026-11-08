# Monster Sourcing Notes — Staged Set, Wave 1 + Wave 2 (Oct 27, 2026)

**Status: STAGED ONLY.** Nothing here spawns. `scripts/dungeon_gen.gd`
`_pick_type()` is untouched and still returns only `slime` / `bat` /
`skeleton`; the placeholder test asserts no staged type id appears in
that file. No release build, no APK export, no upload, no publishing.

**Credits:** game credits use the pseudonym **Aethelwarden Solas** only.

## Locked balance (do not contradict)

Base `hp` / `atk` in `scripts/enemy.gd` `TYPES` are **depth-1 values**.
Live scaling (from `scripts/main.gd` `_new_depth()`):

- `hp = base_hp × depth^1.2`
- `atk = base_atk × depth^1.05`
- `def` stays **flat** at its base value at every depth.

Depth-10 spot checks (`hp_mult = 10^1.2 ≈ 15.85`, `atk_mult = 10^1.05 ≈ 11.22`):

| Monster | Base HP / ATK | Depth-10 HP | Depth-10 ATK |
|---|---|---|---|
| Pixie (frailest) | 7 / 4 | 111 | 45 |
| Troll (heaviest staged tank) | 48 / 7 | 761 | 79 |
| Clay Golem (existing) | 45 / 8 | 713 | 90 |
| Banshee | 22 / 9 | 349 | 101 |

Full per-monster data (family, band, archetype, behavior, sound spec)
lives in the `TYPES` entry itself in `scripts/enemy.gd` — this file is
the sourcing ledger, not a second copy of the stats. Behavior riders
named in specs (venom, regen, dazzle, grapple, AoE scream, fire-breath
cone, traps) are **future wiring, not staged mechanics**; the staged
behavior is posture, silhouette, and the written pattern.

## Counts, honestly

- **Total staged set: 28 types**
  - **3 live with real models:** Slime, Cave Bat, Skeleton — Quaternius
    *LowPoly Animated Monsters* (CC0), already in
    `assets/models/quaternius/` (see that folder's README.md).
  - **25 primitive placeholders, 0 real models:** every other type
    below is a composite of Godot primitives built by
    `_build_placeholder()` in `scripts/enemy.gd`, in the project's
    existing placeholder style. No model is claimed for any of them.
  - **0 new models downloaded in this workstream.** No itch.io
    download was attempted (see "Still missing" below).

## Sound: real vs placeholder, honestly

- **Real CC0 files, already staged in-project:** Kenney packs under
  `assets/audio/kenney/` (CC0, License.txt in each pack folder).
  Where a `TYPES` sound spec names a `res://assets/audio/kenney/...`
  path, that file exists on disk — the staged-monsters test checks
  every such path. These cover attack cues and footsteps only.
- **Procedural placeholder specs (no file):** every vocalization, and
  the attack/footstep cues marked `PROCEDURAL:` in `TYPES`. These are
  written synth specs (waveform + pitch envelope), not audio files.
  No vocal file is claimed to exist.
- **Not used:** freesound (requires an account) — deliberately avoided
  as a source. No new audio was downloaded.

## Consolidated staged list

Bands: T = Tutorial 1–10 · D = Delve 11–50 · Dp = Deeps 51–200.
All names/families are drawn from `design-notes/monster-roster-2026-10.md`
only; nothing outside the roster was invented. "Wraith" is the
pre-existing Wave 1 placeholder name (generic undead shade).

### Live (real Quaternius CC0 model)

| # | Monster | Family | Band | Archetype | Model |
|---|---|---|---|---|---|
| 1 | Slime | Oozes & Slimes | T | brawler | REAL — Quaternius CC0 |
| 2 | Cave Bat | Vermin & Cave Crawlers | T | flyer/skirmisher | REAL — Quaternius CC0 |
| 3 | Skeleton | The Undead | T | brawler | REAL — Quaternius CC0 |

### Wave 1 placeholders (pre-existing, metadata consolidated Oct 27)

| # | Monster | Family | Band | Archetype | Model |
|---|---|---|---|---|---|
| 4 | Cave Rat | Vermin & Cave Crawlers | T | swarmer | PLACEHOLDER |
| 5 | Cave Spider | Vermin & Cave Crawlers | T | ambusher | PLACEHOLDER |
| 6 | Giant Serpent | Beasts | T | ambusher | PLACEHOLDER |
| 7 | Cave Wasp | Vermin & Cave Crawlers | T | flyer/swarm | PLACEHOLDER |
| 8 | Cave Frog | Vermin & Cave Crawlers | T | skirmisher | PLACEHOLDER |
| 9 | Cave Wolf | Beasts | T | pack skirmisher | PLACEHOLDER |
| 10 | Goblin | Goblin-Kin & Cave Folk | T | skirmisher/swarm | PLACEHOLDER |
| 11 | Zombie | The Undead | T | tank/swarm | PLACEHOLDER |
| 12 | Wraith | The Undead | D | phase skirmisher | PLACEHOLDER |
| 13 | Clay Golem | Golems & Constructs | D | tank | PLACEHOLDER |

### Wave 2 placeholders (new, Oct 27)

| # | Monster | Family | Band | Archetype | Model |
|---|---|---|---|---|---|
| 14 | Wild Boar | Beasts | T | charger | PLACEHOLDER |
| 15 | Cave Scorpion | Vermin & Cave Crawlers | T | venom skirmisher | PLACEHOLDER |
| 16 | Centipede | Vermin & Cave Crawlers | T | skirmisher | PLACEHOLDER |
| 17 | Skeleton Archer | The Undead | T | ranged | PLACEHOLDER |
| 18 | Kobold | Goblin-Kin & Cave Folk | T | trapper/swarm | PLACEHOLDER |
| 19 | Imp | Demons, Devils & the Damned | T | flyer/caster | PLACEHOLDER |
| 20 | Pixie | Fey & Nature Spirits | T | flyer/caster | PLACEHOLDER |
| 21 | Orc | Orcs, Trolls & Giant-Kin | D | brute | PLACEHOLDER |
| 22 | Troll | Orcs, Trolls & Giant-Kin | D | tank/regen | PLACEHOLDER |
| 23 | Minotaur | Greek & Mediterranean Myth | D | charger/brute | PLACEHOLDER |
| 24 | Harpy | Greek & Mediterranean Myth | D | flyer/skirmisher | PLACEHOLDER |
| 25 | Oni | Japanese Yōkai | D | brute | PLACEHOLDER |
| 26 | Kappa | Japanese Yōkai | D | grappler/tank | PLACEHOLDER |
| 27 | Drake | Dragons & Great Serpents | D | flyer/brute | PLACEHOLDER |
| 28 | Banshee | The Undead | Dp | caster | PLACEHOLDER |

Behavior variety check: 23 distinct archetypes across the 28 (only
brawler, brute, and flyer/caster repeat, each with a different written
pattern); the staged-monsters test asserts unique behavior text per
type and ≥15 distinct archetypes.

## Materials (locked only — nothing invented)

Per the Oct 24 briefing lock and the materials list, only these are
stated here; everything else stays blank for James to fill in:

- Wolf → fur · Wild Boar → leather · Cave Spider → silk (locked examples)
- Light leather from small beasts, heavy leather from large beasts
  (bears and their weight class) — size-tier rule, not per-monster claims
- Teeth/fangs as Undercrucible reagents: grind for damage + a status
  effect, or mount on weapons directly (locked example: snake fangs,
  ground → damage + poison)

No other material mapping is asserted anywhere in this workstream.

## Files created / modified

- **Modified:** `scripts/enemy.gd` — 15 new `TYPES` entries, 15 new
  `_ph_*` placeholder builders + match arms, and family/band/archetype/
  behavior/sound keys consolidated onto all 28 entries. No change to
  `setup()`, combat, scaling, or spawning.
- **Modified:** `tests/placeholder_models_test.gd` — placeholder list
  extended 10 → 25, count assertion 13 → 28, banshee translucency
  check, and a staged-only spawn guard (no staged id in
  `dungeon_gen.gd`). This is an intentional scope update to that test,
  not a weakened assertion: every check it previously ran still runs,
  over more types.
- **Created:** `tests/staged_monsters_test.gd` — metadata completeness,
  archetype/band validity, unique behavior text, base-stat sanity,
  sound-file existence for every named `res://` path, honest
  model/placeholder claims, and the locked depth^1.2 / depth^1.05
  curves spot-checked at depth 10.
- **Created:** this file, `design-notes/monster-sourcing-notes.md`.
- **Untouched:** `scripts/dungeon_gen.gd` (spawn picker),
  `scripts/main.gd` (scaling), `scripts/combat.gd`, all audio and
  model assets, and every other test.

## Test results (Godot 4.7.2, headless, Oct 27, 2026)

- `tests/staged_monsters_test.gd` — **ALL PASS** (new)
- `tests/placeholder_models_test.gd` — **ALL PASS** (updated)
- `tests/model_balance_test.gd` — **ALL PASS** (unchanged, still pins
  slime/bat/skeleton base stats and flat defense)
- `tests/sfx_hooks_test.gd` — **ALL PASS** (unchanged)
- `tests/audio_manager_test.gd` — **ALL PASS** (unchanged)

Two iterations were needed on silhouettes (minotaur/oni over the
test's 1.8 height band; skeleton archer too close to the zombie's
box) — fixed by resizing builds, not by weakening the test.

## Still missing for a future push to ship these

1. **Quaternius packs — still outstanding, human clickthrough
   required.** The itch.io Quaternius lines named in the roster paper
   (*Animated Easy Enemies*, *Low Poly Animated Animals*, *Animated
   Knight*, and any dragon sibling in the *LowPoly Animated Monsters*
   line) were **not downloaded and not worked around** — itch.io needs
   a human clickthrough. Until a human stages them, all 25 staged
   types remain primitives. This is the single biggest art gap.
2. **Spawn wiring (deliberately not done):** extend
   `dungeon_gen._pick_type()` by depth band, with horde-floor
   weak-only rules, plus per-band spawn weights and balance soak.
3. **Behavior mechanics:** the written patterns are data only. Venom
   DoT, troll regen rate, banshee AoE, drake breath cone, kappa
   grapple, kobold traps, pixie dazzle, and the charge telegraphs need
   combat/AI implementation and tuning against the depth curves.
4. **Real sounds:** vocalizations for all 28 (procedural synth pass or
   a no-account CC0 pack staged by a human), plus bow/fire-breath/
   dazzle cues currently marked PROCEDURAL.
5. **Balance soak:** staged base stats are set by analogy to the live
   three and the Wave 1 placeholders; a real soak across depths 1–50
   (especially the D-band brutes/tanks at depth 10+) is needed before
   any of these go live.
6. **Materials list:** still unfilled by James except the three locked
   examples — drops cannot be finalized until he fills it.
7. **Next waves (roster room):** this set stops at 28 of the ~300
   roster bases. The obvious Wave 3 headliners from the roster paper
   are the Delve tribes and folklore heavyweights (orc shaman,
   hobgoblin, bugbear, harpy-adjacent Greek set, kappa-adjacent yōkai
   set) plus the first dragons beyond the drake — all still primitives
   until (1) is resolved.
