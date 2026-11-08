# Guild Management Layer — Design Reference for Abysmal
*Written Oct 8, 2026. For a 2.5D first-person idle dungeon crawler roguelike (Godot 4.7, Android-first): idle auto-delving; death → death shop (14 skills, 8 charms); per-death monster ramp +2%/run capped +50%; guild hall 4-stage chain (tavern → guild → expanded guild → adventurers' guild HQ, gold + depth gates); town/overworld scaffolding exists; staged CC0 assets only — no AI-generated assets ever; credits use pseudonym "Aethelwarden Solas".*

This paper designs **one coherent guild-management loop** from James's three standing decisions:

- **(a)** The guild UI is a **quest board**: manage requests, pay adventurers for completed work, and a trusted merchant sells supplies/gear that keep adventurers going.
- **(b)** The **blacksmith** lets the player craft **any** weapon or armor for gold.
- **(c)** **Death returns the player to town** once the guild hall is established.

It builds directly on the cross-game synthesis from `loot-drop-progression-research-2026-10.md` — takeaway #4, **"Guild dispatch as frigate expeditions"** — and on the parts/rarity model from `borderlands-loot-research-2026-10.md`. Mechanics are summarized in original wording; all tuning numbers in this paper are first-pass proposals, not tested values, and are flagged as such.

---

## Design intent: what the guild layer is FOR

The core loop of Abysmal is: delve → die → death shop → delve deeper. The guild layer answers the question *"what is the player doing with their town while they're not dying?"* It is the **long game between runs**: a slow, persistent economy where gold, adventurers, gear, and town growth feed each other, running partly on real time so progress accrues between sessions (the idle promise). It must be:

- **Readable on a phone** — one board, one roster, one merchant, one smith. No nested menus deeper than two taps.
- **"Easy, though not too easy"** (James's rule) — the composition puzzle and wage economy provide friction; the systems never punish the player for leaving the app.
- **A gold sink with visible returns** — wages, healing, crafting, and supplies drain gold so the economy breathes, but every drain is traceable to something the player chose.

---

# PART 1 — THE QUEST BOARD

## 1.1 Who posts requests?

Three request sources, unlocked as the guild hall stages up. Each source has its own flavor, difficulty band, and payout character — so the board always tells a story about where the guild stands in the world.

| Source | Unlock | Flavor | Payout character |
|---|---|---|---|
| **Townsfolk notices** | Stage 1 (tavern) | Pin-board scraps from the home town: a cellar rat-thing infestation, an escort for a night market run, a lost charm in the shallow abyss | Small, frequent, gold-poor but loyalty-rich; builds town Prosperity |
| **Overworld towns** | Stage 2 (guild), per-town | Sealed missives from named towns on the overworld map (all original names): caravan guard work, den-clearing, relic recovery | Better gold, Renown with that town, occasional material rewards |
| **Guild contracts** | Stage 3 (expanded) | High-threat postings the guild itself solicits: abyss-breach closures, elite-den hunts | Big gold, forge-house unlock progress, rare-part rewards |

**Design note:** townsfolk notices are deliberately mundane. The contrast between "Mrs. Halden's missing pie tin (it was in an abyss den, somehow)" and "close the breach at Greywatch" is what makes the guild feel like a real place. Original names and flavor text only — no borrowed IP.

## 1.2 The request lifecycle

Every request moves through the same legible pipeline, shown as a card on the board:

1. **Posted.** The board holds a fixed number of slots (start: 3; +1 per guild hall stage). New requests arrive on a timer (e.g., one slot refills every 4 real-time hours) and on each player death — death refreshes the board, because every run's end is a natural "check the hall" beat.
2. **Claimed.** The player assigns an adventurer, assigns a dispatch party (see Part 2), or marks it **"take it myself."**
3. **Underway.** Dispatched parties run on a real-time timer. "Take it myself" quests become **delve objectives**: the next idle run that reaches the requirement (depth, den clear, kill count) auto-completes it at run end. No active play required — the idle loop does the work, and the quest resolves inside the familiar death/run-summary moment.
4. **Resolved.** Payout: quest fee to the player, wage paid to the adventurer (their cut), loyalty/experience to the adventurer, Renown/Prosperity to the town.
5. **Failed.** A dispatch that fails (bad composition, threat too high) pays no fee. The adventurer still gets a partial wage — their time wasn't free — and may be injured (Part 2.4).
6. **Expired.** Unclaimed requests expire after ~24–48 hours and are replaced. Expiry is soft: a small town-mood dip, no punishment. (Anti-idle rule: the board must never make a returning player feel punished for sleeping.)

**Personal quests vs. delegation.** Taking a quest personally should always be *slightly* more lucrative than delegating (no wage to pay) but slower (it resolves at the next run end, and hard quests may take several runs). Delegation is faster gold, thinner margins. That's the core economic choice of the board.

## 1.3 Wages — the tuning philosophy

Wages are the guild layer's heartbeat: the recurring gold sink that makes the economy breathe. Proposed first-pass rules:

- **Wage = f(adventurer level, quest tier).** Roughly: wage ≈ 15–25% of the quest's fee at the same tier, rising with adventurer level. The player nets positive on every successful quest — this is a game, not a job simulator.
- **The margin is the game.** Easy quests: fat margins (fee ≈ 4–5× wage) but small absolute numbers. Hard contracts: thin margins (fee ≈ 1.5–2× wage) with big absolute payouts — the *risk* is the wage plus injury costs, the *reward* is the spread.
- **Failed quests still cost wages** (partial, ~50%). This is the composition puzzle's teeth: sending an under-leveled Skirmisher solo into a breach-closure contract burns gold for nothing.
- **Loyalty (soft, not punitive).** Paying wages promptly and succeeding quests raises an adventurer's Loyalty; high Loyalty unlocks that adventurer being *offered* higher-tier quests (the board's best contracts preferentially surface for loyal, high-level adventurers). There is no rage-quitting, no strikes, no fired-by-algorithm. Abysmal is a cozy-competent fantasy; the friction is economic, never social-punitive.
- **Death refreshes, not resets.** Adventurer levels, loyalty, and the roster persist across player deaths — the guild is the *persistent* layer, the run is the *reset* layer. This is what makes death returning the player to town (decision c) feel like coming home instead of starting over.

**Honest caveat:** wage curves are the single most balance-sensitive dial in this paper. The numbers above are starting guesses; they need a spreadsheet pass against the idle gold-income curve before implementation. If wages outpace idle income, the board becomes a chore; if they're trivial, the economy has no teeth.

## 1.4 The trusted merchant

One NPC, one shop, always in the guild hall. The merchant is the board's support system — everything the merchant sells exists to keep adventurers (and the player) equipped and moving.

**What the merchant sells:**
- **Supplies** — bandages, rations, salves. These are the *consumable cost of failure*: healing injured adventurers (Part 2.4) costs supplies + gold. Supplies are cheap, stackable, and bought in bulk. (The NMS analog: frigate repair resources.)
- **Standard gear for adventurers** — deterministic, mid-tier weapons and armor, priced in gold. Deliberately capped: the merchant never sells Charm-slot items, never sells above the Epic-equivalent band, never sells anything with a forge-house signature behavior. The merchant is the floor, never the ceiling — the chase stays in drops and the blacksmith.
- **Charter papers (proposed)** — see Part 3.3: documents that unlock a forge house's patterns at the blacksmith. If implemented, these are the merchant's premium stock and the main gold sink after wages.

**What the merchant never sells:** chase items, Legendary-signature gear, death-shop currency, anything that would let gold skip the gameplay. Gold buys reliability; it never buys the lottery win.

**Stock behavior:** the merchant's stock refreshes on a real-time timer (e.g., daily), with selection weighted by guild hall stage and town Prosperity. Prices drift with Prosperity — a thriving town has better stock at slightly higher prices. The merchant also occasionally posts **acquisition requests** on the board ("bring me three cracked hilts" — i.e., salvage-grade parts), paying in supplies or a stock discount. That's the merchant feeding the board feeding the merchant: a closed micro-loop.

**Design takeaway for Part 1:** the quest board is a *margin game*. The player is always choosing between doing it themselves (slow, full fee), delegating (fast, thin margin, risk of failure costs), or letting it expire (no cost, no gain). Wages are the recurring sink; the merchant converts gold into reliability; loyalty gates the best work. Nothing here punishes absence.

---

# PART 2 — GUILD DISPATCH: NO MAN'S SKY FRIGATE EXPEDITIONS, TRANSLATED

## 2.1 The source mechanic, fully explained

No Man's Sky's frigate system (current as of the research in `loot-drop-progression-research-2026-10.md`, §3) works like this:

- The player owns a capital freighter and can recruit **up to 30 frigates** across **5 classes**: Combat, Exploration, Industrial, Trade, and Support. Each frigate has a class, a rank, and stats; frigates gain experience and rank up by completing expeditions.
- The player can send **up to 5 frigates at a time** on **expeditions**: missions with a difficulty rating and attribute demands (e.g., a mission might need high Combat and Exploration). Expeditions run on **real-time timers** — from tens of minutes to several hours — and resolve while the player does anything else, including while logged out.
- **Composition is the puzzle.** A fleet whose classes cover the mission's demands succeeds reliably. A mismatched or under-ranked fleet risks **damaged frigates**: damaged frigates must be repaired with gathered resources before they can fly again, and a badly damaged frigate on an active expedition can fail the whole mission.
- **Idle frigates trickle resources.** Frigates not on expedition, "landed" at the freighter, passively generate small amounts of resources over time — so the full roster is always doing *something*.
- Rewards scale with mission difficulty and fleet performance: resources, units (currency), nanites (tech currency), frigate upgrade modules, and occasionally new frigates. High-rank frigates unlock harder, richer expeditions.

The design genius: it's a **composition puzzle on a real-time clock** with **failure costing resources, not progress**, layered over a roster that is **always productive**. It never demands attention *now* — it rewards checking in *later*.

## 2.2 Translation: adventurer classes for Abysmal

Four original adventurer classes, each one combat verb (same legibility rule as the forge houses — learnable in seconds). All names, flavor, and lore are original to Abysmal.

| Class | Role | Quest demand it answers | Flavor sketch (original) |
|---|---|---|---|
| **Vanguard** | Front-line bulwark | Protection, escort, breach-holding — anything where someone has to stand in front | Oath-bound shieldbearers of the hall; they plant their boots and do not move |
| **Skirmisher** | Fast striker | Pursuit, scouting, time-sensitive strikes | Light-footed den-runners who treat the abyss like a racetrack |
| **Mender** | Healer and field medic | Any mission — reduces injury severity and recovery time across the party | Quiet hands; they measure success in who walks home |
| **Occultist** | Abyss-sense and crowd control | Abyss-touched zones, relic recovery, breach closures — some contracts *require* one | They listen to the deep places and the deep places answer back |

*(A possible fifth class — a **Chronicler**, who records expeditions and boosts reward quality — is parked as an open question for James. Four keeps the composition puzzle legible on a phone; five is the NMS-faithful number.)*

Adventurers have **levels** (gained from completed dispatches and quests), a **class**, and a **Loyalty** stat (Part 1.3). The roster is recruited through the guild hall — new applicants arrive as the hall stages up and as Renown grows, so the roster itself is a progression track. Starting roster: 2–3 adventurers at stage 1; up to ~10–12 at HQ stage. (Deliberately below NMS's 30 — a phone roster of 30 is management overhead, not fun.)

## 2.3 Dispatches: timed guild quests with a composition puzzle

A **dispatch** is a quest-board contract (or a dedicated dispatch list, UI TBD) that the player assigns to a party of adventurers — up to **4 per dispatch** (phone-legible; the party screen is four portraits, not a fleet manifest).

Each dispatch lists:
- **Recommended roles** — e.g., "Vanguard + Mender recommended; Occultist required (abyss-touched)."
- **Threat rating** — compared against the party's combined level. Under-leveled parties can attempt anything, but the failure/injury odds climb steeply.
- **Duration** — a real-time timer. Short hops: 30–60 min. Standard: 2–4 hours. Deep contracts: 8–12 hours (the overnight mission).

**Resolution:**
- **Balanced, level-appropriate party → success.** Returns gold (the fee minus wages auto-paid), town resources, Renown, and occasionally a material reward (a forge part, a charm blank, supplies).
- **Wrong composition or under-leveled → risk.** Outcomes on a spectrum: clean success → success with injuries → partial success (reduced payout, injuries) → failure (no fee, partial wages paid, injuries likely).
- **Injuries** are the failure cost (see 2.4). There is no permanent death for adventurers — losing a leveled roster member to one bad call would make players afraid to dispatch at all, which kills the system. Injuries cost time and gold; they never cost the adventurer.

**The composition puzzle, concretely:** a breach-closure contract demands Occultist + Vanguard, threat 5. The player has a level-6 Vanguard, a level-5 Occultist, a level-4 Mender, and a level-2 Skirmisher. Sending Vanguard + Occultist + Mender = safe, clean. Sending Skirmisher + Mender = the Skirmisher is fast but can't hold a breach; likely partial success with injuries. Sending all four = overkill, safe, but now those adventurers are locked for 6 hours instead of earning elsewhere. The puzzle is coverage vs. opportunity cost — exactly the NMS fleet-balancing decision, at phone scale.

## 2.4 Injuries, healing, and the merchant loop

Injured adventurers can't dispatch until healed. Healing costs **supplies + gold + real time** (e.g., a light injury: some bandages, 30 minutes; a heavy injury: salves, more gold, 4 hours). A **Mender in the party** reduces injury severity and recovery time — so the Mender is both a quest answer and insurance, which makes the class valuable even when no quest demands it.

This closes the merchant loop from Part 1.4: **dispatches consume supplies through injuries → supplies are bought from the merchant → merchant gold flows into town Prosperity → better board requests → more dispatches.** The player feels the loop as: "send party, party gets banged up, buy bandages, send them out again" — a rhythm, not a tax.

## 2.5 Idle adventurers trickle gold

Adventurers not on dispatch and not injured are **stationed at the hall** — sparring, mending gear, telling stories. Like NMS's landed frigates, they **trickle gold**: a small per-hour income per stationed adventurer, scaled by level, collected from the guild coffers.

Two guardrails (both anti-degenerate):
- Only a fixed number of **station slots** generate the trickle (start: 2; +1 per hall stage). A roster of 12 doesn't mean 12 incomes — it means choices about who works and who rests.
- The trickle is deliberately modest — pocket money, not a primary income. Its real purpose is emotional: the roster is never dead weight. Every adventurer is always *doing something*.

## 2.6 Real time or game time? And how do dispatches interact with delves?

**Dispatches run on real time.** This is non-negotiable for the design's purpose: dispatches are the *between-sessions* engine. The player sends a 4-hour contract at lunch, comes back after work to a resolved party, injured Vanguard, and a payout. The app does not need to be open. Durations cap at ~12 hours so an overnight dispatch resolves by morning — no infinite stacking, no "I was gone a week and won the game."

**Delves run on game time** (app-active / idle-with-app-open, per the existing idle auto-delve design). The two timelines are **independent**: a dispatch continues while the player delves, dies, shops, and delves again. They interact only at defined touchpoints:

- A dispatched adventurer **can't be assigned** to another quest until the dispatch resolves — roster contention is the strategy.
- **"Take it myself" quests** resolve through the player's own delves (Part 1.2) — this is the bridge between the two timelines.
- Dispatch returns can include **dive-relevant rewards**: a forge part for the blacksmith, a charm blank, supplies — things that make the *next* delve better. And delve loot can include **dispatch-relevant rewards**: salvage the Converter doesn't want becomes merchant fodder or giftable gear for adventurers.
- **Death doesn't touch dispatches.** The player dies, returns to town (decision c), and the dispatch board shows the party still out with 2 hours left. The guild persists; only runs reset. This is the emotional core of the whole layer: *the run ends, the guild endures.*

**Honest caveat:** real-time timers need an offline-progress implementation (timestamp math on app open, not a background service — Android battery rules make background timers hostile). Cap accrued dispatch time per session-check to prevent week-long-absence windfalls, and be transparent in-game about how it works.

---

# PART 3 — THE BLACKSMITH

## 3.1 "Craft any weapon or armor for gold" — the contract

James's decision is absolute: the blacksmith can make **any** weapon or armor. The design's job is to make that promise true without letting it eat the loot game. The resolution is the same one Diablo draws with Kanai's Cube and WoW draws with crafted gear: **crafting is the deterministic floor; drops are the lottery ceiling.** They coexist because they answer different questions:

- *"I need a reliable upgrade right now"* → blacksmith.
- *"I want the thing I can't plan for"* → drops.

**What the player chooses at the smith:** weapon or armor type, **forge house** (from unlocked houses), **blade/armor profile** (the parts-model equivalents: Cleaver/Duelist/Piercer/Crusher and armor parallels), and **rarity band** to craft at. What the player does *not* choose: the exact stat rolls within the band (narrow variance, ±10%), and — critically — **signature behaviors**.

## 3.2 The coexistence rules (crafted vs. drops)

Three hard rules keep the smith from killing the chase:

1. **The smith caps at Epic.** Crafted gear can roll all five part slots (Forge + Blade + Hilt + Guard + Charm, per the Borderlands parts model) up to Epic quality — but **Legendary signature behaviors are drop-only**. You can smith a perfect Epic Emberfall Cleaver; you cannot smith the thing that makes a Legendary *legendary*. The ceiling stays in the abyss.
2. **The smith caps at your depth.** Crafted power is gated to a few rungs **below** the player's deepest delve on the 39-rung ladder (proposed: deepest − 3 rungs). Loot always has headroom; the smith can never obsolete the next tier of drops. As you delve deeper, the smith's cap rises with you — the floor chases the ceiling, never catching it.
3. **Crafted gear can't be better than *lucky*.** Within its band, smith rolls are tight (±10%). A great drop in the same band beats a crafted piece. The smith sells certainty at the price of upside.

These three rules are publishable in-game, OSRS-transparency style: a little plaque over the forge that says what the smith can and can't do. Players trust systems whose limits are stated.

## 3.3 Cost formula (first-pass proposal)

Costs must scale with the exponential power curve without either trivializing gold or demanding grind. Proposed structure:

**Cost = Base × (rung index)^1.5 × parts factor × house factor**

- **Base:** a flat gold constant (tuning placeholder: ~50g), anchoring early-game crafts to pocket money.
- **(rung index)^1.5:** ties cost to the 39-rung ladder's power. The 1.5 exponent is deliberately *sub*-exponential — costs grow fast but slower than power, so crafting stays reachable as a catch-up tool. (If testing shows gold inflation outpaces this, raise to ^1.7; if crafting feels gated, lower to ^1.3. This exponent is the tuning dial.)
- **Parts factor:** 1 + 0.25 × (parts beyond Forge + Blade). Crafting a full 5-slot Epic costs meaningfully more than a plain Common blade — you're paying for the slots.
- **House factor:** 1.0 for the starting house, up to ~1.5 for late-unlock houses with stronger gimmicks. Better verbs cost more.

**Forge-house unlocks:** the smith starts knowing **one** house. Others are unlocked through play — proposed: each house unlocks via a guild contract chain on the quest board (tying Part 1 → Part 3), or via Renown with specific overworld towns, or as premium **charter papers** from the merchant (tying Part 1.4 → Part 3). The answer to "can the blacksmith make any house's gear?" is **yes — once the house is known**. Unknown houses are the smith's progression track.

## 3.4 Time gates: timed orders, not instant gratification

Crafting is **queued, not instant** — the smith is one person with one forge:

- Each order takes **real time** scaled by tier (proposed: 15 min for Common, up to 4 hours for Epic). The timer runs while the app is closed, like dispatches.
- **Queue slots** are the progression: 1 slot at start, +1 per guild hall stage (max 4). More slots = more parallel crafts = a real reason to upgrade the hall.
- **Rush fee:** any order can be completed instantly for **3× the craft cost** in gold. This is a pure gold sink for impatient moments, priced punitively enough that it's a choice, not a default.

Why timed instead of instant: instant crafting turns gold directly into power with no texture — it becomes a vending machine. Timed orders make the smith a *rhythm* ("queue the Mender's new guard before bed, it's ready at breakfast") and give the player a reason to check the hall between delves. It also paces gold-to-power conversion, which is the whole point of the coexistence rules.

## 3.5 Relation to the Converter

The Converter (death-shop machine turning bad loot into permanent progress — cross-game synthesis takeaway #1) and the blacksmith do not compete; they eat different things:

- **The Converter eats items.** Bad drops go in; extracted powers, re-rolls, library progress come out. It answers: *"this drop is useless to me — make it useful."*
- **The blacksmith eats gold.** Gold goes in; a chosen, deterministic item comes out. It answers: *"I know exactly what I want — make it."*

They meet in the middle beautifully: the Converter produces **extracted powers and re-roll currency** that can be applied to *crafted* gear (a smith-made blade with a Converter-extracted power socketed via a Rune charm is the endgame of player agency — deterministic base, lottery soul). And salvage the Converter can't use becomes **merchant fodder or adventurer gear** (Part 1.4). Nothing is ever truly trash; everything has a mouth that eats it. That's the Demeo discard-to-meter lesson applied to the whole economy.

**Design takeaway for Part 3:** the smith is *certainty for sale*, hard-capped below the lottery's ceiling and below the player's own depth. Timed queues make it a rhythm, not a vending machine. House unlocks are its progression track, fed by the quest board and the merchant. The Converter and the smith are complementary mouths — one eats items, one eats gold.

---

# THE COHERENT LOOP: A DAY IN THE GUILD HALL

How board → dispatch → blacksmith → town growth feed each other in one session of play. (All names original; numbers are illustrative first-pass values.)

**Morning — the check-in (5 minutes, phone in hand with coffee).**
James's player died overnight at depth 14. Death returns them to town (decision c). The run-summary screen offers the choose-1-of-3 (WoW Vault pattern, from the earlier research). They walk — figuratively; it's two taps — to the guild hall.

1. **Dispatch returns.** The overnight 8-hour breach-closure contract resolved: success, but the Vanguard is injured (heavy — 4 hours + salves). Payout: 1,200g fee, 300g wages auto-paid, +Renown with Greywatch, and a cracked Emberfall guard-part. The injured Vanguard goes to the infirmary timer.
2. **The board.** Two townsfolk notices expired overnight (soft fade, no penalty). One new overworld-town request: caravan guard work, threat 3, needs a Vanguard or two Skirmishers. The player assigns their level-5 Skirmisher pair — a 2-hour dispatch, clean composition, due by lunch.
3. **"Take it myself."** A relic-recovery notice (depth 10+, bring back a Rune charm blank) gets marked personal. The next idle delve that reaches depth 10 will auto-complete it at run end.
4. **Merchant.** The player buys salves and bandages for the Vanguard's healing (dispatch → merchant loop), and notices the merchant's premium stock: a **charter paper** for the second forge house — 2,500g. Not yet; wages come first.
5. **Blacksmith.** The Skirmishers' blades are two rungs behind the player's depth cap. The player queues two Epic Duelist blades (one known house) — 90 minutes each, two queue slots. They'll be ready by lunch, right when the caravan dispatch returns.

**Midday — the glance (30 seconds).**
Push notification (if enabled): "Caravan guard contract complete." The player opens the app at lunch: clean success, 800g fee, 200g wages, +Prosperity. The two Epic blades are done. They equip the Skirmishers — the party is visibly stronger for tonight's dispatch.

**Evening — the setup (3 minutes).**
The Vanguard is healed. The player posts the full A-team (Vanguard 6, Occultist 5, Mender 4) on a 10-hour abyss-breach contract — the overnight mission. The remaining Skirmisher pair takes a short 1-hour den-clearing notice. The player queues an armor order at the smith for the Mender (their guard is thin), buys tomorrow's supplies, and checks the town screen: Prosperity ticked up from the day's fees; the **daily guild-coffers claim** (NMS settlement-payout analog) is ready — 400g, scaled by Prosperity. They claim it, close the app, and start an idle delve to run while they sleep.

**What just happened, systemically:** gold entered via quest fees and the trickle; gold left via wages, healing supplies, smith orders, and the rush fee nobody paid. Adventurers leveled. Renown rose with two towns. The smith's queue advanced the roster's gear. The town's Prosperity grew, improving tomorrow's board. The player made maybe a dozen decisions across three short sessions — and every system touched at least two others. That is the loop: **board assigns the work, dispatch does the work, wages and injuries price the work, the merchant and smith convert gold into reliability, and the town grows around all of it.**

---

# DESIGN TAKEAWAYS

1. **The guild is the persistent layer; the run is the reset layer.** Adventurer levels, loyalty, roster, town stats, and smith unlocks survive death. This is what makes "death returns you to town" feel like coming home. Never let a run reset touch the guild.
2. **Composition is the puzzle, time is the texture, gold is the sink.** Every system in this paper reduces to: pick the right party (brain), wait the right duration (patience), pay the wages and costs (economy). If any leg of that tripod is missing, the layer collapses into a menu.
3. **Publish the limits.** What the smith can't do (no Legendary signatures, depth-capped), what Luck modifies, how wages are computed — state it in-game. OSRS's transparency lesson applies to the whole guild layer: trust is a feature.
4. **Failure costs resources, never roster.** Injuries, partial wages, lost fees — never dead adventurers, never lost levels. Players must feel safe dispatching; fear kills the system.
5. **Crafted is the floor, drops are the ceiling.** The smith's three hard rules (Epic cap, depth cap, tight rolls) are load-bearing. If any one of them slips, either crafting or loot dies.
6. **Every mouth eats something different.** Board eats time and attention; dispatch eats composition risk; wages eat gold; injuries eat supplies; the smith eats gold and queue time; the Converter eats items. No two systems compete for the same input — that's why the loop coheres instead of cannibalizing.
7. **Real time for the guild, game time for the delve.** The guild is the between-sessions engine; the delve is the in-session engine. They meet at the death/town beat and at "take it myself" quests. Offline-progress math must be timestamp-based and capped — and honest in-game about how it works.
8. **Idle roster, idle income.** Stationed adventurers trickle gold through capped station slots. The roster is never dead weight, and the trickle's real product is emotional, not economic.

---

# OPEN QUESTIONS FOR JAMES

1. **Dispatch party size and roster size.** This paper proposes 4-per-dispatch, ~10–12 roster at HQ. Too small? Too fiddly? (NMS runs 5-per-expedition out of 30 — we deliberately shrank both for phone.)
2. **The fifth class.** Four classes (Vanguard / Skirmisher / Mender / Occultist) keep the composition puzzle legible. Do you want the fifth — the Chronicler (boosts reward quality), or something else entirely — or is four the number?
3. **"Take it myself" auto-completion.** The proposal: personal quests auto-complete at run end when the delve meets the requirement — no active play needed. Does that feel right, or should personal quests ask for something more deliberate from the player?
4. **Wage failure teeth.** Failed quests still pay ~50% wages. Is that the right sting, or should failure cost the full wage (harsher economy) or nothing (kinder, but then failure is free)?
5. **Legendary crafting.** The paper hard-caps the smith at Epic with Legendary signatures drop-only. Alternative: allow Legendary crafts at steep cost *without* the signature behavior. Which side are you on?
6. **Forge-house unlock path.** Three candidates: quest-board contract chains, overworld-town Renown, merchant charter papers (premium gold). One path, or all three? If all three, which is fastest?
7. **The daily guild-coffers claim.** A NMS-settlement-style timed payout scaled by town Prosperity. Does a daily claim fit the idle rhythm, or does it become a login-chore resentment?
8. **Merchant gear ceiling.** The merchant never sells Charm-slot items or above Epic-equivalent. Right call, or should the merchant occasionally stock something spicy (at a painful price)?
9. **Injury model.** Time + supplies + gold, Mender mitigates, no permanent death — ever. Confirm the "never" — is there any version of stakes (e.g., a hardcore guild mode) you'd want, or is roster safety absolute?
10. **Board refresh on death.** Every player death refreshes the quest board. Good beat ("died, check the hall"), or does it make death feel *rewarding* in a way that undercuts the sting?

---

## IP hygiene note (James's standing rule)

Steal the systems, rename everything. None of these go into Abysmal: "frigate," "freighter," any NMS class/economy names, "Kanai's Cube," "Great Vault," "Haedrig's Gift," any Borderlands manufacturer names or terms ("Anointed," "Eridium"). All adventurer classes, forge houses, towns, NPCs, and flavor text in this paper are original proposals — but "Vanguard," "Skirmisher," "Mender," and "Occultist" are common genre words; a trademark search on final picks before commercial release still applies, per the standing guidance. Practical guidance, not legal advice.

*End of paper. Morning read for James — decisions (a), (b), and (c) are his; the numbers are first-pass proposals awaiting his word and a spreadsheet pass.*
