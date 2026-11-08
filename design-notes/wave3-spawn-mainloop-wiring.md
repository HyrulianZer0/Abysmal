# Wave 3 — Spawn wiring + main-loop wiring + balance soak (Oct 29, 2026)

**Engine:** Godot 4.7.2 headless. **Scope:** `scripts/behaviors.gd`
(alias fix only), `scripts/dungeon_gen.gd` (spawn table only),
`scripts/main.gd` (behavior wiring only), `scripts/enemy.gd` (vocal
dedupe + doc comments only), tests. **No APK, no release, no publish,
no upload.** Credits use **Aethelwarden Solas** only.

## 1. Fallback archetype fix (behaviors.gd ONLY)

Four TYPES strings are space forms — rat `swarmer`, wolf
`pack skirmisher`, ghost `phase skirmisher`, scorpion
`venom skirmisher`. Wave 2 resolved them only via the brawler
fallback, so their named mechanics never fired. The fix is ONE
mapping, `ARCHETYPE_ALIASES` + `canonical_archetype()`, applied by
both `profile_for()` and `update()` (which canonicalizes the first
half of a composite). TYPES strings are NOT renamed and
`BehaviorState.archetype` stays verbatim (saves, tests, and
enemy.gd's procedural-motion profiles all read the verbatim string).
Result: rat strikes `nip` with the swarm bonus, wolf `burst`s at
3+ allies for 1.5x, ghost `drift`s with the `shimmer` tell and takes
half damage, scorpion strikes `sting` with `tail_raised`.

## 2. Main-loop wiring (main.gd + enemy.gd hooks)

One shared tick, `_tick_enemy_behavior(e, delta)`, called from the
idle loop (real delta) and `_monster_turn()` (turn delta = 1.0s, so
a 0.8s charge telegraph lasts one turn, a 5s grapple hold five
turns, a 4s dazzle four turns). Manual mode still freezes without
input — update_behavior() is still never called from _process().

- Context is real: `player_pos`, allies within 6 tiles, `in_combat`
  within aggro, step-back room, `want_charge` (charger at 2–6
  tiles), `want_dive` (hovering flyer within 3 tiles).
- DoT: `behavior_venom_damage + behavior_grapple_damage` are dealt
  to the player through `GameState.damage_player()` (the single
  choke point — Agility dodge and defense skill apply).
- Movement: `_enemy_step_toward()` follows `behavior_move_dir`
  (dominant axis). Telegraph/stun/recover/hold/hidden/climb/perch
  never step; a blocked retreat/step-back stays put (no greedy
  fall-through); advance intents fall back to the greedy
  closest-cell step. Charger wall impact reports `wall_hit`
  (next tick stuns). Manual mode still moves exactly one cell per
  turn — `move_speed_mult` scales the idle step RATE, not distance.
- Strikes (`_enemy_strike()`): hidden ambushers reveal with a 1.5x
  first strike; `behavior_attack_kind`/`behavior_damage_mult` shape
  the hit (brute 1.5x, pack burst 1.5x, swarm aggregate, charge
  1.2x); `sting` applies venom; pixie strikes set the PLAYER-side
  dazzle store (4s, 50% miss — the enemy's own
  `dazzle_miss_chance` is only for dazzled enemies, never the
  player); held grapplers deal hold DoT only (no double strike);
  `scream`/`breath` kinds are absorbed by their windup (below).
  After any strike, the behavior cooldown gates the next caster
  wail / charger charge.
- Grapple: a grappler adjacent to the player starts a grab
  (0.5s telegraph, then hold). While held, `_try_step()` blocks
  movement and `_player_attack()` runs at 0.5x — main.gd consults
  `behavior_state.grapple_phase` directly (an enemy node cannot
  block movement by itself, and cached fields go stale on a
  struggle/damage break). Struggle: movement keys ARE the struggle
  while held (no new input, no new action, no new subsystem).
- Ambush: bump-attacking a hidden ambusher reveals it.
- Flyers: ground melee reaches only altitude < 0.5
  (`is_melee_reachable()`); hovering bats/harpies/imps/pixies/
  drakes whiff with "Too high to reach!" until they dive to 0.2.
  Flyer visuals are NOT offset by `behavior_altitude` — they
  already hover via registry `y_offset` / procedural hover, and
  adding 1.5m would double-lift them.
- Traps: trappers at 2–7 tiles drop a trap on their own cell as
  they flee (the lure). Traps advance against the player's cell; a
  trigger deals 1.0x ATK and roots the player 2s (`_try_step()`
  blocked while rooted). Traps PERSIST after the trapper dies:
  `_on_enemy_died_signal()` harvests live traps into
  `_floor_traps` (ticked with a throwaway state carrying the
  trapper's ATK — the trap logic stays in behaviors.gd).
  Disarm has no input in Wave 3 (see gaps).
- Specials with a main-side windup on `behavior_state.windup_timer`
  (Behaviors tracks no caster/drake windup): banshee wail
  (1.2s windup, then AoE scream with falloff over radius 3,
  3.0s cooldown) and drake inhale (0.8s windup with the `inhale`
  label, then breath-cone damage, 3.0s cooldown). Firing a
  special suppresses the turn's normal strike.
- Vocals: `_enemy_strike()` calls `play_attack_vocal()` (the
  retaliation path has no tick); enemy.gd dedupes any second
  attack vocal within 500ms, so the auto-vocal in
  `update_behavior()` never doubles it.
- Ranged/bolt intents strike from their band (4–7 tiles) in both
  modes; a cornered ranged foe strikes instead of stepping.
  Kiting is bounded by room geometry (cornered rule), not infinite.

## 3. Dodge/block decision (documented, minimal)

No player dodge/block action exists (only generic Agility
`dodge_chance()` at damage time), and Wave 3 invents none. The
decision: a WINDOWED BONUS to dodging — a flat 25% sidestep roll
(`TELEGRAPH_SIDESTEP_CHANCE`) during telegraph windows, on top of
Agility, applied at strike time, at scream/breath resolution, and
on the grapple telegraph→held transition. It is a passive
tell-reward, never presented as a windowed action, and it never
reuses the generic dodge as if it were windowed. Sidestep resolves
BEFORE sting/dazzle, so a dodged blow applies neither.

## 4. Spawn wiring (dungeon_gen.gd `_pick_type()`)

`spawn_table(depth, weak_only)` — weights are relative:

| Depth | Adds |
|---|---|
| 1 | slime, bat, rat, spider, frog (gentle five) |
| 2 | skeleton, snake, centipede, goblin, boar (first charger) |
| 3 | zombie, wolf, scorpion, wasp, kobold |
| 4 | skeleton_archer, imp, pixie |
| 5 | ghost, golem, orc, harpy (D-band) |
| 6 | troll, minotaur, oni, kappa (heavy D-band) |
| 8 | drake, banshee (Dp caster waits longest) |
| 10+ | D/Dp weights x1.5; weak types never vanish |

Horde (monster floor, `weak_only`): hp<=20, atk<=6, never a
caster/brute/tank/phase/grappler/ranged type — slime, bat, rat,
spider, snake, frog, wasp, centipede, goblin, kobold, depth-gated
(d1: slime/bat/rat only). No apex bosses spawn (Wave 4 owns apex).
Stats are untouched: staged depth-1 values on the locked curves
(hp x depth^1.2, atk x depth^1.05, def flat). Drops untouched:
only the locked mappings (wolf→fur, boar→leather, spider→silk;
light/heavy leather by size; teeth/fangs as reagents).

## 5. Balance soak

Math soak (`tests/wave3_soak_test.gd`, depths 1/10/30/72) +
live playthrough soak (`tests/depth_scale_scene.tscn`, 600 s
timeout). Results below — KNOB CHANGES: NONE. Every [TUNABLE]
knob was re-examined against soak evidence and kept (see the
soak test's "decided-here rules re-examined" section):

- Charge wall stun kept (punish window, no wall damage).
- Dazzle = miss only kept (no movement lock — kinder, and the
  catalog left the effect open).
- Phase = hittable at half damage kept (the catalog never says
  untargetable; it says phase ignores cover for ITS movement).
- Traps persist after death kept (placed objects, not auras).
- Venom refresh-at-cap kept (standard DoT behavior).

Watch items (not knob changes — they ride the locked curves):
- Deep venom scales with enemy ATK: 3-stack scorpion venom is
  50.5 dps at depth 10, 160.0 at depth 30, 401.2 at depth 72.
  Lethality at depth 72 depends on the deep player's HP build
  (not on record here); the cap (not the rate) is what prevents
  unbounded growth.
- Deep troll in-combat regen (0.5% max HP/s): break-even player
  ATK is 5.1 at depth 10, 14.5 at depth 30, 38.6 at depth 72 —
  always under 100, so a deep build out-DPSes it; a weak build
  stalls (intended tank behavior, not a wall: regen pauses 3s
  on any damage).
- Depth 72 is NOT made unreachable or trivial: enemy TTK at
  player ATK 100 runs 25–153 hits across the roster, and Jeff's
  depth-72 Windows demo v5 run stands as the live-data point
  that deep scaling is survivable.

## 6. Tests (verified Oct 29, 2026, Godot 4.7.2 headless)

Scene suites (all run against a fresh/seeded save or with an
in-test backup; the shared `user://savegame.dat` was verified
byte-identical — md5 `5ab3b1260ff31e6114eb3f9ce57cc386` — after
every scene run):

- `wave3_mainloop_scene`: 26/26 PASS (grapple block + 5-struggle
  break, flyer hover-whiff / dive-hit, venom 1.5 exact, ambush
  reveal, pixie dazzle 4.0s, sidestep 0.25/0.0, kobold trap
  place/trigger/2s root/root movement block, frog retreat step,
  trap persistence after death). One fix on the way: the first
  run never started — 7 `:=` inference errors (Variant returns
  from untyped Node calls) meant the scene ran with no script
  and sat until the 300s timeout. Fixed with explicit types;
  the re-run passed in ~2.4s.
- `turn_based_scene` (fresh save): ALL PASS (8 checks — world
  frozen, one turn = one strike, one-cell step).
- `facing_backstab_scene`: ALL PASS (6 checks).
- `depth_scale_scene` (600s timeout, `--soak-virtual=3000
  --soak-scale=16`): ALL PASS — 3000 virtual seconds, 4 deaths
  with respawn, max depth 6, 0 retreat descends, 877/877 minimap
  follow checks, save round-trip PASS. The idle auto-player's
  pace (depth 6 in 3000 virtual s) is its pre-existing
  cautious pace, not a Wave 3 change; it kept descending with
  no stall, so no infinite-kite or unbreakable-grapple
  degenerate showed in the live soak either.

Script suites (all PASS unless noted): behaviors_test,
wave3_fallback_test, wave3_spawn_test, wave3_soak_test,
enemy_integration_test, staged_monsters_test,
model_balance_test, monster_models_test, sfx_hooks_test,
audio_manager_test, voice_map_test, texture_check,
placeholder_models_test (contract updated, see below),
smoke_test (horde list updated, see below).

Two contract updates made honestly during this wave (not
weakenings): the staged-only spawn guard in
placeholder_models_test was replaced by the Wave 3 band
contract (spawn_table(30) names every staged type), and the
smoke horde check now allows the full HORDE_TYPES pool
instead of slime/bat only. Both old expectations were
superseded by this wave's job on purpose.

## 6b. Tests

- NEW `tests/wave3_fallback_test.gd` — alias map, distinct
  profiles, verbatim TYPES/state strings, named mechanics firing
  at behavior and enemy level.
- NEW `tests/wave3_spawn_test.gd` — band gating, full-roster
  reachability at depths 30/72 (20,000 seeded rolls each),
  horde weak-only at depths 1/2/3/10/30, deep lean, no apex.
- NEW `tests/wave3_soak_test.gd` — knob pins, depth-1 TTK bounds
  (worst player TTK <= 15 hits, worst enemy TTK >= 4 hits, worst
  crit+brute single hit < 50 HP), DoT lethality bounds, per-depth
  tables, regen break-evens, kiting/dive bounds, rule re-exams.
- NEW `tests/wave3_mainloop_node.gd` + `tests/wave3_mainloop_scene.tscn`
  — real main.tscn: grapple block + 5-struggle break, flyer
  reach (hover whiff / dive hit), venom DoT (1.5 exact),
  ambush reveal, pixie dazzle store (4.0s), sidestep chance
  helper (0.25 in window / 0 outside), kobold trap place /
  trigger / 2s root / root movement block, frog retreat step,
  trap persistence after trapper death. Backs up the shared
  `user://savegame.dat` in memory and RESTORES it on quit.
- UPDATED `tests/enemy_integration_test.gd` — the four formerly
  fallback types must now resolve to named profiles.
- UPDATED `tests/placeholder_models_test.gd` — the staged-only
  spawn guard is replaced by the Wave 3 band contract (the guard
  was lifted on purpose).
- UPDATED `tests/smoke_test.gd` — horde check uses the full
  `HORDE_TYPES` pool instead of slime/bat only.
- UPDATED `tests/turn_based_node.gd` — striker/stepper selection
  prefers advance-type foes (special-windup, kiting, retreating,
  and telegraph-rooted foes legitimately do something else on
  their turn; picking one would fail the test for correct
  behavior).

## 7. Gaps left for Wave 4 / next push

- Apex bosses (Wave 4 owns apex; nothing apex-shaped was added).
- Trap disarm has no input (the 1.5s channel exists in
  behaviors.gd, but no action drives it — same class of gap the
  struggle once was; least-invasive wire is a future decision,
  not a silent invention here).
- Save/load does not persist live traps or floor traps (behavior
  state is not saved; traps are floor-transient by design here).
- Banshee scream+breath layering is still future work (idle =
  breath pool, attack/death = scream pool, per voice_map.gd).
- Per-model facing still needs an editor eyeball pass (baked PI
  yaw kept; headless import cannot prove facing).
- Player attack multiplier while held (0.5x) is wired in
  `_player_attack()` but only behaviorally covered in the scene
  test (held state + movement block + struggle break); the exact
  0.5x number is pinned at the behaviors level
  (`grapple_player_restrictions()`), not by a numeric scene
  assertion (combat variance + crit make a single-hit numeric
  assertion flaky).
- The swarm intent overwrites the profile damage with the
  aggregate multiplier (solo rat = 1.0x, not the profile's 0.6x);
  left as-is in Wave 3 — a future tuning question, not a bug fix.
- Goblin courage (cowardly alone, brave in numbers) exists as
  `goblin_is_cowardly()` but is not consulted by `update()`'s
  skirmisher arm — out of Wave 3's four-type scope; a future
  pass can wire it the same way the alias fix was wired.
