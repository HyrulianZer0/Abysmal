# Offline Earnings — "While You Were Away..." — Design Reference for Abysmal
*Researched Oct 8, 2026. For a 2.5D first-person idle dungeon crawler roguelike (Godot 4.7, Android-first): idle auto-delving, death → death shop (14 skills incl. merged Luck, +3% gold/level, 8 charms), per-death monster ramp +2%/run capped +50%, autosave every 30s + on app background, live-run restore.*

James's standing rules for this system: **never paywall idle mechanics** ("i dont like companies who pay wall for more idle time" — be generous); **use CLOCK time (wall time), not background timers** (Android kills background processes — the game saves on backgrounding); and the design principle: **"idle gold income must keep pace with skill costs at any depth, even when the player is away."**

## 1. The Core Loop (what's actually happening)

The idle brain keeps delving when the player is watching. Offline earnings answer one question honestly: **what did the hero do while the app was closed?** The genre-standard answer (AFK Arena, Melvor Idle, Idle Champions, NMS's frigate expeditions) is a *coarse simulation*: don't re-run combat tick-by-tick; compute a plausible, verifiable income from measured recent performance. James's wallet-clock rule makes this clean — Android will kill the process, so there is no "keep simulating in background" option. The entire system is: **timestamp at save → timestamp at load → compute → report.**

Two numbers must be stored in the save at every autosave/background:
- `last_seen_unix` — wall-clock time of the last save (Godot: `Time.get_unix_time_from_system()`)
- `delve_snapshot` — a compact performance profile of the run being simulated (depth, measured kills/min, measured gold/kill, active gold multipliers, hero power vs. floor difficulty at snapshot)

The save already restores live runs; this snapshot rides on the same mechanism.

## 2. The Formula

**Proposal: simulated-floor income, computed from the player's own measured performance.**

```
offline_gold = min(time_away, CAP) × kills_per_min × gold_per_kill × gold_multiplier
             + min(time_away, CAP) × chests_per_min × avg_chest_gold × gold_multiplier
```

Where:
- **`time_away`** = load_time − last_seen_unix, in minutes, clamped (Section 4) and capped (Section 3).
- **`kills_per_min`** = rolling median of the player's measured kills/min over the last ~30 minutes of live play (not a static table — it must come from *their* run, because the per-death +2% ramp and their build change real kill speed). Recompute live; store the current value in `delve_snapshot` at save time. Fallback if no data (fresh install): a conservative constant per starting floor (e.g., 4 kills/min at depth 1).
- **`gold_per_kill`** = rolling median gold per kill from the same window (includes chest gold rolled into the per-minute rate separately — keep kills and chests as two channels so Luck's chest interaction, if any, stays legible).
- **`gold_multiplier`** = 1 + (Luck level × 0.03) + charm bonuses + any guild/town gold structures. **Luck stays the player's friend here** — it visibly inflates the offline report line ("Luck bonus: +36%").
- **`chests_per_min`** and **`avg_chest_gold`** = same rolling-window measurement.

### Depth during absence: HOLD, don't descend

**Recommendation: the delve holds its depth while the player is away. No descent, no boss fights, no deeper floors.**

Justification, in order:
1. **Honesty.** A coarse "you descended 14 floors" claim is unverifiable theater. A held floor says: the hero dug in, cleared the floor on loop, and banked the income. The return screen can show its work (see the idle-promise math in Section 6) because the floor never changed.
2. **No descent-gated reward exploits.** Descent triggers prestige tokens (the 10→11 Abyssal Token in the current design). Letting offline simulation descend would hand out run-end rewards for zero play — a real exploit surface and a design lie.
3. **It matches the fantasy.** The standing fiction: while you're away, the hero isn't pushing into the unknown — they're farming familiar ground. Descent is *your* decision when you return. That's a clean narrative beat and it makes the return moment better ("the hero held floor 8 for 7 hours — descend now?").

One deliberate consequence: offline income is *floor-limited*, which means a player who pushes deeper before closing the app earns more overnight. That's a good incentive — it rewards active play without punishing idle players.

### Worked numerical example

Hero at depth 8. Last 30 min of live play measured: **6 kills/min**, **14 gold/kill average**, **1 chest per 12 min** (~0.083/min) averaging **120 gold**, Luck level 12 (**+36%**), no charm gold bonus. Player sleeps **8h 20m** → time_away = 500 min, under the 12h cap.

```
kill income   = 500 × 6 × 14 × 1.36        = 57,120 gold
chest income  = 500 × 0.0833 × 120 × 1.36  =  6,800 gold
                                         ──────────────
offline total                            ≈ 63,920 gold
```

Return screen shows the full breakdown (Section 5 of the loot report's "publish what Luck modifies" rule applies here too): base vs. Luck bonus as separate lines. If the next Luck level costs 60k, one night ≈ one Luck level — that's the idle promise made visible.

## 3. The Cap

**Recommendation: 12 hours.** (Over 8h.)

Reasoning:
- **Generosity is the brand.** James leans generous and explicitly rejects idle-paywalling. A 12h cap covers a full night's sleep (7–9h) plus a work shift, so the two most common real-world absence patterns both land under the cap and feel fully rewarded. An 8h cap would clip a 9-hour sleep — the single most common case — and that one clipped hour would feel like a punishment for sleeping.
- **Exploit surface is already bounded.** The cap is not the anti-exploit mechanism (clamping is — Section 4). The cap just bounds the *honest* payout. At 12h, the maximum honest payout is ~1.5 nights of the worked example above — meaningful but not economy-breaking, because skill costs scale exponentially with depth and the floor is held (no descent rewards).
- **The honest caveat.** A 12h cap means a player who doesn't open the game for 3 days gets 12h of income, not 72h. Frame it in fiction, not as a penalty: the hero can only carry so much loot before heading back to the guild ("pack's full"). Unclaimed-beyond-cap income is simply *not earned* — never show it as "lost" (that reads as punishment); the report only ever shows what was earned.
- **No cap extensions for sale, ever.** This is where the paywall rule bites hardest. Idle games love selling "+2h offline cap" — that is exactly the "pay wall for more idle time" James named. The cap is 12h for everyone, permanently. Say so in the UI copy.

## 4. Anti-Exploit: Clock Handling

Wall-clock time is player-mutable (Android settings, timezone travel, DST). Handle it without punishing honest players.

**Store in save:** `last_seen_unix` (int). **On load:** compute `delta = now_unix − last_seen_unix`.

| Case | Handling |
|---|---|
| `delta` between 60s and 12h | Normal: simulate, show report. |
| `delta` < 60s | Silent: credit income without the report screen (Section 5). |
| `delta` ≤ 0 (clock moved backwards) | **Clamp to zero, don't punish.** Treat as a clock fix / timezone change: award nothing for the gap, load normally, write the new `last_seen_unix`. No ban, no warning, no save wipe. Log it locally for debugging only. |
| `delta` > 12h (forward jump — could be legit travel or tampering) | **Clamp to 12h cap regardless of cause.** A tamperer gains at most the honest 12h maximum; an honest traveler loses nothing they'd have gotten anyway. Same code path, no accusation UI, ever. |
| Absurd values (year 2030, negative epoch) | Same as forward jump: clamp to cap. Never crash on a bad timestamp; never trust it. |

**Deliberate non-punishment principle:** there is no "cheater" state in this design. The worst case of tampering is capped at exactly what an honest 12-hour sleep earns. Anything harsher (save wipes, shaming) risks hitting a player whose phone clock was just wrong — and James's audience includes people on budget Androids with flaky clocks. **Cap the gain, never punish the player.**

Honest caveat: a determined player *can* still time-travel for a free 12h every few seconds by toggling the clock. Mitigations worth noting but **not** worth building v1: cross-check against a monotonic counter persisted per session is impossible across process death on Android; server time requires a backend Abysmal doesn't have. The 12h-clamp plus held-depth (no descent rewards) makes each time-travel worth at most one honest night's farm — a grind nobody sustains, and it costs them nothing to "earn" legitimately by sleeping. Accept the residual; revisit only if analytics ever show it matters.

## 5. Edge Cases

**Death during absence.** **Recommendation: no death while away. The delve is "safe-ish."**

Reasoning: an idle game that kills your run while the app is closed is a betrayal — the player returns to *less* than they left with, through no decision of their own. The fiction: the hero fights cautiously on a held floor, retreats from anything too strong, banks the income. Concretely: the simulation assumes the hero's power ≥ floor difficulty (it was, when they left — they were farming it). No death, no run loss, no death-shop trigger from offline play. If the player left mid-boss-fight… the snapshot records "in combat" state and the offline sim still holds — the hero disengages. One honest line in the report covers it: *"The hero fought safe and lived to tell it."*

**App killed vs. backgrounded.** Same handling. The game autosaves every 30s and on backgrounding, so `last_seen_unix` is at most ~30s stale after a kill — a negligible sim gap, and the <60s silent-credit rule (below) absorbs it. If the OS kills the app *without* the background save firing (rare), the fallback is the last 30s autosave. Document this; don't over-engineer it.

**Absence shorter than a minute.** Credit silently, no report screen. Popping a "While you were away… (47 seconds!)" modal every time the player checks a notification would train them to hate the system. Threshold: 60s. The gold still lands — generosity includes not making a ceremony of small change.

**First launch / no snapshot.** No `delve_snapshot` yet → no offline income, no report. Don't invent performance data. (A fresh install has no "away" to return from.)

**Offline across a version update.** Snapshot schema is versioned with the save system (save versioning + migration is already approved design). If the snapshot can't be migrated, treat as first-launch: no income, no crash.

## 6. The Return Screen — "While You Were Away…"

This is the emotional core of the system. Design it as a **reward moment**, not an accounting page.

**Contents (in order):**
1. **Headline gold number**, large, counting up on entry (juice matters — a ticking counter sells the fantasy that the hero was *working*).
2. **Breakdown lines** — kills (≈3,000 in the worked example), chests opened, gold from kills, gold from chests, **Luck bonus as its own glowing line** ("Luck 12: +36% — +16,920g"), deepest depth held, any level-ups earned (see below).
3. **Fresh-loot bark.** If the simulation's chest channel produced anything notable (rare+ per the loot-report rarity work), the hero gets a voice/bark line on return — reuse the fresh-loot bark voice from live play. One bark max; it's a cameo, not a concert.
4. **The prompt:** "The hero held Depth 8. Descend?" — one tap returns to the live delve exactly where it was. This is the handoff from idle back to active and it should feel like resuming, not restarting.

**Level-ups while away:** propose **banked, not auto-spent**. Offline gold goes straight to the purse (spendable immediately — never a "claim" button that could later be monetized; the gold is just *there*). Skill levels purchased with it are the player's choice on return. Rationale: auto-spending the player's build is a worse sin than making them tap twice, and banked gold lets the return screen's big number *be* the reward.

**What it must never do:** show "you lost X by being away too long" (see cap fiction — "pack's full" at most, and even that only if asked), require a tap to *receive* the gold (that's a dark-pattern-adjacent claim wall), or play more than one modal in a chain (report → game, done).

## 7. Interaction with the Idle Promise

The design principle: **"idle gold income must keep pace with skill costs at any depth, even when the player is away."** Here's how to make that verifiable instead of aspirational.

**The check the player should be able to do (and the game should show):** on the return screen, under the breakdown, one line:

> *"One night at Depth 8 ≈ 64k gold ≈ 1.1× your next skill cost."*

That ratio — **offline-night income ÷ next-skill-level cost at current depth** — is the promise, quantified. Target band: **0.8×–1.5×** per 8h night. Below 0.8×, idle income is falling behind skill costs and the promise is broken; above 1.5×, nights are outpacing active play and there's no reason to play. Tune via the two honest knobs: `kills_per_min` is player-measured (can't fake it), so the real tuning knob is **gold_per_kill growth per depth vs. skill-cost growth per depth** — keep their exponents matched and the ratio holds at every depth automatically.

**Why the held-depth rule protects the promise:** because income is measured from *the player's own recent performance at the floor they're on*, the ratio self-corrects. A struggling player on a hard floor measures fewer kills/min → less offline income → but also faces cheaper skill costs relative to their depth (they haven't pushed). A strong player farming fast gets more. The system inherits the live game's balance instead of needing its own.

**The per-death +2% ramp interaction:** monster ramp raises difficulty, which *lowers* measured kills/min over time — the rolling 30-min window means offline income decays gracefully as the ramp bites, exactly like live income does. No special-casing needed. (This is also why the window must be rolling and recent, not lifetime average — a lifetime average would overpay late-ramp players.)

**Honest caveat:** the ratio line is a promise the balance team (James + Milo) has to keep on every tuning pass. Recommend a debug overlay showing the ratio live during playtests — if a balance change moves gold_per_kill or skill costs, the ratio moves, and the nightly playtest catches it.

## Design takeaways

1. **Wall clock in, capped math out.** Timestamp at save, timestamp at load, clamp everything. No background timers, no server, no trust in the clock — the 12h cap plus held-depth makes tampering worthless and honest play whole.
2. **Simulate from measurement, not tables.** kills/min and gold/kill come from the player's own last 30 minutes of live play. This is the single decision that keeps offline income honest across the per-death ramp, build changes, and depth progression — the formula can't drift from reality because it *is* recent reality.
3. **Hold depth; descent is the player's decision.** No offline descent, no offline boss kills, no offline prestige tokens. It kills the exploit surface, keeps the math verifiable, and makes the return prompt ("Descend?") a real moment.
4. **No death while away — ever.** An idle game must never return the player to less than they left with. Safe-ish delving is a trust contract.
5. **Never punish the clock.** Backward jumps → zero, not penalties. Forward jumps → the same 12h cap as everyone. There is no cheater state, no accusation UI.
6. **The return screen is theater with receipts.** Counting gold, Luck bonus as its own glowing line, one bark cameo, the depth-held prompt — and the promise ratio line ("one night ≈ 1.1× your next skill cost") so the idle promise is checkable, not vibes.
7. **No claim walls, no cap extensions for sale.** Gold lands in the purse automatically. The 12h cap is the same for everyone, permanently — this is where the never-paywall-idle rule is load-bearing.

## Open questions for James

1. **Cap: 12h confirmed?** Recommended above with the sleep-plus-shift reasoning — but it's your generosity call. 8h if you'd rather keep nights tighter to active play.
2. **"Pack's full" fiction for the cap** — when someone's away 3 days, do you want any acknowledgment of the cap at all (a small "the hero's pack can only hold 12 hours' loot" line), or total silence (report just shows 12h of earnings, no mention)? Silence is safer; fiction is warmer.
3. **Level-ups: banked gold (recommended) vs. auto-spend?** Banked keeps build control with you; auto-spend would make the return number even bigger. Your call.
4. **Should offline play feed the death shop at all?** Current proposal: no — offline gold is live-run gold, spendable on live-run things. Alternative: a small tithe (e.g., 5% of offline gold) converts to death-shop currency, so nights also feed the meta-progression. It'd be generous and on-brand, but it adds a second economy line to balance.
5. **Bark voice on return** — one cameo line max in the proposal. Want the hero to comment on long absences ("Three days?! I held the floor, but my feet hurt.") or keep it to loot only?
6. **The promise-ratio line** ("one night ≈ 1.1× your next skill cost") — show it on every return screen, or keep it as a debug/playtest overlay only? Showing it makes the promise public and holds future balance patches accountable — which is the point, but it's your UI.
7. **Guild dispatch overlap** (from the loot report's NMS takeaway): if guild dispatch missions later run on real-time timers, should offline earnings and dispatch returns merge into one "while you were away" screen, or stay separate moments? Worth deciding before dispatch is designed, so the return screen has room to grow.
