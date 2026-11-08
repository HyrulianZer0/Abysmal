# Loot, Drop & Progression Systems — Design Reference for Abysmal
*Researched Oct 7, 2026. For a 2.5D first-person idle dungeon crawler roguelike (Godot, Android-first): exponential stat scaling, town/guild management, per-death monster ramp (+5% HP/ATK per run, capped +50%), a single merged Luck skill feeding a death shop, 14-skill roster.*

All mechanics below are summarized in original wording with source links — no wiki tables reproduced verbatim. Exact numbers flagged as community-reported vs. officially confirmed.

## 1. Old School RuneScape (OSRS)

**Rarity / drop structure.** Kill resolution is layered, not one table: a guaranteed 100% drop → one weighted roll on the main drop table → a secondary roll (complementary items; can never hit main-table uniques) → a tertiary roll on an independent parallel table (clue scrolls, pets, monster heads) → the shared Rare Drop Table cascade (Gem → Standard → Mega-rare, with multiplicative odds, e.g. 1/128 × 1/128 = 1/16,384). Rolls are memoryless — no pity; dry streaks are officially acknowledged as normal. Drop rates are community-datamined (RuneLite Drop Rate Project), not published by Jagex.

**What modifies drop odds.** Almost nothing — deliberately. The Ring of Wealth does NOT raise unique rates (the most myth-busted mechanic in the game): it only deletes "nothing" slots from the RDT/gem tables and is worn only at the killing blow. Wilderness, slayer, and diary perks modify which tables you can roll on or how many rolls you get, not base fractions.

**Upgrade / crafting sinks.** GE 2% sales tax funds an automated system that buys and deletes targeted expensive items; charge-consuming chase items (the toxic blowpipe eats scales + darts per attack — the best weapon is a permanent loot drain); ornament kits (cosmetic prestige variants that delete the base item + kit); death mechanics (unprotected items destroyed or reclaim-fee'd).

**Design takeaways for Abysmal**
1. Split kill resolution into independent tables and let Luck touch exactly one. Have Luck feed a global "Abyss lottery" table (and the death shop), never monster-specific uniques — and publish in-game what Luck actually modifies. Transparency kills myths.
2. Gate chase uniques three ways: access (skill/depth requirement) + odds + utility. The per-death +5% ramp pairs perfectly: each era's chase item is what makes the next +50%-ramped tier farmable, so deaths feel like buying the next key.
3. Build sinks as features: blowpipe-style items/structures that consume farmed loot per delve, plus ornament-kit-style town prestige cosmetics — gold-to-status conversion with zero power creep.
4. Layer 3–4 simultaneous lotteries per delve and broadcast the wins — town-hall trophy display and a rare-drop announcement moment. OSRS's legendary feel comes from the stack, not any one table.

Sources: OSRS wiki (oldschool.runescape.wiki), RuneLite Drop Rate Project.

## 2. World of Warcraft (retail — Midnight, patch 12.1 Season 2)

**Rarity / drop structure.** Quality ladder Poor → Heirloom, plus a new Midnight "Very Rare" tier. Loot item level scales by difficulty band: LFR 279 → Normal 292 → Heroic 305 → Mythic 318–344. Distribution evolved: Group Loot → Personal Loot (killed ninja looting) → Group Loot 2.0 (spec-restricted Need rolls). Lesson: the distribution method matters less than visible, legible reward moments.

**What modifies drop odds.** Difficulty chosen, keystone level breakpoints, loot-specialization filtering, weekly raid lockouts, hidden bad-luck-protection counters (Legion legendaries had a confirmed-but-undocumented pity counter), and a deterministic shadow system beside every RNG system.

**Pity / deterministic systems.** Great Vault: weekly effort across 3 rows unlocks up to 9 loot choices; you pick ONE per week; item level scales with highest difficulty done. Upgrade tracks (Adventurer→Veteran→Champion→Hero→Myth) turn any drop into a deterministic stepping stone via crest currency — and Valorstones were deleted in Midnight after years of player hatred for the two-currency bottleneck (now one crest type per tier). Sparks (limited seasonal crafting reagent for a chosen BiS slot); the Catalyst converts non-set gear into tier-set pieces on a slow charge drip (tier-set bad-luck insurance).

**Design takeaways for Abysmal**
1. Deterministic shadows for every RNG roll. The Luck skill + death shop should be Abysmal's deterministic shadow.
2. Run-results → choose-1-of-N. The Great Vault pattern fits the death moment perfectly: run summary offers 3 choices, pick 1. One decision, big satisfaction, zero inventory fiddling on a phone.
3. One currency per tier. Learn from the Valorstone deletion — two-currency bottlenecks are the most resented design in modern WoW.
4. Map depth bands to loot tracks so the per-death +5% ramp reads as a ladder: each ramp tier is a named track, making the +50% cap feel like a climb, not a treadmill.

Sources: Wowhead, Icy Veins, Blizzard sources. Caveat: exact BLP formulas are community-reported, not Blizzard-published.

## 3. No Man's Sky

**Procedural generation.** Seeded, deterministic, hierarchical: one 64-bit founding seed → star coordinates seed planets → planet position seeds terrain/climate → climate seeds flora/fauna. The real tuning work was coherence rules. Worlds Part II (Jan 2025) applied new generation only to new systems — never regenerating existing ones, so no player progress was reset.

**Resource / economy loops.** Tiered resources: common elements → refined versions → biome-specific harvestables → stellar metals of escalating rarity (rarer in more dangerous systems). Scarcity is spatial — better inputs require traveling further into harder systems. Refining chains convert raw→refined; Nanites form a separate tech currency spent only on blueprints/upgrades.

**Economy systems.** Every system has one of 7 economy types × 3 strength tiers, with fixed cyclical trade routes and buy/sell modifiers vs. galactic average. Frigate expeditions: up to 30 frigates in 5 classes, up to 5 sent on timed real-time missions; balanced fleets succeed, mismatched fleets risk damaged frigates requiring resource repairs; idle frigates trickle resources when landed.

**Expedition structure.** Seasonal expeditions (~4–8 weeks each): 5 phases + final phase, each with 6–9 named milestones. Milestones pay immediately in useful items/currency; completing a phase pays exclusive cosmetics. Expedition 7: Leviathan was explicitly a roguelike experiment — death reset a time loop on survival difficulty.

**Settlement management.** Players become Overseer of settlements with 5 legible stats (productivity, population, happiness, upkeep, sentinel alert). Buildings have C–S class ranks; settlements start in debt (upkeep > productivity) that auto-repays from surplus. Timed decisions trade off the stats. Optimized settlements produce a daily claimable payout.

**Design takeaways for Abysmal**
1. Hierarchical seeds + coherence rules: seed run → floor → room → loot, and spend tuning budget on the constraints (fairness curves, the per-death ramp), not raw variety. Add new dungeon biomes as new seed-regions post-launch so existing runs are never invalidated.
2. Guild dispatch = frigate expeditions: timed missions, party composition must cover all encounter types, failure costs repairs, success returns death-shop currency + resources, idle units trickle income.
3. Town = settlement loop: 3–5 legible stats, buildings with C–S-style upgrade classes, periodic member decisions with real tradeoffs, timed claimable payout — idle income that feels earned.
4. Deterministic milestone tracks: pay immediately per milestone and exclusively per track completion, so even failed runs bank visible progress — Leviathan proves this works inside a death-reset loop.

Sources: NMS fandom wiki, Hello Games sources.

## 4. Demeo / Demeo x D&D: Battlemarked

**Important correction:** Demeo has no separate "roguelike mode." It's a series of co-op campaign runs (3 floors, boss on floor 3) with a full reset between adventures — cards, gold, and health all wipe; what carries forward is account XP unlocking cosmetics only. Battlemarked (Nov 20, 2025) adds persistent character progression across campaigns.

**Card draft / draw economy (the standout system).** No per-turn deck draw. A shared Card Meter fills as you deal damage and defeat monsters; at 100 you gain a random Hero card (class-unique). Universal cards (anyone can use) come only from treasure chests or the merchant — never from the meter. Two cleanly separated acquisition channels: fighting earns Hero cards, exploring earns Universal cards. Unwanted cards are discarded into the meter — dead cards become fuel. Hand limit 10; overflow is silently lost.

**Within-run power curve.** Heroes are fragile and gain no HP between floors — the power curve comes entirely from accumulated cards, potions, and stat-buff purchases. The between-floor merchant sells random cards, stat buffs, potions, and card upgrades for per-run gold that resets per adventure.

**Design takeaways for Abysmal**
1. Split loot into "earned by fighting" vs. "earned by exploring" (Hero/Universal split). The death shop could sell combat-derived unlocks alongside exploration-derived consumables — two parallel optimization levers.
2. Convert trash into progress (discard→meter mechanic). Salvage duplicate/weak drops into Luck-skill fuel or death-shop currency — critical for an idle game where loot volume is high.
3. Cap active buffs, make the cap visible, and auto-convert overflow rather than silently deleting it (Demeo silently burns over-limit cards and players resent it).
4. Run a cosmetics-only prestige track alongside the power track: guild banners, town decorations — prestige that never touches balance. And make sure the +5%/run monster scaling outpaces what the death shop can buy at the margin to keep late runs tense.

Sources: Demeo wiki, GamingTrend, Road to VR, RPG Site. Honest unknowns: exact merchant price tables and Battlemarked hub gold-spend targets aren't documented in available sources.

## 5. Diablo 3

**Rarity / drop structure.** White → Blue → Yellow → Legendary → Ancient Legendary → Primal Ancient (gated behind a solo GR70 clear). Sets with 2/4/6-piece bonuses. The post-2.0 formula: "fewer, better drops" + smart loot (tunes affix rolls to the class playing; ~85% smart ratio is community-reported).

**Kanai's Cube — three recipe families (the big design mine).**
- Extract Legendary Powers: destroys a legendary, banks its special power at maximum roll, account-wide. Equip 3 extracted powers at once without wearing the items — separating power from gear. Every duplicate becomes progress.
- Convert / Upgrade: turn a level-70 rare into a random legendary of the same item type (type-targeted gambling); fully re-roll an existing legendary; convert a set piece into another random piece of the same set — pity-adjacent set completion.
- Material / Gem transforms: gem color conversion, salvage-material rebalancing, and Caldesann's Despair — consume a leveled Legendary Gem to add permanent core stats to an Ancient/Primal item.

**Rifts & Greater Rifts.** Nephalem Rifts: 10–15 min randomized dungeons with a built-in legendary bonus. Greater Rifts (1–150): infinitely-scaling endgame — 15-minute timed run, progress bar from kills, Guardian at the end. No loot mid-run — everything drops from the Guardian, decoupling pickup from speed. Fast clears unlock +1/+2/+3 tiers (clear-speed gating).

**Kadala (targeted gambling) & Legendary Gems (deterministic track).** Blood Shards buy random items in a chosen armor slot — slot-targeting that feels fair even at bad rates. Legendary gems are guaranteed collection-complete; gems convert into gear via Caldesann augments. Every RNG track paired with a deterministic one.

**Seasons.** 9-chapter Season Journey; completing Chapters II–IV gives Haedrig's Gift (a full 6-piece class set) — an onboarding accelerator making fresh starts immediately rewarding.

**Design takeaways for Abysmal**
1. One "Cube"-style converter beats ten drop-rate tweaks — every bad drop is a resource (powers, re-rolls, augments). Let the death shop consume run loot as currency/extractable powers so a bad run is never zero progress.
2. Pair every RNG track with a deterministic one — the Luck skill + death shop can be the deterministic pity track (Kadala-style slot-targeting feels fair even at bad rates).
3. Reward the boss, not the trash — GRs moved all loot to the Guardian: one satisfying moment. Ideal for idle: bundle run rewards into the death/guardian event; simpler on Android too.
4. Gate on clear-speed, not raw numbers — D3's +1/+2/+3 tier unlocks reward efficiency. For the per-death ramp: let fast runs unlock disproportionately bigger ramp jumps.

Sources: Maxroll, Icy Veins, Diablo Wiki, Blizzard forums.

## 6. Diablo 4 (post-"Loot Reborn," Season 4 → current Season 15)

**Itemization.** Drops reduced in volume, each more valuable; affix counts cut, each stronger. Ancestral is the endgame tier (≥1 Greater Affix, Torment tiers). Greater Affixes: 1.5× max roll, Ancestral-only; enchanting one away destroys it — drop-only chase.

**Tempering.** Manuals learned permanently into the Codex; adds 1–2 random affixes at the blacksmith; 5 re-roll charges per item, no reset = "bricking" is real and notorious.

**Masterworking.** 12 ranks, +5% all affixes per rank; no failure chance; reset-to-zero keeps no refund; roughly ~17M gold + hundreds of mats to max one slot (community-tabulated, season-dependent).

**Codex of Power vs. Minecraft Dungeons II's enchantment library.** D4's Codex is salvage-driven: best-roll-wins ranks, per-imprint gold cost, one aspect per item. D2's library is world-pickup books: discrete enchantment books found in the world, enchantments level up independently, freely movable between gear, and the bookshelf itself levels via Echo Shards. Verdict for Abysmal: D2's model is far closer to what an idle death-shop progression wants — the library as a persistent, upgradeable entity rather than a salvage ledger.

**Pity / deterministic.** Resplendent Sparks (salvage spare mythics) craft mythics: 2 sparks random / 2+runs targeted / 5 sparks keep-everything. Targeted farming via Helltide slot chests, Whisper caches, obol gambling, boss-summoning loot tables.

**Design takeaways for Abysmal**
1. Luck-as-bad-luck-protection: formalize the Luck skill as the visible pity meter — every dry run visibly fills it, and it spends in the death shop. D4's spark system is the template.
2. Guaranteed-perfect library entries feeding the death shop: like D2's bookshelf leveling, let the shop's "library" itself be upgradeable — persistent progression that never dies with a run.
3. Capped bricking without permanent destruction: cap the cost of failure (a run's loot, a shop currency chunk), never the item — bricking an item permanently is anti-idle.
4. Greater-Affix-style "drop-only chase" modifiers + boss-targeted tables: keep the top modifiers un-buyable and let boss selection target specific loot families, feeding the per-death monster ramp design.

Sources: Maxroll, Icy Veins, Wowhead D4, Blizzard sources. Season-specific numbers are community-tabulated and flagged.

## IP hygiene note (James's "don't step on anybody's toes" check)

Mechanics themselves are the safe part — game systems (drop tables, pity counters, upgrade tracks) are standard industry practice. The danger zone is names, lore, flavor text, art, and UI copy. Practical rules:

- Steal the system, rename everything. "Ring of Wealth," "Kanai's Cube," "Great Vault," "Haedrig's Gift," "Blood Shards," "Resplendent Sparks," "Card Meter" — none of these names go into Abysmal.
- Write original flavor text and lore. No paraphrasing of quest text, item descriptions, or named characters.
- Don't copy UI layouts or iconography wholesale — inspiration is fine, pixel-level imitation isn't.
- Practical guidance, not legal advice — before any commercial release, a proper trademark search on the title and key terms is worth doing. ("Abysmal" showed no exact Steam conflict as of Oct 7, 2026, but "Abysmal Gateway" exists — revisit before commercial release.)

## Cross-game synthesis: the 5 mechanics most worth stealing for Abysmal

1. **The Converter (D3's Kanai's Cube / D2's Enchantsmith).** One death-shop sink that turns every bad drop into progress: extract powers into a persistent library, re-roll, convert item types. A bad run is never zero progress. Single highest-value mechanic in the survey.
2. **Luck as the deterministic shadow (OSRS transparency + D4 sparks + WoW Catalyst + D3 Kadala).** The Luck skill feeds the death shop where salvaged loot becomes currency for slot-targeted or pity-tracked rewards — and the game publishes exactly what Luck modifies.
3. **Layered independent lotteries + broadcast wins (OSRS).** Main loot + tertiary "curios" + Luck-modified global lottery + epochal chase uniques per delve, with a town-hall trophy display and a rare-drop announcement moment.
4. **Guild dispatch as frigate expeditions (NMS).** Timed guild missions with a composition puzzle, failure costing repairs, success returning death-shop currency + town resources, idle units trickling income. The town/guild economy loop, ready-made.
5. **Bundle rewards into the run-end event (D3 Greater Rifts) + convert trash to progress (Demeo).** One satisfying death/guardian payout (optionally choose-1-of-3, the WoW Vault pattern), every duplicate auto-salvaging into Luck fuel.

Honorable mention: D2's unique-as-rarity-roll and rarity power offsets (from the earlier Minecraft Dungeons research) pair beautifully with #3.
