# Prestige system — Phase 4 design + groundwork (2026-10-07)

James's design: clear floors 1–10 → earn a prestige token. Track furthest
depth per prestige cycle; beating last cycle's depth feeds the ascension.
Ascending grants a greater permanent upgrade. Standing rule: death costs
the run, never future power — prestige is purely additive.

## What's implemented

**New autoload: `Prestige`** (`autoload/prestige.gd`) — owns tokens, cycle
records, ascension, and the perk registry. Persisted in the save file under
the `"prestige"` key (additive — old saves load with clean defaults).

**Token: "Abyssal Token"** — awarded when you descend the stairs from depth
10 to depth 11 (i.e. floor 10 cleared). Repeatable: every full 1–10 clear
earns another. The game's only "floor cleared" event is taking the stairs
down, so this is the natural trigger.

**Cycle tracking** — `cycle_best_depth` = furthest depth reached since the
last ascension. Survives deaths and run restarts (a cycle ends ONLY on
ascension). `last_cycle_best_depth` remembers the previous cycle's record.

**Ascension** — costs **3 tokens** (tuning, see below). Grants **+1 stack of
every unlocked perk**, plus **+1 bonus stack** when this cycle's best depth
beat last cycle's best. Then the cycle rolls: last ← current best, current
best resets to 1. **Nothing else is touched** — gold, skills, charms,
heirlooms, guild progress all carry on. Purely additive.

**First perk: Gilded Soul** — +10% gold from all sources per stack,
multiplicative with the existing gold bonuses (2 stacks = ×1.21).
The registry (`Prestige.PERKS`) is ready for more: each entry declares
id / name / description / effect kind / per-stack value / cap / unlocked.

**Tests** — `tests/prestige_node.gd` (+ scene): 41 checks covering the token
trigger (10→11 yes, 9→10 and 11→12 no, repeatable), cycle tracking across
deaths, ascend success/failure, record bonus, the gold upgrade math,
save/load round-trip, and the additive-only guarantee (death and ascension
never reduce any meta field). Run:
`godot --headless --path . tests/prestige_scene.tscn`

## Decisions for James to weigh in on

1. **Token trigger**: I chose "descending 10→11" (floor 10 cleared).
   Alternative: award on *entering* depth 10. Say the word and it's one line.
2. **Token name**: "Abyssal Token" fits Abysmal — rename freely.
3. **Ascension cost = 3 tokens**: ~three 1–10 clears per ascension. Too
   grindy? Too fast? Your call.
4. **Gilded Soul +10%/stack**: modest by design. Candidates for the next
   perks: +max HP, +XP, +damage, +potion power — pick what sounds fun.
5. **Record bonus**: currently the *first* ascension always gets the bonus
   (no previous record to beat). Keep as a welcome gift, or require a real
   prior record?
6. **Ascend UI**: the logic is done (`Prestige.can_ascend()` /
   `Prestige.ascend()`), but there's no button yet. Natural home: a panel
   on the death screen next to the death shop. Next step when you say go.
7. **One token per clear, no per-cycle cap**: speed-runners can bank many
   tokens in one cycle. Fine, or cap it?

## Notes for other builders

- `GameState.next_depth()` calls `Prestige.notify_descend()` — the single
  funnel for descends, so the hook can't be bypassed.
- `GameState.gold_mult()` folds in `Prestige.gold_mult_bonus()` (one line).
- The per-death monster ramp (+5%/run, +50% cap) was read, never touched.
- The guild-hall track (`max_depth`, lifetime) is separate and untouched;
  prestige cycle records complement it, they don't overlap.
- Old `prestige_count`/`ascension_count` stubs removed from GameState —
  authority is the Prestige autoload now.
