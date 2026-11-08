# Design Decisions — 2026-10-10
*Locked by James Greenlee ("Aethelwarden Solas"), Oct 10, 2026, in main-chat review with Milo. This is the decision record. Supersession notes are explicit wherever an earlier decision is overridden. All names/lore below are original — IP hygiene per standing rules.*

## 1. Offline Earnings: FULL speed, NO cap

**The decision.** Offline earnings run at **full speed** (no reduction) with **no cap** — a player away for a day gets a day's earnings, a player away for a week gets a week's. Infinite growth is the reward.

**SUPERSEDED — 2026-10-09 design (12h base cap +1h per depth completed, no ceiling).** The Oct 9 formula (base 12 hours + 1 hour per depth completed, deliberately no absolute ceiling) is superseded: there is no base, no per-depth bonus, no cap at all. Any implementation scaffolding referencing a cap value is obsolete.

**SUPERSEDED — `design-notes/offline-earnings-2026-10.md`, §3 ("The Cap") and all cap-dependent reasoning.** The 12-hour recommendation, the "pack's full" fiction, the tamper-clamp math that relied on the cap (§3's honest caveats, §4's forward-jump row), and the "12h for everyone, permanently" UI copy are all superseded. That paper's open question #1 ("Cap: 12h confirmed?") is answered: no cap.

**KEPT from that paper (all still authoritative):**
- **The measurement-based formula.** Simulated from the player's *own measured* kills/min × gold/kill (rolling ~30-min window, fallback constant for fresh installs), Luck multipliers visible as their own line. The formula is unchanged; only the time factor loses its ceiling.
- **The "While You Were Away…" return screen.** Headline gold counter, full breakdown, Luck line, one fresh-loot bark max, the "Descend?" prompt, banked-not-auto-spent gold, no claim walls, no chained modals.
- **Anti-exploit clock handling — minus one row.** The non-punishment principle stands: no "cheater" state, no accusation UI, never punish a bad clock. Backward jumps clamp to zero (no income, no penalty); absurd values (year 2030, negative epoch) are never trusted, never crash. The forward-jump >12h row is superseded along with the cap — see open question #1 below, because uncapped time and clock tampering now share a surface and the design needs an explicit answer for it.
- **No death while away, ever.** The delve is "safe-ish." Offline play never costs the run.

**Rationale (James's call).** The idle promise — "idle gold income must keep pace with skill costs at any depth" — is now stated without hedging: if you're away, you earn what you earned. The cap was a generosity ceiling; James removed it.

**Honest caveat.** With no cap, the 60-second silent-credit threshold and the `last_seen_unix` snapshot math stay exactly as written; the worked numerical example in the old paper is still correct math, just no longer bounded.

---

## 2. Guild Dispatch: Fail Forward, Never Permadeath

**The decision.** Dispatch units **CAN fail** missions — failure is a real outcome of bad composition or under-leveling — but a failed party **ALWAYS returns with something**: partial payout, salvage, scrap, experience, *something*. And there is **no permadeath for dispatched adventurers, ever.**

**Refinement of `design-notes/guild-management-2026-10.md`.** That paper's failure spectrum (clean success → success with injuries → partial success → failure: no fee, partial wages paid, injuries likely) is kept — but its failure state is refined: "no fee" becomes "no fee, but the party still brings something home." The roster-safety rule (§2.3: injuries cost time and gold, never the adventurer) is now absolute, confirmed by James. This also closes out that paper's open question #9: roster safety is absolute; no hardcore guild mode.

**Rationale.** Fear of losing a leveled roster member would make players afraid to dispatch at all, which kills the whole system. Failure should sting (injuries, thin margins, burned wages) but never delete progress. The game's thesis — the run ends, the guild endures — applies to the roster too.

---

## 3. The Undercrucible — Converter Reframe

**The decision.** The Converter's name is locked: **the Undercrucible** (chosen from the candidates in `converter-design-2026-10.md` §12 on Oct 9). Its role is reframed: the machine converts **MATERIALS to strengthen EXISTING items.**

**Reframe of `design-notes/converter-design-2026-10.md` (no rewrite — see its addendum).** The three verbs survive with new framing:
- **Extract** = pull material essence from junk (the machine digests bad drops into usable essence).
- **Reforge / Augment** = apply materials to strengthen *existing* gear — never to make new gear.

**KEPT from that paper.** All generosity tuning: no zero-value items, Extract always max roll, visible published pity, failure costs materials/essence never items (no bricking ever), stated house edges, augments removable with refund, nothing paywalled, and the standing bar: **the worst run still moves five needles.**

---

## 4. Blacksmith vs. Undercrucible: The Split

**The decision.** The craft/enhance economy is split into two clean halves:

| System | Input | Output | Question it answers |
|---|---|---|---|
| **Blacksmith** | **Gold** | Creates **NEW gear** — fills empty slots, targets specific types/profiles | "I know exactly what I want — make it." |
| **Undercrucible** | **Materials** | Strengthens **EXISTING gear** — extracts essence from junk, reforges parts, augments stats | "Make what I have better." |

**Core loop: craft base → enhance.** The player smiths a deterministic base (blacksmith rules from `guild-management-2026-10.md` §3 — Epic cap, depth cap, tight rolls all stand), then feeds it to the Undercrucible to push it further. The two systems eat different things and meet in the middle: crafted base, lottery soul.

**Why the split matters.** It kills the classic design disease of two systems competing for the same input. Gold goes to the smith; materials go to the machine; drops feed both (junk to the machine as essence, wishlist items to the player). One economy, two mouths, no cannibalization. The existing coexistence rules (smith caps below the lottery ceiling; machine never bricks) are unchanged — the split just names which machine does what.

---

## 5. Death Before the Guild Hall: Forgiving by Default

**The decision.** Death before the guild hall/tavern is established is **forgiving** — not Dark Souls. The early game is lonely (void death screen per the NPC paper's §4 design), but never punishing in-fiction.

**Hardcore mode — opt-in only.** A **hardcore toggle** lives in Settings, **very hidden, next to the cheat easter egg**. It is:
- **Reversible** — turning it off returns the player to forgiving rules immediately.
- **Semantically (build coordinator's judgment call, recorded as such):** death forfeits ALL carried gold, and the per-death monster ramp becomes **+5%/run** instead of the standard +2%/run.

The hardcore semantics are explicitly the build coordinator's judgment call — James has approved the *slot* (a hidden, reversible, harder-punishment option) and the *placement* (Settings, next to the cheat easter egg), not the exact numbers.

**Rationale.** James's game gets harder as you die (the ramp) but gets *warmer* in-fiction to compensate — that's the emotional signature. Forgiving by default honors it; hardcore exists for players who want the stakes, and it's hidden so it never becomes the default experience.

---

## 6. Prestige Revision: Platinum, Town Reset, Soul Bonuses

**The decision.** Prestige now works like this:
1. A prestige run earns **PLATINUM** — a new prestige currency.
2. Platinum is **spent on town upgrades BEFORE the reset** — the pre-reset spending window is the moment.
3. **The town resets on prestige.** Town progress is not permanent across prestige.
4. **Soul bonuses apply to the next run.** What's soul-level (the new Soul Tree, perk stacks, extracted powers, the ledger's records) carries forward — the body/town is rented, the soul is owned.

**REVISES — `design-notes/prestige-design-2026-10.md`'s standing rule.** That paper's header states: *"Standing rule: death costs the run, never future power — prestige is purely additive."* And its implementation section guarantees: *"Nothing else is touched — gold, skills, charms, heirlooms, guild progress all carry on. Purely additive."* This is revised: **the town now resets on prestige.** The "purely additive, nothing ever resets" rule no longer holds.

**The tension, stated explicitly.** The old rule's spirit — *death costs the run, never future power* — is preserved at the soul layer: the Soul Tree never resets, extracted powers persist, ascension/perk stacks persist. What changed is the *boundary* of "future power": the town is now a per-prestige-cycle construction project, not a permanent accumulation. The game asks the player to rebuild their town each prestige cycle — with soul-level bonuses making every rebuild faster and grander. **James's Oct 10 decision is authoritative over the old purely-additive rule.**

**What this implies (recorded, not yet designed).** The prestige flow needs a defined sequence: earn platinum → spend platinum on town upgrades (the pre-reset window) → reset fires (town clears) → next run opens with soul bonuses active. The platinum→town-upgrade spend must be legible as *the point* of the run, not a tax — and the Soul Tree (below) must be clearly framed as the permanent prize so the town reset reads as "rebuild, stronger" rather than "lose everything." See open questions.

---

## 7. The NEW Soul Tree

**The decision.** A brand-new persistent system: the **Soul Tree** — an infinite branching skill tree **tied to the player, never resets, only grows.**

- **"Break null"** = no stat caps, ever. Crit can exceed 100%, regen can exceed any bound, attack speed can pass any ceiling — the tree's job is to make infinity *actually* infinite, which is what the math section below demands.
- **Prestige multiplies tree power ×2.** Each prestige run compounds: M = 2^p.
- **Ascension multiplies ×2 again.** M = 2^(p+a), where p = prestiges, a = ascensions. Compounding, multiplicative — exponential on purpose.
- **Cost scaling ~10^N platinum per loop.** Super-exponential costs chase exponential power. Each loop is expected to take ~5× longer and yield ~2× power — the prestige rhythm in one line.

**Why it's parked** (see §11). The tree needs platinum (prestige currency) and the prestige-reset sequence to exist first. Design the economy, then the tree.

---

## 8. Elements: BOTH Damage Types AND Interactions

**The decision.** Elements are **BOTH**:
- **Damage types with resistances** (fire vs. fire-resistant, etc. — the tactical layer: bring the right damage), **AND**
- **Elemental interactions** (fire melts ice, water douses fire, etc. — the systemic layer: elements combine and counter each other in the world).

Not one or the other. The damage-type side gives build decisions; the interaction side gives emergent moments. This is the classic paired design (the research lineage: damage tables for reliability, interaction tables for delight) and James locked both.

**Parked** (see §11) — needs the combat/parts model and enemy-resistance data to exist before the interaction table is worth writing.

---

## 9. NPC Breadcrumb Revision: 2/4/6/8/10

**The decision.** The breadcrumb trail in `design-notes/npc-story-beats-2026-10.md` is revised from four NPCs at depths 2/4/6/8 to **five NPCs at depths 2/4/6/8/10**:

| Depth | NPC | Trade | Buff | Soul-flavor |
|---|---|---|---|---|
| 2 | Marla Bramble | Farmer | **Well Fed** (+max HP) | The soul remembers being fed |
| 4 | **Harlan Slate** (NEW) | **Miner** | **Well Stocked** (**material yield**) | The soul remembers the veins |
| 6 | Tovan Ashe | Woodcutter | **Well Rested** (regen) | The soul learned how to rest |
| 8 | Sarella Vex | Blacksmith | **Well Armed** (attack) | The soul remembers how to hit |
| 10 | Pello Quin | Trader | **Inspired** (luck) **+ tavern deed** | The soul learned the habit of luck — and the town gets its home |

**What changed.** Tovan (woodcutter) moves 4→6, Sarella (blacksmith) moves 6→8, Pello (trader) moves 8→10. The new depth-4 slot is Harlan Slate, the miner, granting **Well Stocked**: a material-yield buff — the player digs more from the deep. His backstory, dialogue, and mechanics are written in the NPC paper's addendum ("Addendum 2026-10-10 — breadcrumb revision").

**The tavern deed at depth 10.** Meeting Pello at depth 10 grants the **tavern deed** — player ownership of the tavern. Mechanically: the tavern becomes the player's **home base**; **death returns here once the guild hall is established** (the death-in-town beat from the NPC paper §4 fires on the first death after the deed). The deed is the trail's payoff: five meetings, five buffs, one home.

**KEPT.** All buffs still survive death (flagged on the soul, per "the body is rented, the soul is owned"). Re-meeting rules, memory-echo behavior after the tavern, and the depth-pocket design language are unchanged — they just have a new resident at depth 4.

**Noted for the record:** NPCs still aren't embodied in-game — this is data-level groundwork only (buff schedule, story beats, dialogue text). Embodiment (pockets, portraits, barks) is a later build phase.

---

## 10. Math Notes

**Recorded as James's locked framing:**
- **Rewards scale exponentially: 2^N.** Power, gold, token income — exponential by design.
- **Costs scale super-exponentially: 10^N.** Skill costs, Soul Tree loops, platinum sinks — an order of magnitude steeper than rewards.
- **Break-null is what makes infinity actually infinite.** Without uncapped stats (Soul Tree §7), exponential growth eventually hits a ceiling and the game ends in arithmetic; with break-null, 2^N keeps meaning something forever. The tree and the math are one decision, not two.

**Honest caveat.** 10^N costs against 2^N rewards is a deliberately brutal gap — it's what makes each loop ~5× longer than the last (Soul Tree §7). The generosity tuning elsewhere (Undercrucible §3, offline earnings §1) is the counterweight: the *numbers* are merciless, the *systems* are kind. If playtesting ever shows the gap reads as punishment rather than aspiration, the exponents move — not the philosophy.

---

## 11. Parked with Intent

Systems James has approved *in concept* but which are parked until their prerequisite systems exist. Each entry: what it is, why it's parked, what unblocks it.

### 11a. Soul Tree
**What.** The persistent infinite branching skill tree tied to the player (§7): break-null stats, prestige ×2, ascension ×2 compounding, ~10^N platinum costs per loop.
**Why parked.** It spends platinum and multiplies across prestige/ascension — neither of which exists in code yet. A tree with no economy underneath is a UI mockup, not a system.
**Unblocks.** The prestige revision (§6) implemented and playable: platinum earned, pre-reset spend window working, town reset firing cleanly. Once a player can prestige and hold platinum, the tree has something to be.

### 11b. Guild dispatch missions
**What.** The NMS-frigate-style dispatch layer from `guild-management-2026-10.md` Part 2: 4-class adventurer roster, composition puzzle, real-time timers, injuries, trickle income — now with the fail-forward/no-permadeath rule (§2).
**Why parked.** Dispatches need the guild hall to exist (roster, board, merchant, stages) and real-time timer infrastructure (offline-progress timestamp math) shared with the blacksmith queues.
**Unblocks.** Guild hall stage 1 (tavern) playable with a roster and a quest board. The board is the dispatch layer's front door — no board, no dispatches.

### 11c. Undercrucible machine
**What.** The death-shop machine (§3): Extract essence from junk, Reforge/Augment existing gear with materials, one generosity-tuned economy.
**Why parked.** It's a death-shop installation — and while the death shop exists in code, the machine needs the *item economy* to be worth digesting: drops with parts/rarity, the forge-house model, and a clear materials inventory. A refinery with nothing to refine is a dead screen.
**Unblocks.** The loot pipeline (parts model, rarity bands, material drops) generating enough junk-per-run that "the worst run moves five needles" is *testable* against real volumes — the converter paper's §10 caveat about Shard-ladder-vs-loot-volume applies to essence too.

### 11d. Blacksmith crafting UI
**What.** "Craft any weapon/armor for gold" (§4): type + forge house + profile + rarity band selection, timed queues, depth-capped Epic ceiling.
**Why parked.** The UI needs the parts model and forge-house roster to select *from*, the depth-ladder gating to be real numbers, and the timed-order infrastructure (shared with dispatches §11b).
**Unblocks.** Forge houses defined (at least the starting house) and the 39-rung ladder's power curve locked enough that "deepest − 3 rungs" is a computable cap.

### 11e. Platinum currency + town reset
**What.** The prestige revision's core (§6): platinum earned per prestige, the pre-reset town-upgrade spend window, the town reset itself, soul bonuses carrying forward.
**Why parked.** It revises the live `Prestige` autoload's additive-only guarantee — the deepest systems change on the table. It needs a designed sequence (earn → spend window → reset → next run) before any code is touched, because the current tests *assert* nothing resets and those tests encode the old decision.
**Unblocks.** A written prestige-sequence design that answers the open questions in §12 (#3–#5) — especially what platinum-bought town upgrades mean across a reset — plus James's sign-off that the additive-only test suite gets rewritten, not patched.

### 11f. Elements system
**What.** The dual elements design (§8): damage types with resistances + elemental interaction table.
**Why parked.** Both halves need data: enemy resistance profiles per depth band (for the damage-type side) and an interaction matrix (for the fire-melts-ice side). Writing the matrix before enemies have elements is world-building without a world.
**Unblocks.** The enemy/bestiary design carrying element tags, and the combat model's damage pipeline being element-aware. The interaction table is written *after* the resistance table, not before.

---

## 12. Open Questions for James

1. **Forward clock jumps, now that there's no cap.** The old design clamped forward jumps to 12h; with no cap, a player who sets their clock forward a year earns a year's farm. Options: (a) accept it — time-travelers were already getting the honest 12h for free, and grinding via clock-toggling is self-punishing tedium; (b) clamp forward jumps to a sane bound (e.g., the longest *honest* absence, ~24h) while honest time stays uncapped — but the game can't distinguish them; (c) a soft "that seems like a long time" sanity threshold with a one-tap confirm. Your call — the non-punishment principle says (a) or (c), never a ban.
2. **Hardcore semantics.** The build coordinator's judgment call is recorded: death forfeits all carried gold + ramp becomes +5%/run instead of +2%. Confirm, adjust, or veto — and should hardcore also forfeit carried *materials*, or is gold the whole stake?
3. **Platinum → town upgrades → reset: what survives?** You spend platinum on town upgrades *before* the reset, then the town resets. Do the platinum-bought upgrades (a) apply to the *next* town as permanent soul-level unlocks, (b) apply to the current town for its final stretch and are then lost (a farewell feast), or (c) something else? This is the single most load-bearing ambiguity in the revision — the whole prestige sequence design hinges on it.
4. **Soul bonuses vs. the old perk registry.** The implemented `Prestige` autoload grants +1 stack of every unlocked perk per ascension (Gilded Soul, +10% gold). Does that registry survive alongside the Soul Tree, or does the Soul Tree *absorb* the perk stacks? Two compounding multiplier systems (perk stacks + tree ×2s) could stack into silliness — or into exactly the infinity you want.
5. **The tavern deed vs. the gold purchase.** The guild paper's hall chain gates the tavern behind gold + depth. Now Pello hands you the deed at depth 10. Does the deed *replace* the gold cost (the breadcrumb trail is the real price — five meetings, ten floors), or does the deed unlock the *option* to buy (deed + gold)? Related: the NPC paper's "come find me when you've bought that old tavern" lines still work either way — Pello just becomes the closer.
6. **Well Stocked numbers.** Suggested starter: +15% material yield, stacking with everything, never build-defining (matching the other four buffs' tuning: Well Fed +10% max HP, Well Rested +15% regen, Well Armed +8% attack, Inspired +10% luck). Right neighborhood?
7. **Breadcrumb reset on ascension — the miner question.** The NPC paper has the four NPCs re-meetable each cycle. With five now: does Harlan's Well Stocked re-grant stack, refresh, or is it once-per-cycle flat like the others? And the standing question from that paper still holds — should ascension re-earn *all* buffs, or keep them permanent with re-meetings as pure flavor?
8. **Elements: how many?** Fire, ice, water, lightning, earth, shadow, light…? The interaction table's size grows quadratically — 6 elements = 30+ interactions to write and tune. Start small (4–5) and grow, or go wide from day one?
9. **The 2^N / 10^N gap: visible or hidden?** Should the game ever *show* the player these exponents (OSRS-transparency style — "next loop costs 10×, pays 2×"), or is the math felt but never stated? Showing it makes the infinity legible; hiding it keeps the mystery.
10. **Undercrucible name in-world.** "Undercrucible" is locked as the name. Does the machine get an in-world explainer like the other systems got faces (Marla = HP, Pello = death shop)? Or does it stay a strange machine in the death shop, unexplained — some things in the dark don't get a face?

---

*End of decision record. Directed by James Greenlee ("Aethelwarden Solas"); written by Milo. Standing rules honored: original names/lore only, no AI-generated assets, staged CC0 only, credits use the pseudonym.*
