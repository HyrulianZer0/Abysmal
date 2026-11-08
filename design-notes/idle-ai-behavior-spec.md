# Idle AI Behavior Spec — Abysmal
*Living spec for the idle delve AI (the "AI companion" that plays the dungeon for you).*

## Current behavior (build v0.6.0 + working tree, Sept 27, 2026)

- **Room-by-room sweep:** monsters → chests/loot → unexplored room cells, then moves on.
- **Exit handling:** exit is "mentally marked" when found, but the AI keeps clearing instead of ping-ponging across the map.
- **Critical HP (≤25% max):** retreats toward the depth shop and uses a 50%-of-max-HP patch-up when possible.
- **Movement:** smooth interpolation, eased yaw, subtle walk bob. Idle brain tick interval and stride time scale with depth walk multiplier.
- **Manual mode untouched:** turn-based pipeline intact; monsters act on player action.

## Design note — event reactivity: "fresh loot" moments (James, Oct 7, 2026)

When something happens in the dungeon — a chest unlocks, a ward breaks — the idle AI
companion should **notice and react**, not just silently path. James's example: the AI
says something like "Oh, that's fresh loot!" and goes for it.

This is about giving the AI **personality** and making loot events feel alive, not just
mechanical. The current build's AI just pathfinds without reacting — that silence is
the gap to close.

**Event types to react to (initial):**
- Chest unlocks / chests spotted during sweep
- Ward breaks (seals broken)
- (Future: rare drop moments, boss rooms, level-ups — pair with the loot-research
  "broadcast wins" takeaway: town-hall trophy display + rare-drop announcement moment.)

**Open questions — RESOLVED by James (Oct 7, 2026):**
1. **Interrupt vs. finish → FINISH THE FIGHT FIRST.** When a chest unlocks mid-fight,
   the AI does NOT break off — it finishes combat, then goes to the chest, and
   "double checks" before opening. (This double-check hooks into the coming
   trap/perception system.)
2. **Voice of the barks → SMALL POOL.** "Fresh loot" bark pool, fires after combat on
   the way to the chest (roleplay-action flavor allowed):
   - "Oh, that's fresh loot!"
   - "Oh, finally I can get that chest after defeating those group of monsters."
   - *deep sigh of relief* as he walks over to the chest and opens it.
3. **Delivery → HUD TEXT POPUPS** (phone-first, no voice).

## Design constraints
- Phone-first: reactions must read at a glance; no audio dependency (staged SFX exist
  but barks are text).
- Must not fight the room-by-room brain: reactivity is a *flavor layer* over the
  existing sweep priorities, not a replacement — interrupts do NOT reprioritize
  (per James: finish the fight first).
- Personality should feel like a companion, not a slot machine: sparing, contextual,
  never spammy.

## Coming systems (locked design, not yet implemented)

**Traps & hidden enemies (James, Oct 7, 2026):** tangled vines, spiders, webs —
gated behind a perception check. Design rule: there must be a *very faint* visual
hint of them even before perception is high enough to fully reveal. Subtle, not
invisible. The chest "double check" before opening hooks into this system.

## Movement fix priority (James, Oct 7, 2026)

**The step cycle outranks turning fixes.** James describes current stepping as
"like taking a step forward with a limp, like one leg stiff" — asymmetric stride
timing. Smoothing the step cycle (even stride timing/easing) is the priority;
turning fixes come after.

**Limp diagnosed (Oct 7 verification pass, player.gd move_step) — 3 causes:**
1. Walk-bob asymmetry: camera dips over stride×0.45 but rises over stride×0.55 —
   every step dips 18% faster than it rises. A baked-in limp.
2. Inter-step micro-pauses: brain tick == stride duration, but `busy` clears a frame
   late in the tween callback — chained steps land 1–2 frames late.
3. Bob-kill snap: each step hard-resets camera Y to eye height, causing vertical pops
   on timing drift.
Secondary: D-pad repeat (0.24s) vs step (0.16s) gap; inputs dropped while busy;
back/strafe re-yaw the camera.

## Implementation status (Oct 7)

- **v0.6.1 APK built clean** (31.8 MB, same release signature as v0.6.0 — installs over
  it). Soak tests both pass (30 virt-min @2x, 60 virt-min @4x, zero violations).
- **Chest fight-first: FIXED (overnight Oct 7).** Was: `_auto_step`'s adjacent
  loop checked per direction N/E/S/W — a chest to the north beat a foe to the
  east/south/west, and multi-tick lockpicking let the brain fiddle while an
  adjacent foe hit it free. Now: threat-ordered passes (foes → doors → chests).
- **"Fresh loot" barks: DONE (overnight Oct 7).** 5-line pool (`FRESH_LOOT_BARKS`
  in main.gd), hooked at the `_sweep_step` monster→loot transition, delivered
  via `_spawn_popup` + `add_log`, 60% fire chance, once per room's loot phase —
  never mid-fight.
- **Chest fight-first: FIXED (overnight Oct 7).** `_auto_step`'s adjacent loop
  split into threat-ordered passes (foes → doors → chests); chests never while
  critical-retreating. `_perception_double_check(chd)` no-op hook left at
  `_bump_chest` for the coming traps/vines/spiders/webs system.
- **Enemy facing + backstab: DONE (overnight Oct 7).** Enemies face travel
  direction (not the camera, per James). Striking from behind the enemy's
  facing — or striking a sleeper — deals x1.5 ("Backstab!"). Facing persists
  through save/load.
- **Save versioning: DONE (overnight Oct 7).** Save dict stamped
  `SAVE_VERSION = 2`; older saves migrate forward additively, corrupt/
  unsupported versions rejected.
- **Tutorial: DONE (overnight Oct 7).** Floor-1 fresh-boot paused popup cards
  (4 steps: welcome, idle, manual controls, death-is-progress). Dismissable;
  `tutorial_done` persisted, never shown again.
- **Settings screen: DONE (overnight Oct 7).** Music/SFX sliders wired to
  AudioManager setters; High/Low quality (3D render scale); cheats VERY hidden
  (7 taps on the Settings title reveals the dev speed selector — never
  advertised).
- **Textures/audio: staged, not live.** 30+ flakdeau textures staged, zero loaded
  (flat colors). Kenney SFX bundled but never triggered; Alkakrab 2 GB excluded from
  Android export. Needs James: (1) mobile music-source decision, (2) audio-manager
  autoload, (3) event hooks.
