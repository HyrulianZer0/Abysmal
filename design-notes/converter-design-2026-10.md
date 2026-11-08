# The Converter — Design Paper for Abysmal
*Written Oct 8, 2026 for James's morning reference. Companion to the loot research series (loot-drop-progression-research-2026-10.md, borderlands-loot-research-2026-10.md, minecraft-dungeons-loot-research-2026-10.md).*

**The one-sentence pitch:** a death-shop machine that eats every bad, duplicate, or weak drop from a run and converts it into permanent, account-wide power — extracting signature powers into a persistent library (Diablo 3 Kanai's Cube lineage), re-rolling parts on beloved gear (D3 reforge / Kadala lineage), and augmenting gear with permanent stats (Caldesann lineage). James's standing order: **be generous to the player.** A bad run is never zero progress.

## 1. Lineage and IP hygiene (steal the system, rename everything)

This machine's DNA is fully admitted: D3's Kanai's Cube (Extract / Convert / Material families), D4's Codex-vs-D2-library lesson (the extraction library must be a persistent, upgradeable collection — never a salvage ledger), Demeo's discard→meter trash-to-progress, and WoW's Midnight currency lesson (one currency per tier — Valorstones were deleted for a reason).

Per James's IP rules: **nothing from Blizzard goes in the name, lore, or flavor text.** No "Cube," no "Kanai," no "Blood Shards," no "Caldesann." The design below uses original names only (machine name is left open for James to pick — see §11), original flavor, original UI copy. Systems themselves are standard industry practice; the words are ours.

## 2. The machine: what it is

A permanent installation in the **death shop**, unlocked the first time the player dies (run 1 — day-one feature, no gating). It is the player's trash compactor and power refinery in one. Flavor direction: the Abyss doesn't just kill you — it *digests* what you brought, and something useful survives digestion. Proposed flavor line (James can rewrite): *"The deep remembers every blade. Feed it, and it remembers yours."*

**Where it lives (UI):** the death shop gets a dedicated machine panel with five tabs — **[Feed] [Extract] [Reforge] [Augment] [Library]** — rather than burying it in the shop's existing tabs. Rationale: the machine is a ritual, not a transaction. The death moment should flow: run ends → death summary → "Feed the Machine" bulk action → tabs open for spending. One tap from the death screen to the machine; zero inventory fiddling on a phone (the Demeo overflow lesson: auto-convert, don't silently delete).

## 3. What it eats (which items qualify)

Run loot only — the machine never touches equipped gear, locked/favorited gear, or town-stashed keepsakes without an explicit tap-and-hold confirm on the specific item. The hard rules:

- **Feedable by default:** any weapon/armor from the run's loot haul that is (a) a duplicate of equipped or banked gear, (b) below the player's current equipped power in its slot, or (c) Common/Uncommon with no signature behavior. The **Feed tab** pre-selects everything matching these rules into a bulk pile, shows the Shard total before confirming, and the player taps once.
- **Never feedable without deliberate opt-in:** equipped items, locked items (lock = 1-tap star icon on any item card), anything at or above equipped power in its slot, and any item with an un-extracted signature behavior (the machine warns: "This blade has a power you haven't extracted yet — extract first?" and routes you to the Extract tab).
- **The anti-idle rule (cap the cost of failure):** feeding costs a run's loot, never the item's *potential*. Extracting destroys the source item — fine, because the library keeps the power at max roll forever. Reforge never consumes the item itself (only Shard costs). Augments never downgrade and never destroy the gear. **No function of this machine can permanently brick, delete, or reduce a beloved item.** (D4's tempering "bricking" is explicitly rejected here — bricking is anti-idle.)
- **No zero-value items:** every fed item produces Shards, even a plain Common. The worst drop in the game is worth *something*. This is the core generosity guarantee.

### The single currency: Shards

Feeding items yields **Abyssal Shards** (placeholder name — James picks), the machine's one spend currency. Every function below costs Shards only — never Shards + gold, never Shards + a second salvage token. This is the WoW lesson honored verbatim: **one currency per tier, one currency per system.** Gold stays the town/guild economy currency (guild hall stages, town buildings, blacksmith catch-up); it never enters this machine. One currency, zero bottlenecks, readable at a glance.

Tuning starting point (labeled as such — these are dials, not gospel): Common = 10 Shards, Uncommon = 25, Rare = 60, Epic = 150, Legendary = 400. Duplicate-of-extracted-power items get a ×2 "echo" bonus so duplicates of the *same* signature behavior are exciting, not sad (every duplicate becomes progress — the D3 takeaway).

## 4. Function 1 — EXTRACT (destroy the item, keep the power)

**Mechanics:** any item with a **signature behavior** (Epic+ per the Borderlands rarity-gates-parts model: Charm slot at Rare, signature behavior at Legendary — the proposal carries that forward) can be fed to the Extract tab. The item is destroyed; its signature power is banked into the **account-wide power library at its maximum roll**, forever, regardless of the source item's rolled quality. This is the D3 Extract rule: the library always stores the best possible version, so a garbage Legendary with a great power is a *jackpot*, not trash.

**Loadout:** the player equips up to **3 extracted powers at once** (D3's number — kept because it's readable and phone-UI-friendly: three slots, no page). Powers function without wearing the source item — this is the "separate power from gear" principle, and it's the machine's single most important economy move: players stop agonizing over whether to wear the item or save it, because keeping and wearing are the same thing.

**Generosity details:**
- First extraction of a given power is always the announcement moment (rare-drop announcement pattern from the OSRS research — town-hall trophy display: "The deep has learned [power name]").
- Duplicates after the first still pay the ×2 echo Shard bonus — the library entry doesn't improve (already max roll), but the *feeding* is still progress.
- Extracting is free beyond the item itself. The destruction is the cost; the game never charges Shards to extract. Punishing the player for feeding the machine would invert the whole design.

## 5. Function 2 — REFORGE (targeted gambling, no bricking)

Two modes, both Shard-priced:

**a) Re-roll (D3 reforge lineage).** Pick a weapon/armor, spend Shards, and re-roll its parts/stats within its rarity structure (forge mark stays — identity is permanent; blade/hilt/guard/charm re-roll). Cost scales with the item's tier but **caps** — a stated Shard ceiling per item so late-game players can't be bled dry. Every re-roll that doesn't improve the item feeds a **visible pity meter**: after N unsuccessful rolls (tuning start: 8), the next roll is guaranteed at least one part-grade improvement. The pity meter is shown on the item card — published mechanics, per the OSRS transparency takeaway. Luck stays the player's friend: the Luck skill nudges the pity threshold down slightly (each 5 points of Luck = −1 to the guarantee count, floor 4), and the game *says so* on the card.

**b) Convert (Kadala / set-conversion lineage).** Feed 5 unwanted items of one family (e.g., 5 blades) → receive 1 random item of a **chosen target slot** at the average tier of the inputs, minus one rung. The minus-one-rung tax is the house edge, stated up front; the target-slot choice is the generosity (Kadala's lesson: slot-targeting feels fair even at bad rates). Converted items are eligible for Extract if they roll a signature behavior — conversion is an Extract-library feeder, not a dead end.

**Anti-bricking rule (restated for the record):** reforge consumes Shards only. It cannot destroy, downgrade, lock, or otherwise damage the item. The worst outcome of a reforge is a bad roll plus visible pity progress. Failure's cost is capped at Shards — never the item.

## 6. Function 3 — AUGMENT (consume resources, add permanent stats)

**Mechanics (Caldesann lineage):** spend Shards to fuse a permanent stat bonus into a weapon or armor piece. The bonus scales with the gear's tier and the amount spent — a sliding control, not a fixed recipe: the player picks a stat (damage, crit, block, etc., matching the gear slot's allowed list) and pushes a slider up to what they can afford. **One currency per tier** honored again: the only cost is Shards, scaled by gear tier (deeper gear costs more, deeper runs produce more — the per-death ramp and the augment economy climb together).

**Generosity rules specific to augments:**
- Augments are **permanent and removable** — removing an augment refunds 50% of the Shards spent (the D4 masterwork "reset to zero, no refund" outcome is explicitly rejected; resets in an idle game must never feel like deletion).
- Augments never fail. No failure chance on any augment tier (the 12-rank D4 masterwork has no failure chance either — and even D4's critics conceded that was the right call).
- Augments can only target gear the player has **locked** (a beloved item) or currently equipped — the machine refuses to augment unfavorited junk. This is deliberate friction: augments are a commitment mechanic, and the design should make the commitment legible ("the deep only remembers blades worth remembering").

## 7. Tie-in: the extracted-power library vs. the planned enchantment library

These are **two sibling systems, one shared home** (the death shop), and they must not collapse into each other:

- **Extracted powers (this machine):** signature behaviors ripped from items. Loadout-style — up to 3 active, function without the item, always at max roll. Think of them as the player's *build identity*.
- **Enchantment library (planned, Minecraft Dungeons II lineage):** enchantments found as books/pickups, living in a persistent, upgradeable library, **socketed into gear** — the Rune-charm slot on weapons is the socket per the Borderlands research. Think of them as the player's *gear customization*.

**Cross-feed (the elegant part):** extracting a signature power also grants a small amount of **enchantment-library XP** (the D2 bookshelf-levels-via-use mechanic). And Shards — the machine's single currency — can also be spent in the planned library (buying enchantment books, funding bookshelf upgrades). Result: one salvage economy, two spend sinks, no bottleneck, and the two systems visibly reinforce each other instead of competing. A player who only cares about powers still feeds the library; a player who only cares about enchantments still uses the machine.

**Forge-house Charm/Rune socket relationship:** the Rune-charm variant (Epic+) is the physical socket for library enchantments; extracted powers are slotless (the 3-power loadout). A weapon can carry both: its Rune charm holds an enchantment from the library *and* the player independently runs 3 extracted powers. No conflict, no double-dipping rules needed — they're different layers.

## 8. Worked example: one 1→10 run's junk becomes permanent power

*Tuning numbers are starting points, flagged where speculative. Assumes the auto-delve idle run that James has greenlit: the player idles through depths 1–10, dies at the floor-10 guardian, lands in the death shop.*

**The haul (a deliberately mediocre run):** 9 weapons (5 Common, 3 Uncommon, 1 Rare), 6 armor pieces (4 Common, 2 Uncommon), 1 Epic blade with a signature behavior the player hasn't extracted yet, plus the equipped set (untouchable). Luck is mid-level; no Legendary. By old-roguelike standards: vendor trash.

**Step 1 — Feed.** The player opens the machine. The Feed tab has pre-selected the 13 Common/Uncommon items (the Epic is flagged "unextracted power — extract first?"). Everything else junk-grade. Tap once: **13 items → ~190 Shards** (5×10 + 3×25 + 4×10 + 2×25 = 190, plus a small Luck-tinged bonus — say 12 Shards — because Luck stays the player's friend and even feeding feels lucky). The town-hall feed reads: "The deep took 13 offerings. +202 Shards."

**Step 2 — Extract.** The Epic blade's signature behavior — say a lifesteal-on-kill forge-house power — goes into the Extract tab. Blade destroyed; the power banks into the library **at max roll**, account-wide, forever. First-extraction announcement plays. The player slots it as one of their 3 active powers. Run 2 opens with permanent lifesteal-on-kill they didn't have in run 1.

**Step 3 — Convert.** Five leftover-feel items: the player had 5 Uncommon blades across this run and the previous one. Feed them into Convert, target slot = boots. Out comes a Rare pair of boots at the input tier minus one rung — wearable immediately, and if it rolls a signature behavior later, it's Extract fodder.

**Step 4 — Reforge.** The player's favorite Rare cleaver gets 3 re-roll attempts at 25 Shards each (75 total). Roll 2 lands a better blade part; roll 3 doesn't — pity meter now shows 1/8 toward the guaranteed improvement. Nothing lost, nothing bricked.

**Step 5 — Augment.** Remaining Shards (~130) go into the locked Epic blade from last week: +crit pushed partway up the slider. Permanent, removable, refundable at 50%.

**Net of one bad run:** 1 permanent max-roll power in the account-wide library, 1 new Rare item in a chosen slot, 1 improved favorite weapon + visible pity progress, 1 partially-augmented beloved item, 1 library-XP tick toward the enchantment bookshelf. **Zero progress was possible before this machine; now the worst run in the game still visibly moves five needles.** That is the generosity target, and it's the number James should hold this design to.

## 9. Generosity tuning — the rules, not just the numbers

1. **Every bad drop is progress.** No zero-value items; the floor is Shards.
2. **Extract is always max roll.** A garbage item with a great power is a jackpot.
3. **Pity is visible and published.** Reforge pity meter on the card; Luck's effect on it stated in-game.
4. **Failure costs Shards, never items.** No bricking, no downgrades, no permanent destruction of anything beloved.
5. **Conversion has a stated house edge** (minus one rung) and a stated generosity (choose the slot). Both visible before confirming.
6. **Augment refunds 50% on removal.** Resets are re-allocation, not deletion.
7. **Nothing paywalled.** All three functions use Shards and items only — never a premium currency, never a timer-skip, never an ad-gated roll. (James's rule: no paywalled idle mechanics.)
8. **"Easy, though not too easy."** The machine is generous with *progress*, not with *power spikes*: it converts trash into steady, legible gains, never into a Legendary faucet. The chase (top-tier signatures, drop-only modifiers per the D4 research) stays drop-only. The machine makes every run worth it; it does not replace the hunt.

## 10. Honest caveats

- **Shard economy balance is untested.** The Common=10 / Uncommon=25 / Rare=60 / Epic=150 / Legendary=400 starting ladder and all costs are first-pass dials. They need a simulation pass against the actual idle loot volumes once auto-delve rates are locked — if a run produces 200 Commons, the ladder is wrong. Flag for the balancing pass, not for argument now.
- **The enchantment library doesn't exist yet.** §7's cross-feed assumes the D2-style library design from the research; if that design changes (e.g., no bookshelf leveling), the Extract→library-XP link needs re-deciding.
- **Three-power loadout is inherited, not derived.** D3's 3-at-once number is kept for readability; there's no Abysmal-specific analysis proving 3 > 2 or 4. It's a dial.
- **Minus-one-rung conversion tax** is a guess at the right house edge. Could be minus-zero with a Shard fee instead — needs a feel test.
- **Staged CC0 assets only.** The machine's panel, icons, and any "digestion" animation must come from the staged CC0 asset pool — no AI-generated assets, ever (James's rule). If the pool lacks a good "maw/crucible" visual, the UI ships as clean iconography first; flavor visuals wait for asset availability.
- **Credits use "Aethelwarden Solas"** — real name stays off everything, including any flavor text credits.

## 11. Design takeaways

1. **One machine, three verbs: Extract / Reforge / Augment.** The whole trash-to-progress economy lives in one place with one currency. Players learn it once; it pays off forever.
2. **Extract is the headline.** Separating power from gear (D3's great insight) is what makes duplicates exciting and kills the "wear it or lose it" anxiety. Everything else is support.
3. **One currency per system.** Shards in, Shards out. Gold never touches the machine. (The Valorstone lesson, honored.)
4. **Publish the pity.** Visible reforge meters and stated Luck effects — transparency is the generosity multiplier.
5. **Augments are commitment, reforge is play.** The machine deliberately makes augmenting slightly frictive (lock required) and reforging frictionless — matching the psychology: tinker freely, commit deliberately.
6. **Two libraries, one home.** Extracted powers (loadout) and the planned enchantment library (sockets) share the death shop and the Shard economy without overlapping mechanically. Build both, let them cross-feed, keep them distinct.
7. **The worst run still moves five needles.** That's the bar. If a tuning pass ever makes a bad run feel like zero progress, the tuning is wrong — not the design.

## 12. Open questions for James

1. **Machine name.** "Converter" is the design-doc word, not the in-game word (and "Cube" is off the table for IP hygiene). Candidates: **The Gullet**, **The Undercrucible**, **The Charnel Engine**, **The Foundry Below**, **The Maw**. Pick one, or give a direction and I'll generate more.
2. **Shard name.** "Abyssal Shards" is a placeholder. Alternatives: **Gloomshards**, **Deepglass**, **Dross** (fun — the machine eats dross and makes it valuable). Your call.
3. **Extract loadout size.** 3 powers at once is inherited from D3. Keep 3, or is there an Abysmal-native number (tied to, say, the 8 charms or the 3 talismans)?
4. **Extract scope.** Should *every* signature behavior be extractable, or should the very top tier (drop-only chase modifiers, per the D4 research) stay un-extractable to protect the hunt? Generosity says extract everything; chase-protection says hold the top back.
5. **Conversion house edge.** Minus-one-rung on the output, or same-tier output with a flat Shard fee? Which feels better to you?
6. **Augment targets.** Restrict augments to locked/equipped gear only (commitment friction, §6), or open them to anything? The friction is deliberate — but is it *fun* friction?
7. **Reforge identity lock.** Proposal keeps the forge mark permanent (identity never re-rolls). Should a full re-roll of even the forge mark ever be possible — a "re-forge the soul of the blade" expensive option?
8. **Enchantment library cross-feed.** Extract granting library-XP assumes the D2-style bookshelf design. If the library design shifts, what's the cross-feed instead — or should the two systems stay fully separate?
9. **Death-shop panel vs. standalone.** Proposal puts the machine as a 5-tab panel inside the death shop. Alternative: a standalone machine screen with its own art moment. Which reads better on your phone?
10. **Luck's exact role.** Proposal: Luck nudges reforge pity (−1 per 5 Luck, floor 4) plus a small Shard bonus on feeding. Enough, or should Luck touch conversion odds too? (Luck stays the player's friend either way — this is about *how* friendly.)

---
*Sources: Diablo 3 — Maxroll, Icy Veins, Diablo Wiki, Blizzard forums (Kanai's Cube recipe families, Kadala, Legendary Gems/Caldesann's Despair, Greater Rifts, Seasons); Diablo 4 — Maxroll, Icy Veins, Wowhead D4, Blizzard sources (Loot Reborn, tempering/masterworking, Codex of Power, Resplendent Sparks); WoW Midnight — Wowhead, Icy Veins (Valorstone deletion, upgrade tracks, Great Vault, Catalyst); Minecraft Dungeons II — metabot.gg, tech-insider.org, beebom.com (enchantment library, Enchantsmith/Blacksmith, Echo Shards); OSRS — OSRS wiki, RuneLite Drop Rate Project (layered lotteries, transparency); Demeo — Demeo wiki, GamingTrend (discard→meter); No Man's Sky — NMS fandom (frigate expeditions as dispatch model). All mechanics summarized in original wording; exact numbers flagged as community-reported where applicable. Practical IP guidance, not legal advice.*

---

## Addendum 2026-10-10 — Undercrucible reframe

**The name is locked: the Undercrucible.** James picked it from the candidates in §12 on Oct 9, 2026. The design-doc word "Converter" is retired in-world; "Cube" was never on the table (IP hygiene).

**The role is reframed: the machine converts MATERIALS to strengthen EXISTING items.** This is not a rewrite of the paper — the three verbs, the one-currency economy, and all generosity tuning below stand. It is a reframe of what the verbs *mean*, recorded here so the paper and the Oct 10 decision record (`design-decisions-2026-10-10.md` §3–§4) stay in sync:

- **Extract** = pull material essence from junk. The machine digests bad drops and what survives digestion is *essence* — the usable material the dark couldn't keep. (The D3-extract lineage in §4 — destroy the item, keep the power at max roll in the account-wide library — is unchanged; "essence" is now also the machine's material output, the feedstock for the other two verbs.)
- **Reforge / Augment** = apply materials to strengthen *existing* gear. Reforge re-rolls parts on a beloved item; Augment fuses permanent stats into it. Both consume essence/materials — never the item, never gold.

**The split (new, Oct 10).** The blacksmith and the Undercrucible are now two clean halves of one economy: the **blacksmith** eats **gold** and creates **NEW gear** (fills empty slots, targets specific types — the deterministic base); the **Undercrucible** eats **materials** and strengthens **EXISTING gear** (the enhancement pass). Core loop: **craft base → enhance.** The §3 "one currency per tier" rule is preserved and sharpened: the machine's currency is essence/materials, full stop — gold never enters the machine, and the blacksmith never touches materials. One mouth eats gold, the other eats junk. They never compete for the same input.

**KEPT — all generosity tuning (§9) and the standing bar.** No zero-value items; Extract always max roll; visible published pity; failure costs materials, never items (no bricking, ever); stated house edges; augments removable with 50% refund; nothing paywalled; "easy, though not too easy." And the bar James holds this design to: **the worst run still moves five needles.**

**Interaction with the new material economy.** The Oct 10 breadcrumb revision adds Harlan Slate's **Well Stocked** buff (+material yield, `npc-story-beats-2026-10.md` addendum) — the player now digs more from every vein, chest, and crack. That buff feeds this machine directly: more material yield → more essence → more reforge/augment. The breadcrumb trail's new depth-4 resident is, mechanically, the Undercrucible's quartermaster.

**Honest caveat (unchanged from §10).** The essence economy is still untested against real idle loot volumes — the Shard-ladder-vs-loot-volume flag now applies to essence too. When the loot pipeline is generating real junk-per-run numbers, the essence ladder gets its simulation pass.

---

*Addendum written Oct 10, 2026 — directed by James Greenlee ("Aethelwarden Solas"). Original names only; staged CC0 assets; no AI-generated assets, per project rules.*
