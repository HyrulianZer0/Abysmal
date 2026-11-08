# Idle Dungeon Roguelike (working title)

A 2.5D **idle dungeon crawler roguelike** starter build for Godot 4.
First-person grid dungeon (Barony-flavored), auto-explore / auto-combat idle
mode, and incremental-style big-number formatting ready for the
equipment / skills / magic / prestige / ascension systems coming in later
phases. **Primary target: Android** (director devs from his phone).

## Run it

Requires Godot 4.x (developed against 4.7.2, installed at
`~/workspace/tools/godot/`).

```bash
~/workspace/tools/godot/godot --path ~/workspace/game/idle-dungeon-roguelike
```

Or open `project.godot` in the Godot editor and press Play.

### Controls

**Idle mode is ON by default** — the crawler delves on its own; you opt OUT
to take manual control. The player's job is gear (equipment UI is the Phase 2
priority).

| Key | Action |
|---|---|
| W / ↑ | Step forward |
| S / ↓ | Step back |
| A / D | Strafe left / right |
| Q / ←, E / → | Turn 90° |
| Space / I | Toggle idle mode (auto-explore + auto-combat) |
| R | Start a new run (after death) |

On touch devices a virtual D-pad appears (tap = one step/turn, hold =
repeat); it dims while idle mode owns movement. HUD buttons are touch-sized
and the log panel moves above the D-pad.

## Android build

Debug APK: `~/workspace/build/idle-dungeon-roguelike-debug.apk`
(package `com.aethelwardsage.idledungeon`, minSdk 24).

- Export preset: `export_presets.cfg` → "Android (Debug)".
- Toolchain: export templates 4.7.2 in
  `~/.local/share/godot/export_templates/4.7.2.stable/`; Android SDK
  (platform-tools, android-35, build-tools 35.0.0) at
  `~/workspace/tools/android-sdk/`; Temurin JDK 17 at
  `~/workspace/tools/java/`; debug keystore at `~/.android/debug.keystore`.
- Rebuild: `godot --headless --path . --export-debug "Android (Debug)"
  ~/workspace/build/idle-dungeon-roguelike-debug.apk`
  (with `JAVA_HOME` set and the SDK's build-tools on `PATH`).
- Install on phone: copy the APK over, open it, allow "install unknown apps"
  for your file manager/browser when prompted. It's signed with a debug key,
  so Android will warn — expected for a dev build.

## What's in the box

- **Procedural dungeons** — rooms + corridors on a 40×40 grid, one floor per
  depth, golden EXIT stairs that generate the next deeper floor.
- **Idle mode** — BFS auto-explorer: hunts the nearest enemy, then the stairs,
  then unexplored tiles. Bump-to-attack combat, all automatic.
- **Combat** — 3 enemy types (Slime, Cave Bat, Skeleton; more unlock with
  depth), HP bars, floating damage numbers, crits, XP/levels, gold.
- **BigNumbers** — `1.23K … 1.00Qi … 1.00e100` formatting autoload; the
  incremental-infinity number feel starts here.
- **Roguelike loop** — permadeath with a run summary (depth, kills, level,
  gold); each new run bumps enemy difficulty slightly (the per-death "hunger"
  ramp caps at +50% so a bad streak can never spiral into an unbeatable game).
- **Death shop** (Brotato-style) — on death, spend hoarded gold on 4 random
  charm offerings (permanent stacking stat boosts, re-rollable) plus the
  canon 14-skill list to unlock/upgrade (12 wired: Attack, Strength, Defense,
  Vitality, Agility, Dungeoneering, Stealth, Perception, Luck, Enchanting,
  Regeneration, Lockpicking; Smithing/Alchemy show as coming soon). Everything
  bought is permanent — death always leaves you stronger.
- **Guild-hall unlock chain** (Phase 2) — a separate meta track from the death
  shop: buy the old run-down tavern with loot-sale gold, then upgrade through
  Guild Hall → Expanded Guild → Adventurers' Guild HQ (gold costs + lifetime
  depth milestones). Stages are visually distinct (stub 3D for now, real art
  later); progress persists across runs and deaths, never wiped.
- **Locks, seals & sleepers** — chests carry room seals (break when their room
  clears) and tumbler padlocks; corridor doors can be closed or locked.
  Lockpicking skill picks locks quietly, or bash them down loud: bashing can
  wake sleeping monsters and (rarely) draw a patrol. Sleepers grant a free
  first hit and tie into Stealth.
- **Floor-clear shop** — after each cleared floor, a shop visit offers items
  and skills before descending; one tap keeps delving, no purchase required.
- **HUD** — HP/XP bars, depth/kills/gold/run, message log, idle toggle.

## Architecture

```
project.godot            input map, autoloads, GL Compatibility renderer
autoload/
  game_state.gd          run + player stats, signals (stats_changed, log_message…)
  big_numbers.gd         K/M/B/T…e308 formatting
scripts/
  main.gd                orchestrator: loop, idle AI, combat resolution, death/restart
  dungeon_gen.gd         rooms+corridors generator (static, unit-tested)
  dungeon_view.gd        MultiMesh 3D builder from the grid
  player.gd              first-person grid movement (tweened steps/turns)
  enemy.gd               enemy entity: stats, HP bar, hit flash
  combat.gd              damage math (static, unit-tested)
  damage_popup.gd        floating combat text
  hud.gd                 code-built UI + death shop (Heirlooms/Items/Skills tabs)
  shop.gd                death-shop catalog: 8 charms, 14 canon skills, pricing
  guild_hall.gd          guild-hall chain: 4 stages, costs, depth reqs, buy rules
  guild_hall_view.gd     stub 3D stage representation (real stages, placeholder art)
  items.gd               loot generation + comparison (static, unit-tested)
scenes/main.tscn         minimal scene; main.gd builds everything
tests/smoke_test.gd      headless unit tests (gen, combat, BigNumbers)
```

## Stubbed for later phases (TODO)

**Phase 2 priority: equipment/inventory UI.** `GameState` carries the
scaffolding: `equipment` dict (`weapon`/`armor`/`trinket` slots holding item
dicts), `equip()` / `unequip()` / `gear_bonus(stat)` helpers, reset on new
run. Next: loot drops, rarity tiers, upgrades, and wiring gear bonuses into
combat stats.

HUD buttons **Skills / Magic / Prestige / Ascension** open placeholder panels.
`GameState` already carries stub fields (`skills`, `spells`,
`prestige_count`, `ascension_count`). Planned: incremental skill levels, mana +
spellbook, prestige resets with permanent multipliers, ascension cosmic resets,
save/load (`BigNumbers.parse` is a stub for that).

**Phase 3 (scaffolding): town / overworld state machine.** `GameMode`
(`scripts/game_mode.gd`) is the seam: `DUNGEON` / `TOWN` / `OVERWORLD` with
explicit legal moves (dungeon→town on run end, town→dungeon on delve,
town↔overworld stub; no direct dungeon↔overworld). `GameState.mode` is the
guarded current state (persisted in saves). Town is the between-runs hub —
placeholder 3D (`scripts/town_view.gd`: boxes + Label3D signs, Delve/Travel
buttons); overworld is a stub panel (`scripts/overworld_view.gd`). Fresh boot
still delves straight into the dungeon; death-screen restart now lands in
town. **Open decision (TODO_JAMES): overworld map size is undecided** — see
`OverworldView.OVERWORLD_MAP_SIZE` (0 = no size chosen, not a design pick).

## Headless verification

```bash
cd ~/workspace/game/idle-dungeon-roguelike
G=~/workspace/tools/godot/godot
$G --headless --path . --import            # build import cache
$G --headless --path . -s tests/smoke_test.gd        # unit tests (exit 0 = pass)
$G --headless --path . tests/turn_based_scene.tscn   # manual-mode turn-based regression (exit 0 = pass)
$G --headless --path . tests/autoplay_scene.tscn     # 3min idle autoplay priorities
$G --headless --path . tests/death_sort_scene.tscn   # death panel + heirloom pick
$G --headless --path . tests/horde_stress_scene.tscn # 12min forced monster floors (perf + survivability)
$G --headless --path . tests/deep_delve_scene.tscn   # 30min endurance: inconsistencies + soft-lock scan
$G --headless --path . tests/brain_blocker_scene.tscn # blocker-in-corridor soft-lock regression
$G --headless --path . -- --smoke          # 30s autoplay: idle explore + combat + death/restart
$G --headless --path . tests/speed_ramp_scene.tscn -- --phase_min=30  # 2h speed ramp x2->x4->x8->x16 (dev cheat)
$G --headless --path . -- --speed=2            # dev-only stress-test cheat: player speed x2 (not a game feature)
$G --headless --path . -- --seed=12345 tests/deep_delve_scene.tscn  # replay an exact beta run
```

## v0.5.0 (unreleased — source only, no APK yet)
- **Locked chests & doors.** Chests spawn with room seals and tumbler padlocks;
  corridor doors can be closed or locked (deterministic tumblers, shared with
  chests). Lockpicking picks locks quietly; bashing is the loud alternative —
  it can wake sleepers (35% alert) and rarely (<10%, currently 8%) draws a
  1–3 monster patrol.
- **Sleeping monsters** (~30% of spawns) — darkened body, floating `z z`;
  Stealth interacts, attacks get a free first hit and wake them.
- **Exit ward** — stairs stay barred until the stairs room is clear; rushing
  the exit still works once the exit room itself is clear.
- **Floor-clear shop** — a shop visit after every cleared floor (items + skills
  tabs); "Keep Delving" resumes with no purchase required.
- **Idle brain** — hunts monsters → bumps doors (open/pick/bash) → opens
  chests → loot → stairs; sealed chests are solid to pathing, and warded
  stairs are too (deep-delve soft-locks fixed: the brain used to bump a sealed
  ward forever, and used to pace through warded stairs at the last hostile
  beyond them). Chests now spawn in rooms only — a sealed chest in a 1-wide
  corridor could wall off the map permanently (its seal could never break).

## v0.4.0 (2026-09-26)
- **Turn-based manual mode.** With idle OFF, the world freezes until the
  player acts: every step, turn, bump-attack, chest bump-open, and potion
  quaff grants each living monster exactly one turn (adjacent foes strike,
  mid-range foes step one cell closer, distant foes stay dormant).
  Timers/cooldowns no longer decay while the player stands still.
- **D-pad fixed.** The touch D-pad emitted `Input.action_press()`/`release()`,
  which only sets action *state* and never dispatches an `InputEvent` — and
  main.gd reads input exclusively via `_unhandled_input`, so every tap
  vanished. The D-pad now emits a `pad_action` signal that main.gd routes
  through the exact same action pipeline as the keyboard, so touch and
  keyboard stay in lock-step (forward/back step, 90° left/right turns).
- No more instant counter-strike on bump-attack in manual mode — the foe
  retaliates on its own monster turn, like everything else.
- HUD potion button now routes through main: free top-up while idle,
  costs a turn in manual mode.
- New regression test `tests/turn_based_scene.tscn`: D-pad step/turn with
  idle OFF, 120-frame freeze check (8 monsters, 0 movement, hp steady),
  exactly one strike per player turn, no strikes without input, mid-range
  foe steps exactly one cell closer.
- Release-signed APK (v0.4.0, versionCode 5).

## v0.2.0 (2026-09-25)
- Smooth camera: yaw now glides (~0.3s ease-out) instead of snapping.
- Loot system: weapons/armor (Rusty/Iron/Steel/Starforged tiers) scattered in rooms,
  auto-equip-if-better else auto-sell; health/mana potions; 2-4 chests per floor.
- Idle brain auto-drinks a health potion below 30% HP; manual drink via HUD (HPxn) or H key.
- Fog-of-war minimap (top-right): radius-4 lit circle, explored=dim, unexplored=black.
- Idle brain priority: monsters -> chests/loot -> stairs LAST.
- Release-signed APK (v0.2.0, versionCode 3). Keystore lives in keystore/ — back it up;
  password.txt (600) is required to sign future builds.

## Status — November 1, 2026

- **Live build: v0.11.0** (Android APK + Windows demo v5, Oct 24).
  Two diagnosed UI bugs parked for the next push (HUD overlap on
  Life Tree open; Life Tree button clipped 16px).
- **Phase 2 complete (Oct 29, build only, unreleased):** 20 of 28
  monsters on real models, spawn + main-loop wiring, 15 apex
  treatments (Cerberus still unbuilt — only on the director's
  re-ask). No APK, no release; next push needs the director's
  green light (pending Nov 1).
- **Decided Nov 1:** house texture pack anchored at 1K realistic
  (1K = high/extreme; 512/256 fallback-only, both player-chosen
  and automatic; 128 joins if the ladder expands); mercy = 10%
  off current HP per trigger until that foe is defeated; trap
  disarm = d20 (1 crit fail, 20 crit success + learn the trap),
  mechanical chest traps added alongside mimics, trapped doors as
  an option; monster placement random, no zone exclusives;
  jalastram-voice-008.mp3 repurposed as zombie/ghoul gasp loop.
- **Accessibility:** target is full Windows Magnifier
  compatibility (Nov 1, from Tristan himself). A Tristan playtest
  package (v0.11.0 Windows demo) was prepared Nov 1 — the build
  predates the accessibility pass, so his feedback shapes it.
- **Credits:** see `design-notes/credits-and-attribution.md`
  (Settings panel, source-verifiable). AI assistance: Muse by Meta
  (text only, no logo).

## Forever — Abysmal lives on

If this game ever goes down — taken down, lost, abandoned, or
silenced — anyone, human or AI, has my blessing to bring it back:
new site, new server, new location. Mirror it, re-host it, keep it
alive. You can't kill a dream just because you don't like someone
else's story. Abysmal belongs to everyone who plays it, forever.
