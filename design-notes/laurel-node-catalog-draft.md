# Laurel Node Catalog — DRAFT

**Game:** Abysmal
**Producer / Director:** Aethelwarden Solas
**Drafted:** Nov 4, 2026 — design document only, James decides
**Revised:** Nov 7, 2026 — currency only: Hope tokens → skill points, per James's Nov 4 evening decision (Hope dropped as a currency, kept as theme only). No node, cost number, effect, or scaling rule changed. **Cut Nov 7:** Ascendant Leaf + Eternal Vine removed per James (rebirth isn't key; replayability is), and Ouroboros Loop removed (a text description of the laurel — it never truly ends — not a purchasable node) — 38 nodes total after the cuts.
**Status:** DRAFT / PROPOSAL. Nothing in this document changes a scene, a script, or a build. It is the catalog a future weekly push would build from — after James approves it.

**How to read the numbers:** every cost, effect, and rate below is labeled **DRAFT** or **PROPOSAL**. James has not approved any cost or effect value. The *shape* (branching tree, dense nodes, tappable) and the *currency* (skill points) is James's Nov 4 evening decision and is applied exactly. **Hope is theme only — not a currency.** The numbers are placeholders for him to correct.

---

## 1. Locked canon this draft builds on

These are not proposals — they are already locked and this draft does not change them:

- **The Laurel IS the Life Tree's form.** The vine that holds the leaves together *is* the ascension tree. No crown jewel. New leaves grow as needed, for infinite playthroughs.
- **Six starting leaves:** the 5 founders + Deep. The tree unlocks on completing depth 1; founder leaves join as their founders are met — Marla (depth 2), Harlan (depth 4), Tovan (depth 6), Sarella (depth 8), Pello (depth 10).
- **Deep leaf** = a simple dark leaf.
- **Nodes are currency-gated only, never path-gated.** An unaffordable node is dimmed but visible, never hidden, never locked behind another node. Every node is worth having; there are no bad picks.
- **Nodes upgrade indefinitely.** No node ever shows a false "MAX" state — the level number keeps climbing and a next step is always shown.
- **The Laurel persists through rebirth** — PENDING in code. Rebirth does not exist in the game yet, so persistence-through-rebirth is a design promise this draft records, not a behavior any code performs today.
- **The HUD button still reads "Life Tree."** The glyph follow-up is a separate open item and is NOT redesigned here.

## 2. James's Nov 4 decisions — applied exactly

- **Shape: Civilization-style BRANCHING tree, nodes CLOSER together (denser) than a sparse tree, nodes TAPPABLE.** The catalog below is organized as branches, dense with nodes, each node a tap target.
- **Currency: SKILL POINTS, not Hope.** 1 platinum per building/room upgrade = 1 skill point. Currency tiers run copper → silver → gold → platinum. Gold is a good starter tier; more tiers are possible later.
- **Skill points come from the DEPTHS, via towns.** Dungeon loot funds town buildings/upgrades; upgrading a building/room to platinum yields skill points for the Laurel. Income scales with town upgrades — the more you upgrade the towns, the more you get per thing.
- **Gold → skill points → (Ambrosia open).** Buildings are the skill-point ENGINE; the Laurel is the skill-point SINK. (Ambrosia belongs to rebirth and the Temple — it does not buy Laurel nodes in this draft, and the old Gold → Hope → Ambrosia chain is broken at the Hope link: Ambrosia sourcing is open.)

### Shape-vs-gating note (needs James's confirmation)

Civilization trees normally gate later nodes behind earlier ones. Abysmal's locked canon says the opposite: currency is the ONLY gate, never path. This draft keeps the locked rule and uses the Civ shape for **organization only** — branches group related nodes and show the tree's growth, but a node deep in a branch is purchasable the moment you can afford it, even if earlier nodes in its branch are unbought. If James wants Civ-style prerequisites after all, that overturns the no-path-gate lock and must be decided explicitly (see §7).

## 3. How skill points are earned (as James described it, Nov 4 evening)

**DRAFT mechanics — values are proposals, the structure is James's:**

1. **Dungeon gold funds towns.** Gold buys town founding and upgrades (existing canon: tavern stage 1 at 1,500 G → guild at 10,000 G + depth 10 → expanded guild at 50,000 G + depth 20 → HQ at 200,000 G + depth 35; later towns gold-gated by charter proposals of ~25k / 100k / 400k).
2. **Town upgrades yield skill points at platinum.** When an upgrade reaches platinum tier — even a single room of a building of a specific kind — it yields skill points spendable on the Laurel. **DRAFT:** one platinum-tier room = 1 skill point (proposal; the skill-point-per-upgrade count is undecided).
3. **Skill points are the spendable unit on the Laurel.** Spending on the Laurel consumes whole skill points. There is no fractional accrual to round or bank — a skill point is earned whole, when a platinum upgrade lands. (The code's orphaned `hope` float, added Nov 4 with save/load and no income/UI/costs, is NOT the skill-point balance and still needs a cleanup pass.)
4. **Currencies stay flexible/revisitable.** James's Nov 4 evening word: the currency tiers and this rule can be stepped back from later if they don't play right — nothing here is locked beyond the skill-point currency itself.

**What this means in play:** you delve for loot in the depths → loot funds town buildings/upgrades → platinum upgrades yield skill points → skill points buy permanent Laurel power → permanent power makes delving deeper easier → deeper delving funds bigger towns. The loop is sequencing, not starvation: skill points are never a choke point that stops play, they are the slow permanent-growth track beside the run-to-run dungeon loop.

## 4. How skill points are spent on the Laurel

1. Open the Laurel (HUD button reads "Life Tree" for now).
2. Tap any node in any branch. Its card shows icon + name + current level + next effect + skill-point cost — the same four things, in the same places, every time (per the laurel UI draft).
3. If you can afford it, tapping buys the next level. The effect applies permanently and immediately. The node shows its new level and its next cost. There is no "MAX."
4. If you cannot afford it, the node is dimmed but fully visible, with its cost shown so you can see what to save toward. It is never hidden and never locked behind another node.
5. Founder passives (the automatic gifts that root when you meet a founder) are not purchases: they simply *are*, drawn as grown-in gold vein segments, with no cost and no button (per the laurel UI draft's proposal).

## 5. Branch structure — Civ-like, dense, tappable

The trunk is the **vine** (the ascension tree itself). Six branches root in the six leaves. Each branch below lists its theme, its founder (where one applies), and its nodes. Every node entry gives a **DRAFT** effect and a **DRAFT** first-level skill-point cost; scaling follows §6.

### Branch 0 — The Vine (ascension trunk, no founder)

Universal nodes. (The ascension track was cut Nov 7 per James: rebirth isn't key, replayability is. Ouroboros Loop was also cut the same day — it was a text description of the laurel, that it never truly ends, not a purchasable node.)

| Node | DRAFT effect (level 1) | DRAFT cost (Lv. 1) |
|---|---|---|
| Deep Roots | +2% max HP, permanent | 1 skill point |
| Steady Step | +2% move speed in the dungeon | 1 skill point |
| Second Wind | +1% HP regen per second | 2 skill points |

### Branch 1 — Marla's Leaf (farmer, depth 2): vitality and sustenance

| Node | DRAFT effect (level 1) | DRAFT cost (Lv. 1) |
|---|---|---|
| Warm Hearth | +3% max HP | 1 skill point |
| Harvest Hands | +2% healing from food | 1 skill point |
| Stout Heart | +1% resistance to hunger drain | 1 skill point |
| Field Medicine | Potions heal +2% more | 2 skill points |
| Granary | +2% carry capacity for food | 2 skill points |
| Farmer's Patience | +1% HP regen while idle | 3 skill points |

### Branch 2 — Harlan's Leaf (miner, depth 4): materials and yield

| Node | DRAFT effect (level 1) | DRAFT cost (Lv. 1) |
|---|---|---|
| Deep Pockets | +2% material yield | 1 skill point |
| Keen Eye | +2% rare material chance | 1 skill point |
| Sturdy Pack | +2% carry capacity for materials | 1 skill point |
| Seam Sense | +1% chance of a bonus drop per kill | 2 skill points |
| Quarry Gift | +2% gold from selling materials | 2 skill points |
| Motherlode | +1% chance a drop is doubled | 4 skill points |

### Branch 3 — Tovan's Leaf (woodcutter, depth 6): strength and damage

| Node | DRAFT effect (level 1) | DRAFT cost (Lv. 1) |
|---|---|---|
| Strong Swing | +2% attack | 1 skill point |
| Felling Blow | +1% critical chance | 2 skill points |
| Timber Frame | +2% damage to large foes | 2 skill points |
| Axe Rhythm | +1% attack speed | 3 skill points |
| Clear Cut | +2% damage after a kill (5 s) | 3 skill points |
| Old Oak | +2% attack and +1% max HP | 4 skill points |

### Branch 4 — Sarella's Leaf (blacksmith, depth 8): gear and defense

| Node | DRAFT effect (level 1) | DRAFT cost (Lv. 1) |
|---|---|---|
| Iron Skin | +2% defense | 1 skill point |
| Smith's Care | Crafting costs −1% gold | 1 skill point |
| Tempered Edge | Weapons keep +1% damage after repair | 2 skill points |
| Reinforced Plates | +2% max armor durability | 2 skill points |
| Masterwork | +1% chance crafted gear is superior | 3 skill points |
| Anvil Blessing | +2% defense and +1% attack | 4 skill points |

### Branch 5 — Pello's Leaf (trader, depth 10): fortune and trade

| Node | DRAFT effect (level 1) | DRAFT cost (Lv. 1) |
|---|---|---|
| Lucky Coin | +2% luck (drop quality) | 1 skill point |
| Trader's Tongue | Shop prices −1% | 1 skill point |
| Caravan Sense | +2% gold find | 1 skill point |
| Pello's Ledger | +1% sell prices | 2 skill points |
| Road Warden | +1% chance to avoid ambushes | 2 skill points |
| Golden Road | +2% luck and +1% gold find | 4 skill points |

### Branch 6 — Deep Leaf (simple dark leaf): the abyss and the idle

| Node | DRAFT effect (level 1) | DRAFT cost (Lv. 1) |
|---|---|---|
| Dark Sight | +2% vision range in dark floors | 1 skill point |
| Abyssal Calm | +1% resistance to fear effects | 1 skill point |
| Deep Earnings | +2% offline earnings | 2 skill points |
| Delver's Mark | +1% experience from delve | 2 skill points |
| Still Water | Idle gains tick +1% faster | 3 skill points |
| The Dark Below | +2% damage at depths 20+ | 4 skill points |

**New growth:** buying nodes sprouts new veins and new nodes further out in the same branch — a branch never runs out of room. New nodes join their branch's list in growth order; the tree never reorders nodes you already know. (This matches the laurel UI draft's ever-expanding rule; the exact new-node unlock pacing is undecided, see §7.)

## 6. Indefinite-upgrade scaling rule (PROPOSAL)

One rule covers every node, so the catalog never needs infinite rows:

- **Effect growth — linear (PROPOSAL):** each level adds the same amount as level 1. A node giving +2% attack at level 1 gives +4% at level 2, +6% at level 3, and +2% × level at any level. No diminishing returns, no hidden curve — the next-effect line always shows the next step in plain numbers.
- **Cost growth — geometric (PROPOSAL):** each level costs 1.15× the previous level's cost, rounded up to a whole skill point. Cost(level) = round_up(first_cost × 1.15^(level−1)).
- **Worked example (DRAFT):** a node with first cost 1 skill point costs 1, 2, 2, 2, 3, 3, 3, 4, 4, 5 skill points at levels 1–10 (cumulative 29 skill points for level 10). A node with first cost 4 skill points costs 4, 5, 6, 7, 8, 9, 10, 12, 13, 15 at levels 1–10 (cumulative 89 skill points for level 10).
- **No cap, no "MAX."** A node at level 100 still shows level 101's effect and cost. If a node ever needs a cap for technical reasons, that cap must be decided explicitly — it is not assumed here.

Both halves of this rule are proposals. James may change the effect curve, the cost multiplier, or both without changing the branch structure.

## 7. What remains undecided — James must approve before any code is written

1. **The node list itself.** Are these the right branches and nodes? Anything missing, anything to cut, anything renamed? (Founder-leaf themes follow founder roles — farmer, miner, woodcutter, blacksmith, trader — but the specific node picks are this draft's, not James's.)
2. **Every cost and effect value.** All numbers above are DRAFT placeholders. Nothing ships until James approves or corrects them.
3. **The scaling rule.** Linear effects + 1.15× costs is a proposal. Confirm or replace.
4. **Civ shape vs. no-path-gate lock.** Confirm that branches organize but never gate (§2). If James wants prerequisites, that overturns a locked rule and needs an explicit decision.
5. **Skill-point income rates.** How many skill points per platinum-tier upgrade (draft says 1)? Which buildings and rooms count as "platinum tier"? Do later towns generate skill points at the same rates? (Per James's Nov 4 evening refinement: income comes from the DEPTHS — dungeon loot → town → upgrades; 1 platinum per building/room upgrade = 1 skill point. There is no per-hour Hope generation.)
6. **Skill-point granularity.** Skill points are whole units (1 platinum upgrade = 1 skill point); Laurel spending is in whole skill points. There is no fractional accrual to bank, and no offline accrual question for skill points. (The code's orphaned `hope` float, added Nov 4 with save/load and no income/UI/costs, is NOT the skill-point balance — it still needs a cleanup pass before any Laurel code is written.)
7. **New-node growth pacing.** What makes a branch sprout new nodes — every purchase, every N purchases, every town upgrade, or something else?
8. **Rebirth persistence implementation.** The Laurel persists through rebirth by design, but rebirth does not exist in code. Nothing here assumes rebirth works — the ascension nodes that were in Branch 0 were cut Nov 7 per James (rebirth isn't key; replayability is).
9. **HUD glyph.** The HUD button still reads "Life Tree." The glyph follow-up is separate and untouched by this draft.
10. **Ambrosia interplay.** This draft keeps Ambrosia out of the Laurel (Ambrosia = rebirth → Temple). If James wants any Laurel node to cost Ambrosia, that is a new decision.
11. **OPEN QUESTION — "what was it that Jeff wanted Hope for?"** James asked this Nov 4. **No record exists** of Jeff asking for Hope for any specific purpose. The design docs were searched: the only Jeff+Hope record is that Jeff's Oct 20 design feedback reshaped Hope, the Life Tree, and the laurel itself, and that a later feedback round covers those topics for gameplay-feel eyes. That is Jeff *shaping* Hope, not Jeff *wanting* Hope for something. This question stays open for James — nothing here invents a Jeff-Hope link.

## 8. Approval checklist — nothing is built until James ticks these

- [ ] Branch structure and node list approved (or corrected)
- [ ] Cost and effect values approved (or corrected)
- [ ] Scaling rule approved (or replaced)
- [ ] Shape-vs-gating confirmed (§2)
- [ ] Skill-point income rates + platinum skill-point rule approved
- [ ] Skill-point granularity decided (whole points only; no fractional accrual)
- [ ] New-node growth pacing decided
- [ ] Jeff-Hope open question answered or set aside by James

---

*End of draft. Locked canon followed: Laurel = Life Tree's form, vine = ascension tree, 6 starting leaves (founders at depths 2/4/6/8/10 + Deep), currency-gated only, indefinite upgrades, persistence through rebirth (pending code). James's Nov 4 decisions applied: Civ-style branching tree, dense tappable nodes, SKILL POINTS from platinum town upgrades (copper → silver → gold → platinum, gold a good starter, 1 platinum upgrade = 1 skill point). Hope is theme only, not a currency. All numbers are DRAFT proposals.*
