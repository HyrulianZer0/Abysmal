# Overworld & Towns — Design Reference for Abysmal
*Researched Oct 8, 2026. For a 2.5D first-person idle dungeon crawler roguelike (Godot 4.7, Android-first): idle auto-delving, death → death shop, per-death monster ramp (+2%/run, capped +50%), prestige (Abyssal Tokens / ascension), guild hall 4-stage chain, town/overworld scaffolding.*

All mechanics below are original design proposals for Abysmal, informed by the No Man's Sky settlement-management survey (loot-drop-progression-research-2026-10.md §3: 5 legible stats, building ranks, timed decisions, daily claimable payout). Numbers are provisional and flagged as tuning, not commitments.

## 0. The fantasy: what the overworld is FOR

The dungeon is where you *fight*. The overworld is where you *watch*. James's directive: "the overworld is for WATCHING YOUR TOWNS START AND GROW, handling requests and trades as they come up." Everything in this paper serves that sentence.

Concrete design posture:

- **The overworld is a management layer, not a second game.** One screen per town, one screen listing your towns, glanceable in 30 seconds on a phone. If any town interaction takes longer than a death-shop visit, it's too heavy.
- **Growth is legible.** The player should be able to tell, at a glance, whether a town is thriving, struggling, or dying — the way a Sims player reads a moodlet or an NMS player reads 5 settlement stats.
- **The dungeon funds the towns; the towns feed the dungeon.** Dungeon loot (gold) buys town founding and upgrades; town tithe (income) buys better dungeon gear via the blacksmith and guild quest board. One loop, two directions.
- **Death is a door, not a punishment.** Once the tavern/guild hall is established, dying returns you to town — per the standing rule, death costs the run, never future power. Towns make death *convenient*: you wake up where the shops are.

## 1. Town founding — how a new town starts

A town starts with a **Guild Charter**, bought at the guild hall (quest-board screen). Proposals:

- **First town:** the charter is bundled into the first guild-hall stage. You already bought the tavern (stage 1, 1.5k G) — the tavern IS the seed of the first town. Buy the tavern, name your town, and the town screen unlocks. This is the NPC breadcrumb payoff: farmer/woodcutter/blacksmith/trader at depths 2/4/6/8 told you to build it, and here it is.
- **Second and later towns:** charters cost escalating gold (provisional: 25k / 100k / 400k — must sit *above* the idle gold curve at the depth the player has reached, so founding a town is a mid-run goal, not a click). Each charter lets you plant a new settlement at an unlocked site.
- **Sites, not free placement:** towns can only be founded at marked sites on the overworld (see §7 — ruins, crossroads, dungeon-gate clearings). This keeps map layout authored and legible instead of letting the player dot the map randomly. Sites unlock via dungeon progress (e.g., site 2 unlocks at depth 25).
- **Original name generator:** each founded town gets a generated original name (e.g., "Dunmere", "Cleftford" — generated from syllable lists, NOT pulled from any existing IP) and the player can rename it once. Keep a name-pool big enough that no two towns in one save share a name.

**Design takeaway:** the first town is *free with the tavern* (breadcrumb reward); later towns are gold-gated mid-run goals. Town founding is how dungeon gold leaves the dungeon and becomes empire.

**Caveat:** charter costs need a sim pass against the idle gold curve (§10) before locking — the wrong number makes towns feel either trivial or impossible.

## 2. The settlement panel — what the player SEES

Each town gets one panel. NMS's settlement model is the template: 3–5 legible stats, no tooltips required to understand the mood of the town. Proposed stats (all original, generic enough to be safe):

| Stat | What it means | Goes up when | Goes down when |
|---|---|---|---|
| **Prosperity** | Town's economic output; drives the tithe | Buildings upgraded, trades completed, population growing | Upkeep debt, raids, unanswered requests |
| **Population** | Residents; cap = housing buildings | Requests completed, morale high, stages advance | Morale low, nest infestations, neglect |
| **Morale** | How happy residents are | Requests answered fast, trader visits, town events | Ignored requests, debt, decay |
| **Upkeep** | Ongoing cost of the town's buildings | Every building adds upkeep; higher ranks add more | Buildings downgraded/closed |
| **Safety** | How protected the town is (replaces NMS's "sentinel alert") | Watchtower built/upgraded, nests cleared | Nearby nests unanswered, monster ramp climbing |

Panel layout (phone-first): five bars with icons at the top of the town screen — color-coded (green/yellow/red thresholds), tap any for a one-line explainer. Below: building slots. Below that: pending requests as cards with countdown timers. Everything glanceable.

**Buildings & ranks.** Each town has **building slots** (provisional: 4 at outpost stage, +2 per stage, cap 12). Buildings are placed from a small menu; each building has **ranks 1–5** (named tiers, e.g., Rough → Sturdy → Fine → Grand → Resplendent — original names, none borrowed). Higher ranks raise output AND upkeep. NMS uses C–S classes; the point is *ranked upgrades with visible cost*, not the specific letters.

Proposed building set (all original, dungeon-fantasy generic):

- **Hovel / Rowhouses** — raises population cap.
- **Market** — raises Prosperity, enables trade routes.
- **Smithy** — lowers blacksmith craft costs in this town (ties to the "blacksmith crafts any weapon/armor for gold" directive).
- **Watchtower** — raises Safety, shortens nest-spawn timers nearby.
- **Granary** — buffers against supply-shortage requests (auto-fills some).
- **Tavern Annex** — raises Morale; at rank 3+ unlocks rumors (bonus quests on the guild board).
- **Shrine** — slow passive Morale regen; rank 5 gives the "Blessing" event (free request completion).
- **Guild Office** — ONLY in the first town (the guild hall chain lives here — §7). Higher guild-hall stages are this building's rank-ups.

**Design takeaway:** five stats, ranked buildings, slots that grow with town stage. Copy NMS's legibility; rename everything; keep it to one screen.

## 3. Growth stages — watching it grow

Proposed stages: **Outpost → Village → Town → City**. (Fifth "Bastion" stage parked as a post-launch candidate — keep the ladder short for v1.)

Each stage-up is a *moment*: the town screen art/layout visibly changes (more slots, denser skyline silhouette), a town-event popup fires ("Dunmere has grown into a Village!"), and a small celebration bonus lands (one-time tithe bonus + morale bump). Advancement conditions (provisional):

| Stage | Slots | Advance when (all required) |
|---|---|---|
| Outpost | 4 | — (founding state) |
| Village | 6 | Pop ≥ 40, Prosperity ≥ 60, Morale ≥ 50 |
| Town | 9 | Pop ≥ 120, Prosperity ≥ 120, Morale ≥ 60, ≥ 3 buildings rank 3+ |
| City | 12 | Pop ≥ 300, Prosperity ≥ 220, Morale ≥ 70, ≥ 2 buildings rank 5 |

Visible changes per stage (staged CC0 assets only — no AI-generated assets ever): stage badge on the town list, background/parallax swaps on the town screen, more ambient life (see §9). The guild-office building in the first town visually follows the guild-hall 4-stage chain (tavern → guild → expanded → HQ), so the first town's centerpiece grows on a parallel track.

**Caveat:** thresholds are guesses against no data — they need a passive-growth sim before implementation. The rule: reaching Village should take ~a day of casual play, City should be a month-scale goal. ("Easy, though not too easy.")

## 4. The Request system — towns ask for help

Requests are the overworld's heartbeat: timed, with real tradeoffs, NMS-overseer-decision style. A request appears as a card on the town panel with a countdown (provisional: 4–12 hours). Answer it, ignore it, or let it expire — all three are valid, all have consequences.

Request types (provisional set — small on purpose):

1. **Monster Nest** — a nest has spawned near the town (Safety drops while active). Answers: (a) clear it yourself — launches an auto-delve detour to a nest encounter, costs one run but pays loot + Safety; (b) hire guild swords — costs gold, instant, no loot; (c) ignore — nest grows, Safety and Morale bleed. If ignored past the timer, it becomes an infestation: bigger Safety hit, bigger reward when finally cleared.
2. **Supply Shortage** — town needs goods. Answers: (a) pay gold (dungeon loot → town mouths); (b) route a trade from a surplus town (see §5); (c) ignore — Morale drops, Population growth stalls.
3. **Construction** — residents want a specific building built/upgraded *now*. Answering with gold (or materials — see traveling merchant, §5) completes it instantly instead of waiting for passive construction. This is the whale-free version of "rush": it costs dungeon-earned gold, never premium currency (there is none).
4. **Prosperity Windfall / Emergency** (rare) — NMS-style tradeoff decisions: e.g., "A wealthy caravan offers 5k gold to set up a toll road through town. +Prosperity, −Morale." or "Refugees from a collapsed mine ask for shelter. −Upkeep, +Population." One tap, two stats move opposite directions. These are the memorable ones.

Rewards scale with town stage and the per-death monster ramp (a nest near a City at +40% ramp should pay accordingly). Expired requests penalize the relevant stat, never gold — you can't lose gold to a timer.

**Design takeaway:** requests are the reason to *check* the overworld between dungeon runs. 4–12 hour timers respect an idle game (no one should wake up at 3 AM for Abysmal). Every request has at least two answers and one tradeoff.

## 5. The Trade system — surplus between towns, and the traveling merchant

Once the player has 2+ towns with Markets, the **trade layer** opens:

- **Surplus/deficit:** each town periodically reports a surplus good (provisional goods list: grain, timber, iron, cloth, charm-goods — all generic). A town with a grain surplus and a town with a grain shortage can be linked with a **trade route** (one tap, costs a small setup fee). Routes generate passive Prosperity for both towns and a small gold trickle to the player. Routes are visible on the town list as link icons — empire legibility.
- **Player-mediated trades:** the Supply Shortage request (§4.2) can be answered by routing goods from a surplus town instead of paying gold. This makes founding town #2 mechanically meaningful, not just cosmetic.
- **The traveling merchant:** a single NPC on a visible circuit visiting your towns on a timer (provisional: completes a full circuit every 6 hours). While the merchant is in a town: unique town-only goods are buyable (materials for Construction requests, a rotating rare charm — never power items, per the economy rules), the town gets a Morale bump ("the market is lively"), and the merchant sells one "rumor" that adds a quest to the guild board. The merchant's position is shown on the overworld screen — watching the little icon travel is pure §9 ambient satisfaction.
- **Merchant + dungeon:** the merchant also buys nothing from the player — keep gold flowing dungeon→town→dungeon, not into a sell-everything vendor that bypasses the death shop.

**Caveat:** trade routes risk becoming set-and-forget spreadsheet work. Mitigation: routes have a duration (provisional: 7 days) then need one-tap renewal, and surpluses rotate, so the player re-engages without daily babysitting.

## 6. Idle income — the tithe must feel earned

NMS's lesson: the daily payout feels earned because you watched upkeep get repaid from surplus first. Proposal for Abysmal:

- Each town accrues a **tithe** over time (provisional: ticks hourly). Tithe rate = Prosperity − Upkeep, floored at 0. If Upkeep > Prosperity, no tithe accrues — the town is in **debt** instead (see §8).
- Tithe is **claimable, not automatic**: a "Collect" button on each town (and a "Collect all" on the town list). Unclaimed tithe caps at 24 hours of accrual — the player who checks daily gets everything; the player who checks weekly gets one day's worth. This is the earned-feel knob: it rewards the habit without punishing a life.
- Tithe scales with stage (City tithes dwarf Outpost tithes) and gets a multiplier from Morale (provisional: ×(0.8 + Morale/250), so 100 Morale ≈ ×1.2).
- Where tithe spends: the blacksmith (crafting), guild board (quest costs), charters for new towns, request answers. Gold stays in the dungeon→town→dungeon loop.

**Design takeaway:** claimable, capped, surplus-minus-upkeep. The NMS "watch the debt repay itself from surplus" moment is the emotional core — show a little "debt repaid" tick when a town climbs out.

## 7. Connections — guild hall, towns, dungeon

Three entities, one legible relationship:

- **The guild hall is IN the first town.** The tavern you buy (stage 1, 1.5k G) is a building in your first town; the guild-hall 4-stage chain (tavern → guild → expanded guild → HQ) is that building's upgrade path. The quest board (guild = quest board, per James) lives here. Later towns get a small "Guild Office" annex building that mirrors the board remotely — no second full guild hall, one board to rule them all.
- **Dungeon entrances on the overworld.** Proposal: each founded town sits near its own **dungeon gate** — a separate entrance into the same dungeon, but each gate has a **depth offset** (town 1: depth 1; town 2: depth ~15 equivalent; town 3: depth ~30). You pick which gate to delve from on the overworld screen. Mechanically this is "skip the early floors you've outgrown" — the idle-friendly answer to run-startup tedium — implemented as gate selection rather than a debug cheat. Gates deeper than you've personally reached stay sealed (no sequence-breaking). Monster ramp (+2%/run, +50% cap) applies globally regardless of gate.
- **Death returns to town.** Once the tavern exists, dying puts you at your town (the one whose gate you delved from, or the first town — pick one and be consistent). The death screen keeps the death shop and adds the town door: collect tithe, answer requests, re-delving is one tap. Death becomes the game's natural town-visit rhythm.

**Caveat:** depth-offset gates are the most mechanically ambitious piece here — they interact with prestige token triggers (10→11 stairs) and cycle-best-depth tracking. Proposed rule: tokens trigger on *stairs descended*, so gate 2 starting at depth 15 still earns a token when it descends 10→11 *relative to its own gate*... or absolute depth 10? This needs a decision (see Open questions). Simpler alternative parked: one dungeon entrance, gates are cosmetic — but the depth-skip is genuinely valuable for idle pacing, so it's worth the design cost.

## 8. Failure & decay — can a town shrink?

Yes — but gently ("easy, though not too easy"). NMS's upkeep-debt model is the template, and it maps cleanly:

- **Upkeep debt:** when Upkeep > Prosperity, the difference accrues as **debt** (visible number on the panel, red). Debt auto-repays from future surplus before any tithe accrues — the player watches the town dig itself out, NMS-style. The player can also pay debt directly with gold (dungeon loot rescues towns — the loop again).
- **Consequences of sustained debt/neglect:** Morale drains while in debt → Population growth stalls, then reverses → if Morale bottoms out for a sustained period (provisional: 72 hours), the town **loses a stage** (City → Town), refunding nothing, with a somber event popup ("Dunmere is shrinking. The market square is quiet."). Buildings keep their ranks — the town contracts, it doesn't burn.
- **What CANNOT happen:** a town can never be destroyed, raided to zero, or deleted. The standing rule "death costs the run, never future power" extends here: neglect costs *momentum*, never *the save*. A player returning after a month finds shrunken, debt-ridden towns — a renovation project, not a graveyard. This is the anti-quit mechanic.
- **Monster-ramp pressure:** as the per-death ramp climbs toward +50%, nest requests get harder and Safety upkeep costs drift upward — towns get more expensive exactly as the dungeon gets harder. Deliberate squeeze; the tithe should still outpace it for an engaged player.

**Design takeaway:** debt → morale drain → stage loss is the full decay ladder, but the floor is "shrunken town," never "lost town." Neglect is recoverable by design.

## 9. Moment-to-moment: what "watching them grow" means in an idle game

In an idle game the player isn't *in* the town — so "watching" has to be delivered in 30-second visits:

- **Ambient life feed:** the town screen shows 1–3 rotating flavor lines from a pool ("The market square is busy today." "Children are playing by the well." "Smoke rises from the smithy."). Lines change with stats: high Morale → cheerful lines; in debt → worried lines. Cheap to implement (string pools), high "it's alive" payoff. All original writing.
- **Visible growth ticks:** population number ticks up in real time while the panel is open; building upgrade progress bars fill; stage-up is a full-screen-ish moment with the new skyline.
- **Event popups:** requests arriving, merchant arriving, stage-ups, debt repaid, nest cleared — these fire as dismissible cards on the town list, not modal interrupts. The player opens the app, sees "3 new town events," taps through them like a morning paper. This is the idle-game core loop for the overworld.
- **The overworld screen itself:** your towns as nodes (map size TBD — James's call), the traveling merchant as a moving dot, nest icons pulsing near towns that need help, tithe-ready towns glowing softly. One screen, whole empire, 5 seconds to read.

**Phone-first rule restated:** nothing on the overworld may require more than three taps. Town list → town panel → answer request is two taps. Collect-all tithes is one.

## 10. Economy sketch — provisional numbers for the sim

All provisional; needs a passive-growth sim against the idle gold curve before implementation:

- Charter costs: town 1 bundled with tavern (1.5k G); town 2 ≈ 25k; town 3 ≈ 100k; town 4 ≈ 400k.
- Tithe rate: hourly tick = (Prosperity − Upkeep) × stage multiplier (Outpost ×1, Village ×2, Town ×3.5, City ×6) × morale multiplier.
- Target: a mid-game Village should tithe roughly what 30–60 minutes of idle delving earns — meaningful, never replacing the dungeon.
- Building costs: rank-up cost ≈ 2.5× previous rank; rank 5 of a late building should cost less than a charter for the next town (keeps the "wider vs. taller" choice live).
- Request gold costs: scale with stage (a City's supply shortage costs ~10× an Outpost's).

## Design takeaways for Abysmal

1. **First town = the tavern purchase** (breadcrumb payoff); later towns are gold-gated mid-run goals at authored sites. No free placement, no map clutter.
2. **Five stats** (Prosperity / Population / Morale / Upkeep / Safety), ranked buildings (5 ranks), slots that grow per stage — the NMS settlement panel, renamed and shrunk to one phone screen.
3. **Outpost → Village → Town → City**, each stage-up a visible moment with art change, event popup, and celebration bonus. Thresholds need a sim; Village ≈ 1 day, City ≈ 1 month.
4. **Requests are the heartbeat**: 4 types (nest / shortage / construction / windfall-emergency), 4–12h timers, every one answerable at least two ways, expired requests cost stats never gold.
5. **Trade opens at 2+ Markets**: surplus/deficit routes (7-day duration, one-tap renewal), player-mediated shortage fixes, and a traveling merchant on a visible 6-hour circuit selling materials, rotating charms, and rumors — never buying from the player.
6. **Tithe is claimable, capped at 24h, surplus-minus-upkeep** — the NMS "watch debt repay from surplus" moment is the earned-feel core.
7. **The guild hall lives in town #1** (the 4-stage chain is its building's upgrade path); each town gets a **dungeon gate with a depth offset** (sealed until personally reached) — idle-friendly run startup; death returns you to town, making death the natural town-visit rhythm.
8. **Decay ladder: debt → morale drain → stage loss**, floor is "shrunken town," never lost. A month away = renovation project, not graveyard. Neglect costs momentum, never the save.
9. **"Watching them grow" = ambient flavor lines + ticking numbers + morning-paper event cards + a 5-second-readable overworld screen.** Everything ≤ 3 taps.
10. **IP hygiene**: all names, stats, building names, flavor text, and the merchant are original. "Settlement," "overseer," NMS's exact stat names, and C–S ranks stay out. Mechanics are industry-standard; the words must be ours.

## Open questions for James

1. **Map size — your call, explicitly.** How big is the overworld? Candidates: (a) a compact authored map with ~6–8 fixed sites (tight, every node matters); (b) a larger explorable map with fog/sites unlocking by depth (more "world" feel, more art cost). What should it FEEL like — a diorama or a frontier?
2. **Town count cap.** Is 4 towns right, or should founding stay open-ended with escalating charter costs? Open-ended risks UI sprawl; capped risks a "done" feeling.
3. **Gate depth offsets vs. token triggers.** If gates skip early floors, does the Abyssal Token trigger (descend 10→11) count per-gate or absolute depth? Simplest: token on absolute 10→11 regardless of gate — but then gate-2 delvers earn it "free." Your ruling needed before implementation.
4. **Can the player visit the dungeon without a town?** Pre-tavern, death returns... where? Proposal: a bare "camp" screen until the tavern is bought. Fine, or should the tavern be cheaper so towns arrive sooner?
5. **Merchant inventory.** Should the traveling merchant ever sell power (gear), or strictly materials/charms/rumors? Strictly non-power keeps the dungeon supreme; a rare power item would make the merchant a destination.
6. **Decay severity.** Is "lose a stage after 72h at zero morale" too harsh, too gentle, or about right? And should the player get a warning popup at 48h ("Dunmere is failing")?
7. **Trade route duration.** 7-day routes with renewal — good rhythm, or should routes be permanent once set?
8. **Naming.** The generated town names need your vibe check — what should an Abysmal town sound like? (Grim? Cozy? Weird?) Same for the traveling merchant's name/title.
9. **Stage count.** Outpost → Village → Town → City — want the 5th "Bastion" stage now, later, or never?
10. **Tithe cap.** 24-hour claimable cap — right number, or should engaged daily players get more runway (48h)?

## 11. Earned town automation — unlock by doing, then call-backs (James, Oct 10, 2026)

From James's Oct 10 main-chat direction on the overworld loop: town management should be **earned, then automated**. The player completes a production/management task **manually through roughly 10 levels** of it first (e.g., hand-running a building's production chain); once proven, that task can be automated and runs in the background. Automation is the reward for demonstrated mastery, not a default.

**Call-back events.** An automated town runs itself, but the game **calls the player back to a specific town** when a problem needs a decision. James named three problem types:
1. **Breakdowns** — a building breaks; fix it (gold/materials) or its output stalls.
2. **Supply shortages** — inputs run dry; reroute a trade route, buy from the merchant, or ride it out (stats dip).
3. **Skimming** — someone in the town is skimming; a trust event with a choice (forgive / fine / replace), each with different stat consequences.

**New currency on thriving.** As a town thrives (stage-ups, high Prosperity/Morale), it unlocks a **new currency** — a late-game reason to push past "good enough," not just bigger tithes. Form and name TBD (James's vibe check; see Open question 8).

**Design takeaway:** automation = manual ~10 levels first → background idle; the soul of the loop is the call-back interrupts (breakdown / shortage / skimming). Open tuning: which buildings/tasks qualify for the automation unlock, and whether the new currency is per-town or empire-wide.
