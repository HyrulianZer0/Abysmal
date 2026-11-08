# Named Uniques: Unique-as-Rarity-Roll — Design Target for Abysmal
*Designed Oct 8, 2026. For Abysmal — a 2.5D first-person idle dungeon crawler roguelike (Godot 4.7, Android-first): idle auto-delving, death → death shop (14 skills incl. merged Luck), per-death monster ramp (+2%/run, capped +50%), 39-rung power ladder (goal), staged CC0 assets only.*

**Terminology note:** "D2" in this paper means **Minecraft Dungeons II (2026)**, not Diablo 2. "D3"/"D4" mean Diablo 3/4. (The earlier loot papers use the same convention.)

**Status: TARGET DESIGN — parked until the ladder/part engine exists.** James parked this system pending the 39-rung ladder and the parts engine (forge houses, blades, hilts, guards, charms). The current game runs 4-tier rarity on a fixed item list. Do not retrofit this early — this paper is the spec the engine will plug into when it's built. Everything below assumes the ladder + parts model from `borderlands-loot-research-2026-10.md`.

**Lineage:** this design is a direct adaptation of D2's unique system (see `minecraft-dungeons-loot-research-2026-10.md`, D2 Uniques section): a Unique is not a separate loot entry — it's a base item that rolled top rarity and *transforms* into its named version, carrying one fixed signature effect plus one re-rollable bonus effect.

## 1. The core mechanic: the transform

When an item at a qualifying rung rolls the top rarity outcome, it does not just get better stats — it **transforms**:

1. Its Forge + Blade title is **replaced** by its unique name (fixed full name, no prefix — the name IS the card).
2. It keeps its rolled parts (Hilt, Guard, Charm) — the unique is still *your* drop, not a static handout.
3. It gains **one fixed signature effect** (the reason the item has a name — a build-defining behavior, not a stat bump).
4. It gains **one re-rollable bonus effect** (a standard stat line, re-rollable at the death shop / Converter — the D2 Blacksmith lineage).

Example: a crit-house Piercer at Legendary rung rolls Unique → it becomes **Needle's Verdict**, keeps its rolled Swift Hilt and Warden Guard, gains its signature (*critical hits ignore armor…*) plus one random bonus effect you can re-roll later.

Why this is the right model: one loot pool per item family, so the unique table never needs separate drop entries; every drop at a qualifying rung carries a lottery ticket; and the transform moment is inherently dramatic — a plain Cleaver *becoming* a named legend is a better story than a separate item appearing. (D2 takeaway #1 from the earlier research: the single best idea in the survey.)

## 2. Which rungs uniques can roll on

- The Unique rarity outcome exists **only at the Legendary rung and above** (Legendary → Exotic → letter tiers F→EX). Below Legendary, the rarity roll caps at Special.
- Rationale: Legendary is where names begin. The letter tiers are pure power rungs (parts rolled at Epic/Legendary structure, per the Borderlands paper), so uniques there draw from the **same pool at higher power** — one pool, no content duplication, and the chase naturally extends up the ladder.
- **Gentle-start gate:** pre-first-death runs have unique weights zeroed — with exactly one exception (Section 5). The first death opens the death shop *and* the unique system together: one onboarding beat, not two.

## 3. Rarity power offsets — structural, not cosmetic

Within a rung, the rarity roll sets a power offset, D2-style:

| Rarity | Power offset (rung-steps) |
|---|---|
| Common | −2 |
| Rare | −1 |
| Special | 0 |
| Unique | 0, at full current-depth strength |

The Unique always drops at **full strength for your depth** — never a dead roll you have to upgrade into relevance. This is structural, not cosmetic, because of the per-death ramp: at +2%/run compounding to +50%, a full-strength Unique with a signature effect is the item that lets a build hold the line against the next ramp tier. Each era's chase unique is the key to farming the next era — deaths start feeling like buying the next key, not losing progress. (OSRS takeaway #2 from the loot paper.)

Offsets are measured in rung-steps, not raw numbers, so they scale automatically with the exponential stat curve — no per-tier retuning as numbers inflate.

## 4. Source-modified rarity tables — explicit weights

Every drop rolls rarity from a weighted table, and **the source modifies the table** (the big D2 structural change). Starting-point weights for the Unique outcome, tuned for idle kill volume — see honesty notes:

| Source | Unique weight | Notes |
|---|---|---|
| Regular kills | 0.5% | Idle volume is enormous; per-kill rates must be low (see §11) |
| Elites | 4% | |
| Bosses | 18%, no Commons | Bosses never drop Commons (D2 lineage) |
| Boss chest | 12% | The reward chest is the farm |
| Simple/wooden chest | 3% | |
| Ornate/fancy chest | 10% | |
| Guild dispatch expedition | 5% per completed expedition | Flat; expedition class scales reward *count*, not chance |

These are **starting points for the idle sim, not locked numbers**. The tuning target: roughly **one unique every 2–3 delves from trash**, with bosses and chests layered on top — "easy, though not too easy" (James's rule). Tune to *expected uniques per run*, never to per-kill rates; per-kill rates lie in an idle game.

Publish these numbers in-game. D2's community had to datamine them; Abysmal should show them (OSRS transparency lesson from the loot paper: publish exactly what Luck and sources modify — transparency kills myths).

## 5. First-kill guarantee — the onboarding hook

- **Each boss's first-ever kill (per save) guarantees a unique drop.** This **overrides** the gentle-start gate — the first boss is the tutorial for the whole system.
- The guaranteed drop gets the full announcement treatment (§8) plus a one-time explainer beat: what a unique is, what the signature effect means, that the bonus effect is re-rollable.
- Subsequent kills of that boss use standard RNG (§4).
- This is the D2 first-victory guarantee, adapted: the player's first boss always pays off, teaching them what uniques are before the wider system opens at first death.

## 6. Chase protection (James-approved)

Both protections below were approved by James; they are non-negotiable constraints on the design:

1. **Top tier NEVER sold in shops — drop-only.** No shop inventory, death shop included, may ever contain a unique. The death shop may sell *services* for uniques (re-rolls, upgrades, extraction — §7) but never the items themselves. (D2 takeaway #8: no uniques from merchants — protecting the chase.)
2. **First-kill guarantee** (§5) — the onboarding hook doubles as the deterministic floor under the chase.

Supporting rules:
3. **Uniques are never auto-salvaged.** They go to a trophy stash reviewed at the death summary; the player decides, one tap at a time. Duplicates are pre-flagged for the Converter but never silently eaten (Demeo lesson: never silently delete — auto-convert *visibly*).
4. **Duplicates always have floor value** — every duplicate feeds the Converter for premium fuel (§7). A duplicate is never a dead drop.

## 7. Duplicates feed the Converter

The Converter lives in the death shop (loot-paper synthesis #1: one Converter beats ten drop-rate tweaks). Every duplicate unique is fuel, and fuel is progress — the idle game's most important emotional rule, since loot volume is high and most drops will be also-rans:

- **Extract signature → persistent library.** Destroy the duplicate, bank its signature effect at max roll, save-wide (D3 extract lineage). Banked signatures socket into **Rune charms** — this is the death-shop enchantment library concept from the Borderlands paper, given its endgame: the library is a persistent, upgradeable entity, and extracted signatures are what you socket.
- **Melt → premium fuel.** Duplicate becomes Converter fuel at a premium rate. While **Miser's Lantern** (§9) is equipped, duplicates yield **double fuel** — the chase item that makes the chase cheaper.
- **Re-roll the bonus effect.** Spend fuel/gold to re-roll the unique's one bonus effect. **Capped cost, never destroys the item** — the D4 anti-bricking lesson: cap the cost of failure at a currency chunk, never the item. Bricking a unique permanently is anti-idle.
- **No dupe protection on world drops** (honest design call): with the Converter eating duplicates at premium rates, duplicates are a resource, not a failure state. Dupe protection would just hide the fuel economy.

## 8. The announcement moment — broadcast wins

Idle games are checked, not watched — so the unique moment must survive being found while the player is away. Layered design (OSRS "broadcast the wins" takeaway):

- **First unique ever:** full-screen fanfare — name reveal animation, lore line, signature effect explained, tutorial beat. One time per save.
- **Every unique:** a distinct fanfare sting + a dedicated announcement card pinned to the top of the run/death summary. Never buried in the loot list — the death summary gets a **"Unique finds"** section.
- **Guild hall trophy wall:** each unique found for the first time earns a plaque — name, lore one-liner, the depth and date it dropped. Duplicates increment a counter on the plaque ("×4 — melted for fuel"). This is the town-hall trophy display from the loot paper: the collection is visible, permanent, and social-proof for a solo game.
- Art note: reveal cards use staged CC0 art only — **no AI-generated assets, ever** (standing rule).

## 9. Example uniques (11)

All names and lore are **fully original** (IP hygiene — nothing borrowed from any game). Each lists its base (forge-house descriptor + blade type, since house names aren't finalized), its lore one-liner, and its fixed signature effect. Each also rolls one re-rollable bonus effect (standard stat line — not listed; that's the re-roll sink).

**Weapons — Cleaver (high damage, slow):**
1. **Widow's Arithmetic** — *crit-house Cleaver.* "She counted her husbands in heartbeats, and never ran out of fingers." **Signature:** Critical hits detonate, dealing 30% of the damage to nearby enemies.
2. **Red Ledger** — *lifesteal-house Cleaver.* "Every debt in the deep is paid in red ink." **Signature:** Kills grant a ward equal to 20% of overkill damage, stacking to 50% of max HP.

**Weapons — Duelist (fast, low damage):**
3. **Hundredth Whisper** — *flurry-house Duelist.* "The ninety-nine before it were only practice." **Signature:** +3% attack speed per consecutive hit on the same target, stacking 20 times; switching targets resets the stack.
4. **Static Sermon** — *elemental-house Duelist.* "It preaches, and the deep answers in sparks." **Signature:** Hits apply Spark (max 10 stacks); at 10 stacks, lightning strikes the target for 150% weapon damage.

**Weapons — Piercer (high crit):**
5. **Needle's Verdict** — *crit-house Piercer.* "The trial is brief. The sentence is final." **Signature:** Critical hits ignore armor and deal +40% damage to enemies above 75% HP.
6. **Patient Edge** — *counter/parry-house Piercer.* "It has never struck first, and has never needed to strike twice." **Signature:** After a successful parry, your next attack within 4 seconds is a guaranteed critical for +100% damage.

**Weapons — Crusher (armor-shred):**
7. **Foundation's Grudge** — *slow-heavy-house Crusher.* "The mountain remembers every pickaxe." **Signature:** Hits permanently reduce the target's armor by 2% (max 25 stacks); at max stacks the target is Sundered, taking +20% damage from all sources.
8. **Grave Tithe** — *lifesteal-house Crusher.* "The deep collects. It always collects." **Signature:** Heal for 10% of damage dealt; healing doubles against enemies below 30% HP.

**Armor:**
9. **Bulwark of the Ninth Bell** — *plate chest.* "It rang nine times the night the delve fell. It has not rung since." **Signature:** Once per delve, cheat death — survive a fatal blow at 25% HP and gain 3 seconds of immunity. *(Idle logic: this is the run-saver; it converts one death into one more floor.)*
10. **Tenth-Step Treads** — *boots.* "Nine steps to the bottom. The tenth is yours." **Signature:** +20% delve speed; +50% move speed for 2 seconds after each kill. *(Idle logic: clear speed is efficiency; this is the farmer's signature.)*

**Charm:**
11. **Miser's Lantern** — *charm.* "It burns brightest over the things nobody else wanted." **Signature:** Duplicates fed to the Converter yield double fuel. *(The chase-eats-itself item: the more you farm, the faster the library grows.)*

Design notes on the set: signatures are **behaviors, not stat bumps** (the D2 "Unique tier of an enchantment" lineage — a stronger version of a standard effect, or something standards can't do at all: cheat death, Sunder, ward-from-overkill). Spread covers all four blade types, six forge-house descriptors, two armor slots, and the charm slot. Starter pool target: **24–36 uniques** (~2 per blade type per house + armor + charms), data-driven so the pool grows without code changes.

## 10. Luck interaction — Luck stays the player's friend

- The merged Luck skill adds **+0.25 percentage points of unique chance per level, on every source** (§4 table). Shown in-game as "Luck: +X% unique chance." Flat, uncapped, transparent.
- Luck never gates, never penalizes, never has a downside — James's standing rule. It only ever helps, and the game publishes exactly what it modifies (OSRS transparency lesson).
- **Miser's Lantern** (§9) is the Luck-adjacent chase item: it doesn't raise drop rates, it raises what duplicates are *worth* — Luck's friend, not Luck's replacement.
- Unchanged: Luck still feeds the death shop as the deterministic shadow (loot-paper synthesis #2). Uniques are the RNG track; the shop is the pity track.

## 11. Gaps and honesty notes

- **D2 numbers are single-source community datamining** (metabot.gg, published days after launch) — treated as lineage and inspiration, not gospel. The §4 weights are Abysmal-original starting points, not ports.
- **§4 weights are NOT tuned.** Idle kill volume makes per-kill rates deceptive — a 0.5% that looks rare on paper is a flood at 10,000 kills/hour. Final numbers must come from the idle sim, tuned to *expected uniques per run*, before this system ships.
- **Parked, by design.** This paper specifies the target the ladder/part engine will plug into. The current 4-tier fixed list should not be retrofitted with transforms early — half a unique system is worse than none.
- **Forge-house names aren't finalized** — §9 uses generic descriptors (crit-house, lifesteal-house, …) deliberately. Final lore strings wait on house naming.
- **No AI-generated assets, ever.** Unique reveal cards, trophy plaques, and icons are staged CC0 or original art only.
- Not legal advice: before commercial release, trademark-screen the unique names alongside the title screen (per the standing IP-hygiene note).

## Design takeaways

1. **Unique-as-rarity-roll collapses two systems into one.** One loot pool per item family; the rarity roll transforms the item. Every drop at a qualifying rung carries a lottery ticket.
2. **Top rarity drops at full depth strength — structural, not cosmetic.** With the +2%/death ramp compounding to +50%, the Unique is the item that holds the line against the next era. The chase has a job, not just a glow.
3. **Source-modified tables make odds farmable.** Boss 18% vs. trash 0.5% is a decision the player can feel — push harder content, change your odds. Publish the numbers in-game; never make the community datamine them.
4. **First-kill guarantee is the onboarding hook.** The first boss always pays a unique and teaches the system; the wider system opens at first death alongside the death shop. One tutorial beat, not two.
5. **Drop-only is the chase protection.** No shop — death shop included — ever sells a unique. The shop sells *services* for uniques (re-rolls, extraction), never the items. (James-approved, non-negotiable.)
6. **Duplicates are fuel, not failure.** The Converter (extract / melt / re-roll, capped costs, never destroys) makes every duplicate progress. No dupe protection needed — the fuel economy is the protection.
7. **Broadcast the wins.** First-find fanfare, per-unique announcement cards, guild-hall trophy wall with lore plaques and melt counters. Idle games are checked, not watched — the moment must survive being found while away.
8. **Signatures are behaviors, not stat bumps.** Cheat death, Sunder, ward-from-overkill, parry-into-guaranteed-crit — each unique should enable something standard effects can't do. If a signature reads as "+X% damage," cut it.
9. **Luck only ever helps, and says so.** Flat +0.25pp/level, published in-game, no downside anywhere. Luck stays the player's friend — the rule is load-bearing for the whole drop economy's feel.
10. **Parked means parked.** This is the target spec for the ladder/part engine. Ship the engine first; plug this in whole.

## Open questions for James

1. **Boss-attuned uniques?** Should each boss have a signature unique (first-kill guarantee pays *that boss's* item), or should the guarantee roll from the general pool? Attuned = farmable chase per boss; general = simpler pool.
2. **Unowned-first on guarantees?** If a boss's first-kill guarantee rolls while you own some of its pool, should it prefer uniques you don't have yet, or pure RNG? (World drops stay pure RNG — duplicates are fuel.)
3. **Armor uniques: full sets or one-offs?** D2 has 19 full armor sets; §9 proposes one-off armor pieces. Do you want set bonuses down the line, or keep armor uniques as standalone chase pieces?
4. **Gentle-start gate: first death, or a depth threshold?** Currently: uniques unlock at first death (except the first-kill guarantee). Alternative: unlock at depth 8+ regardless of deaths. Which reads better?
5. **Reroll/extract currency: one currency per tier?** The WoW lesson from the loot paper says two-currency bottlenecks are the most resented design in modern games. Should Converter costs be pure gold, pure fuel, or one dedicated currency?
6. **Trophy wall placement:** guild hall (ties to the guild-hall upgrade chain) or town hall (ties to the town loop)? It wants to be somewhere the player *sees* it every session.
7. **Exotic/letter-tier uniques: same pool, or ascended variants?** Currently the same pool at higher power. Alternative: Exotic+ rolls add a second signature or an empowered version of the signature. More chase, more content cost.
8. **Starter pool size:** §9 proposes 24–36 uniques at launch. Too many to write well, too few to chase? And do you want community-submitted names/lore down the line (credits as Aethelwarden Solas stay clean — submissions would need a policy)?
9. **Should elites have a mini-guarantee?** E.g., every Nth elite kill forces a minimum Special+ roll — a small deterministic floor under the mid-tier chase, D2's "fancy sources get better tables" extended downward.
10. **Unique drop sound/visual identity:** one shared fanfare for all uniques, or per-house stings (crit-house gets a sharp crack, lifesteal-house a low pulse)? Cheap to do with staged audio, big feel payoff — worth it?
