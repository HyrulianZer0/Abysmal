# NPCs & Story Beats — Design Reference for Abysmal
*Written Oct 8, 2026. For a 2.5D first-person idle dungeon crawler roguelike (Godot 4.7, Android-first): idle auto-delving, death → death shop, per-death monster ramp (+2%/run, capped +50%), guild hall 4-stage chain (tavern → guild → expanded guild → adventurer's guild HQ), town/overworld scaffolding, prestige system live in code (Abyssal Tokens, ascension, Gilded Soul perk).*

All names, lore, and dialogue below are original — IP hygiene per James's rules. No AI-generated or external IP assets: every NPC here is expressible with staged CC0 portraits, Kenney-style first-person hands, and the HUD text-popup bark system James already approved (idle-ai-behavior-spec.md).

Design philosophy: every NPC here exists to make a *system legible*, not to decorate it. A player who skips every line of dialogue should still understand prestige and ascension — but a player who reads should feel why the systems exist in the world.

---

## 0. The naming rule (one line, obeyed throughout)

Nobody in the abyss has a famous name. Nobody is "the chosen one." These are *working people* who fell, wandered, or hid in the dark — which is exactly why the soul-reincarnation theme works: the abyss doesn't care who you were, only whether you keep coming back.

---

## 1. The Breadcrumb Trail — the four depth NPCs

**Design purpose (James's directive):** NPCs at depths 2/4/6/8, each granting a buff that **persists through death** ("the body may die, the soul reincarnates"). Each is a story beat that spaces the player toward building the tavern/town. Each foreshadows it in their own voice: *"come find me when you've bought that old tavern."*

**Shared mechanics:**
- Each NPC is a one-time meeting per *cycle* (resets on ascension — see Counselor, §2). Re-meeting them after ascension grants the buff again with fresh dialogue acknowledging the loop ("You've done this before. I remember. Do *you*?").
- The buff applies instantly on meeting and is *flagged on the soul*, not the body — dying does not remove it. Death screen should show the four icons lit: "the soul remembers."
- Each NPC lives in a **safe pocket** — a small room the idle AI paths through, marked by a unique prop. No combat inside the pocket (enemies don't spawn there); the NPC is unkillable and uninteractable beyond dialogue. Phone-first: dialogue is 3–5 short lines, HUD text popups + optional log lines, matching the bark delivery already built.
- After the tavern (guild hall stage 1) is purchased, each NPC **moves to the town** with a permanent spot, and their depth-pocket version becomes a "memory echo" — the same lines, one line shorter, with the buff already active. This makes the tavern purchase visibly *depopulate the dungeon of loneliness*.

### 1a. Depth 2 — Marla Bramble, the farmer → **Well Fed (+max HP)**

**Who.** A stout woman in her fifties with mud permanently under her nails and a scarf knotted over her hair. She keeps a narrow terraced garden in a sunless cavern, grown under a colony of pale lantern-moths that feed on abyss mist and glow dim green.

**Backstory (one paragraph).** Marla was a turnip-and-barley farmer two valleys over when the war tithes took her sons and the tax collectors took the farm. She walked *down* instead of walking home — "the dark doesn't tax you, boy, it just *waits*" — and found a cavern where the mist made things grow sideways and twice as fast. She's been feeding lost delvers for eleven years. She won't say what happened to her sons; her dialogue implies she thinks the abyss took them first and she's staying to make sure it doesn't keep anyone else.

**Where she stands.** A shallow stone hut against the cavern wall — dry-stone, one room, roof of packed moss and planks. Outside it: the lantern-moth garden (rows of pale glowing tubers), a cook-pot over a cold blue flame that never goes out. The safe pocket reads as *warmth in the dark*: the only orange/warm light on the first four floors.

**The meeting dialogue (short — phone-first):**
- Marla: "Well now. A live one. Sit, sit — the moths won't eat you, they only drink the dark."
- Marla: "You look half-starved, and the dark's twice as hungry as you. Eat."
- *[Well Fed gained: +max HP]*
- Marla: "There. A full belly outlasts a sharp blade, my mam always said. The soul remembers being fed — even the next one."
- Marla: "You hear of anyone buying up that old tavern on the surface? Land like that goes to waste empty. When you've got it — *come find me.* I'll cook for a whole town."

**Flavor justification.** Well Fed = a soul-level +max HP because Marla's cooking isn't just food — it's the memory of being *cared for* in a place that cares for nothing. The soul carries nourishment the way it carries scars. Mechanically it's +max HP; narratively it's the first thing the abyss can't take from you.

**Foreshadow beat.** The tavern line plants the seed at depth 2 — the earliest possible moment. After the tavern is bought, Marla moves into the tavern kitchen; her dialogue in town becomes recipe-flavored idle chatter ("The moths followed me up. Don't ask how."). She is the emotional anchor of the town: the first NPC the player meets, and the first resident.

### 1b. Depth 4 — Tovan Ashe, the woodcutter → **Well Rested (regen)**

**Who.** A gaunt, quiet man with an axe that's older than he is, wrapped in a blanket-coat stitched from sailcloth. He never hurries. Everything about Tovan is slow on purpose.

**Backstory.** Tovan was a lumberjack for the river mills until a snapped cable took his crew and his leg's full use. He came down to the fourth depth because the petrified "ghostwood" there — dead trees that never rotted, drinking abyss mist — is the only timber that burns with *no smoke*, and smokeless fire is the only fire the deep things don't notice. He cuts it alone, one tree a week, and sells it to delvers who know. He stays because the surface wanted him grateful for a pension that never came.

**Where he stands.** A lean-to campfire site: a ring of stones around a smokeless blue-white fire, a chopping block, ghostwood stacked like pale bones, and a bedroll laid out *for the player* — the game never explains who it's for. The pocket is quiet; the SFX layer should be near-silent here.

**The meeting dialogue:**
- Tovan: "...Sit. Fire's safe. Nothing down here hunts what doesn't hurry."
- Tovan: "You sleep like you're bracing for a blow. Lie down. The wood won't judge."
- *[Well Rested gained: +HP regen]*
- Tovan: "Rest is a weapon, friend. The dark wins every fight you're too tired to finish. Your soul knows how to rest now — bodies forget, souls don't."
- Tovan: "That old tavern up top — I heard it's for sale. A place with real beds, where a man can sleep without one ear open... *Come find me when you've bought it.* I'll keep the hearth."

**Flavor justification.** Well Rested = regen because Tovan taught the soul *how to rest* — the mechanic is literally "your soul learned to recover while the body is busy dying." It's the counterweight to the abyss's attrition: every death costs the run, but the soul gets better at healing between disasters.

**Foreshadow beat.** The hearth line makes Tovan the tavern's future keeper-of-the-fire. When he moves to town, he takes the tavern's common-room hearth — and his "rest" theme becomes the town's rest mechanic home: if James ever adds an inn-style recovery bonus, Tovan owns it.

### 1c. Depth 6 — Sarella Vex, the blacksmith → **Well Armed (+attack)**

**Who.** A broad-shouldered woman with burn scars mapping both forearms, a leather apron over chainmail she clearly forged herself, and the loudest laugh in the dark. Where Marla is warmth and Tovan is quiet, Sarella is *defiance*.

**Backstory.** Sarella was the third smith of a mountain hold that fell to a dragon — a *real* one, in the old wars — and she was the one who kept the forge lit while the hold burned around her so the evacuation had weapons. The hold's lords forgot her name in the songs. She came down to depth 6 because the abyss grows **bleedstone**, a blue-black ore that holds an edge no surface steel can match, and she's spent nine years proving the songs wrong one blade at a time. She forges for delvers who bring her ore — and she never charges the ones who look like they won't come back.

**Where she stands.** A forge built into the rock: an anvil of black glass, a quench trough steaming with cold water, weapon racks of half-finished bleedstone blades, and a bellows the player can hear *before* they see the room. The pocket smells of hot metal even through the screen — warm color grading, ember particles.

**The meeting dialogue:**
- Sarella: "HA! Another one walking like the dark owes them rent. Come here — let me see that edge."
- Sarella: "Hm. Surface steel. It'll do. But *you* — your swing's got spite in it. I like spite. Spite outlives steel."
- *[Well Armed gained: +attack]*
- Sarella: "There. I can't reforge your blade down here, but I reforged *you* — a little. The soul remembers how to hit. Bodies just carry the memory."
- Sarella: "They say someone's finally buying that old wreck of a tavern up top. You do that, and *come find me* — this forge is wasted on the dark. I'll arm your whole town."

**Flavor justification.** Well Armed = +attack because Sarella doesn't improve the weapon — she improves the *swinger*. The soul carries technique across bodies: every death, the new body inherits the old one's lessons. This is the most literal expression of the reincarnation theme, and Sarella is the one who says it out loud.

**Foreshadow beat.** The "arm your whole town" line makes Sarella the blacksmith of the guild hall chain — James already decided the blacksmith crafts any weapon/armor for gold, so Sarella *is* that system wearing a face. Depth 6 plants her; the guild hall hires her.

### 1d. Depth 8 — Pello Quin, the trader → **Inspired (+luck)**

**Who.** A wiry, bright-eyed man with too many pockets, a grin that's survived things it shouldn't have, and a cart that has no business being eight floors underground. Nobody knows how the cart got there. Pello won't say. ("Trade secret, friend. Literally.")

**Backstory.** Pello was a caravan master on the surface roads until the roads stopped being safe for anyone honest. He drove his cart *down* on a dare and discovered the abyss's real economy: delvers die rich and resurrect broke, which makes them the best customers in the world — no haggling, no credit, just desperate hope with coin in it. He trades in stories as much as goods: every trinket on his cart has a previous owner's tale, and he tells them free with purchase. Under the grin, he's keeping a ledger of every delver who never came back up — "someone ought to remember their names, since the dark won't."

**Where he stands.** A lantern-lit trading post: the impossible cart, a rug spread with oddities, hanging lanterns in five colors, and a chalkboard with the day's "rates" that are clearly made up on the spot. The pocket feels like a *market stall that wandered into a tomb* — the only place in the deep dungeon that feels *mercantile* instead of mournful.

**The meeting dialogue:**
- Pello: "Pello Quin! Purveyor of fine second chances! You're my favorite kind of customer — breathing!"
- Pello: "Here — take this. A luck-charm. Previous owner cleared twelve floors with it. Don't ask about the thirteenth."
- *[Inspired gained: +luck]*
- Pello: "Luck's not a coin, friend, it's a *habit*. Your soul just learned the habit. Die all you want — the habit comes back with you."
- Pello: "Word is that old tavern's on the market. A trader needs a *base*, friend, and a town needs a *market*. You buy it — *come find me.* We'll make that town rich."

**Flavor justification.** Inspired = +luck because Pello teaches the soul *expectation* — the habit of assuming the next chest is the good one. Luck in Abysmal already feeds the death shop (per James's loot design); Pello is the in-world reason the soul's luck persists: he literally sold the soul a habit, and habits survive death. This also retroactively justifies the Luck skill's death-shop feed — the death shop *is* Pello's ledger, in a sense (see §4).

**Foreshadow beat.** The market line makes Pello the town's economy NPC — the face of the death shop once the town exists. Depth 8 is the deepest breadcrumb: the player who reaches Pello has *earned* the full set, and his line is the final push toward the tavern purchase.

### Breadcrumb trail — design summary table

| Depth | NPC | Trade | Buff | Soul-flavor | Town role |
|---|---|---|---|---|---|
| 2 | Marla Bramble | Farmer | Well Fed (+max HP) | The soul remembers being fed | Tavern kitchen |
| 4 | Tovan Ashe | Woodcutter | Well Rested (regen) | The soul learned how to rest | Tavern hearth / inn |
| 6 | Sarella Vex | Blacksmith | Well Armed (+attack) | The soul remembers how to hit | Guild blacksmith (crafts for gold) |
| 8 | Pello Quin | Trader | Inspired (+luck) | The soul learned the habit of luck | Town market / death-shop face |

**Why this order works.** The buffs arrive in the order a struggling player needs them: survivability (HP) → sustainability (regen) → damage (attack) → economy (luck). The *story* order works too: warmth → quiet → defiance → hope. And the tavern foreshadow escalates: a cook, a hearth-keeper, an armorer, a market — by depth 8 the player has mentally staffed the entire tavern before buying it.

**Honest caveats.**
- Four unskippable-feeling NPC stops could irritate speed-runners. Mitigation: after the first meeting per cycle, re-meeting is one tap ("Marla nods. Well Fed rekindled.") — the full dialogue only plays once per cycle.
- The "memory echo" version after the tavern is bought must be *visibly* different (faded/ghostly) or players will report it as a bug ("Marla is in two places").
- Buff numbers need tuning against the floor-10 balance target (attempt-3 clear). Suggested starting points: Well Fed +10% max HP, Well Rested +15% regen, Well Armed +8% attack, Inspired +10% luck — modest, stackable-with-everything, never build-defining.

---

## 2. The Counselor — prestige NPC

**Design purpose (James's directive):** an NPC for the prestige system — "make it relevant." Not a menu skin. A character whose presence *explains* why prestige tokens exist and what a cycle is.

### Who: Counselor Ilya Venn

**The concept.** Ilya Venn is the guild hall's record-keeper — a calm, precise, older person (deliberately ungendered presentation; soft voice, ink-stained fingers, a ledger that never closes) who has served *every* guild that ever stood over this abyss. They are very old. They do not explain how old. The implication, never stated: Ilya has watched a hundred delvers live the same loop the player is living, and keeps the records so *someone* remembers that each loop was a person.

**Why a counselor and not a merchant.** Prestige is the game's most abstract system — tokens for clearing floors 1–10, cycles, ascension. A merchant would make it transactional; a counselor makes it *reflective*. Ilya's job is to give the player a moment of "here is what your last cycle meant" — which is exactly what the prestige screen needs emotionally. The mechanics (token count, cycle records, ascend button) live in Ilya's dialogue UI, but the *character* is what makes the player open it more than once.

**Where they live.** A quiet room in the guild hall — available from guild stage 2 (the full guild, not the run-down tavern). Before stage 2, prestige still *works* (tokens accrue silently, the death screen shows a small "the Counselor would want to see this" hint), but Ilya has no room yet. The room: a round table, a wall of ledgers, one window with actual daylight, a chair that is always pulled out waiting. The quietest room in the game — no music, just page-turns.

**What they do mechanically.**
1. **Explains prestige tokens.** First visit: a 4-line explanation ("Every time you clear the tenth floor, the abyss *notices*. It leaves a token. Three tokens, and we can do something with them."). Never uses the word "prestige" in-world — Ilya calls them **"marks the dark leaves on you."** The UI can say "Abyssal Token"; Ilya's dialogue gives it meaning.
2. **Shows cycle records.** Ilya's ledger displays: current cycle best depth, last cycle best depth, tokens held, ascensions completed, and — the emotional hook — a one-line auto-generated epitaph per cycle ("Cycle 3: reached depth 14. Died to a cave lurer. The ledger remembers."). This is the *only* place the game acknowledges individual runs as stories.
3. **Performs ascension.** The ascend action happens *through* Ilya: a short ritual beat (candle lit, ledger entry written, "And so the cycle turns"), then the mechanical ascension (3 tokens → +1 stack of every unlocked perk, +1 bonus if the record was beaten). Ilya's post-ascension line changes based on whether the record bonus was earned.
4. **Resets the breadcrumb trail.** Ascension is a new cycle — the four depth NPCs can be re-met, and Ilya is the one who tells the player why: "They'll remember you. The question is whether *you'll* remember *them*. Go down and find out."

**Personality.** Warm, unhurried, dry-humored. Ilya treats the player like a colleague, not a hero. The running gag: Ilya has a stamp for everything, including emotions ("I'm stamping this one *wistful*").

**Sample dialogue:**
- *First visit:* Ilya: "Sit. You're the one who keeps coming back, aren't you? Don't look surprised — the ledger knows. Everyone in it comes back. That's rather the point of the ledger."
- *Explaining tokens:* Ilya: "The tenth floor. Every time you clear it and walk down past it, the dark leaves a mark on you — a token. Collect three, bring them here, and we'll turn them into something permanent. The dark takes everything else. Not these."
- *Cycle records:* Ilya: "Cycle four. Best depth: eleven. Cause of ending: ascension — oh, that's *this* one, isn't it. Forgive me, I write ahead. The ledger remembers what the body forgets. Would you like to hear about cycle two? No? Wise. Cycle two was embarrassing for everyone."
- *Ascension (record beaten):* Ilya: *[lights a candle]* "Three marks. A deeper road than last time. The ledger turns its page — and so do you. Gilded Soul, a little brighter." *[stamp]* "Approved. Obviously."
- *Ascension (record not beaten):* Ilya: "Three marks. Not deeper than last time — but *here*, which is more than the dark expected of anyone. The page turns anyway."
- *Breadcrumb reset hint:* Ilya: "Marla, Tovan, Sarella, Pello — they'll be down there again, same as always. They'll remember you. Go remind yourself."

**Why this is relevant, not a menu skin.** Without Ilya, prestige is arithmetic: 3 tokens → +10% gold. With Ilya, prestige is *the game's thesis restated by a character*: the loop has meaning because someone is keeping score *kindly*. Ilya is also the only NPC who acknowledges the player across cycles — which makes ascension feel like a story event instead of a currency exchange. Mechanically, nothing changes from the implemented design (prestige-design-2026-10.md) — Ilya is the *face* on the existing `Prestige` autoload.

**Honest caveats.**
- Ilya must not gate prestige behind guild stage 2 *mechanically* — only the room and the full record UI are gated. Tokens must accrue and ascension must be possible from the death screen from day one (the implemented design already allows this). Ilya's room is a reward for guild progress, not a tollbooth.
- The auto-epitaphs need a content pool (causes of death × depth bands) or they'll repeat fast. Start with ~20 templates; it's flavor, not systems.
- Keep Ilya's dialogue out of the critical path: a "just show me the ledger" fast option on every visit.

---

## 3. The Demigod — ascension NPC

**Design purpose (James's directive):** an NPC for ascension — "make it relevant." The Counselor explains the *records*; the Demigod explains the *power*. Ascension must feel like an audience with something vast, not a button press.

### Who: Vess, the Half-Drowned God

**The concept.** Vess is not a god *of* the abyss — Vess is a god the abyss *drowned*. Once a minor deity of thresholds and crossings (doors, bridges, the moment between waking and sleep), Vess was pulled down centuries ago when a cathedral's foundation broke through into the deep dark. What's left is a vast, patient presence wearing the shape of a drowned traveler: waterlogged coat, lantern full of dark water, eyes like deep wells. Vess speaks slowly, like someone remembering language one word at a time.

**Why a *faded* god.** A full-powered god would break the game's stakes — why doesn't it just fix everything? Vess is *diminished*: it can only act through the one loophole the abyss left it — the moment of ascension, when a soul voluntarily turns its cycle's page. Vess can't grant power; it can only *witness* a soul becoming more than the dark budgeted for, and in the witnessing, make it true. That's the ritual: not a blessing *given*, but a becoming *recognized*. This keeps the player as the agent — Vess is the audience that makes the performance real.

**Originality check.** "Faded god in the dungeon" is a trope neighborhood (cf. various roguelikes), but Vess's *specifics* are original: a god of *thresholds* (not war, not death, not the abyss itself), drowned rather than slain, acting only as *witness* rather than patron, communicating in half-remembered fragments. No existing game has this exact figure. The name "Vess" is invented; "Half-Drowned God" is a title, not a proper noun from any IP.

**Where they appear.** Vess does not live in the town. Vess appears **at the threshold** — manifesting in Ilya's quiet room *only* during the ascension ritual, rising out of the room's shadows like water filling a footprint. The staging: the room darkens, the candle Ilya lit gutters blue, and Vess is simply *there*, where a moment ago there was empty chair. After the ritual, Vess is gone — the chair is empty again, the candle burns normally. Vess is never available for casual conversation. This scarcity is the point: ascension should feel like weather, not shopping.

*(Late-game alternative for James to consider: once the guild hall reaches stage 4 — the adventurer's guild HQ — a flooded shrine room unlocks in the town where Vess can be *sensed* but never spoken to: flavor text only, "the water in the basin is deeper than the basin." Keeps the mystique; gives the HQ a sacred room.)*

**The ascension ritual flavor (the beat, step by step):**
1. Player selects "Ascend" in Ilya's ledger UI (3 tokens held).
2. Ilya lights the candle and writes the ledger entry. (The existing mechanical ascension fires here.)
3. The room darkens. Blue gutter of the flame. Vess manifests — no fanfare, just *presence*. HUD text, slow.
4. Vess speaks: 3–4 lines (see below). The perk stacks land as Vess names them — "Gilded Soul" is spoken aloud by a god, which is why it *works*.
5. Vess dissolves. Ilya stamps the ledger, a little shaken every time ("It never gets... ordinary. Don't tell it I said that.").
6. Cycle resets. The breadcrumb NPCs are re-meetable. Ilya's post-ritual line plays.

**Sample dialogue — Vess:**
- *Manifestation:* Vess: "...a threshold. Again. You keep... *crossing*."
- *On the record (cycle best beat last):* Vess: "Deeper than the last time. The dark... did not budget for you. I am a god of the *between*, little soul — and I witness: you are *between* what you were and what the dark allows. Let the ledger show it."
- *On the record (not beaten):* Vess: "Not deeper. *Here*, though. Returning is also a crossing. I witness it."
- *Naming the power:* Vess: "What the dark takes, it keeps. What *I* see, it cannot unsee. **Gilded Soul.** Brighter. Heavier in the world's hand."
- *Dissolving:* Vess: "The water... remembers the shape of the shore. Come back... *deeper*."

**Sample dialogue — Ilya, after Vess leaves:**
- Ilya: *[quietly]* "It never gets ordinary. Don't tell it I said that. Right — the page is turned. Marla's probably already reheating the pot."

**Why this is relevant, not a menu skin.** Vess answers the question the prestige system can't: *why does turning in tokens make you permanently stronger?* The answer: because a god of thresholds witnessed you crossing one, and a god's witness is binding even on the abyss. Every future perk added to the `Prestige.PERKS` registry gets its flavor the same way — Vess *names* it, and the naming is the magic. This gives James a free flavor template for every future perk: "Vess names the [Perk]. One line about what it means."

**Honest caveats.**
- Vess must never become a quest-giver or a vendor. The moment Vess has a shopping list, the mystique dies. One function: the ascension ritual. (The HQ shrine is *sensed*, never interactive.)
- The manifestation needs to be cheap to stage: lighting change + text + maybe a water-particle effect. No model required — in fact, *no clear model is better*. Vess should read as "a shape the dark makes when it's paying attention."
- Frequency: ascension costs 3 tokens ≈ three 1–10 clears per ascension. That's often enough that the ritual must be *skippable* after the first viewing ("Ilya: 'The short version?'") — reverence that can't be skipped becomes annoyance.

---

## 4. Death-in-Town — the moment

**Design purpose (James's directive):** death returns to town once the guild hall/tavern is established. The *moment* of waking up needs to land — it's the emotional hinge the whole game swings on.

**The setup.** Before the tavern is bought, death works as it does now: the death screen, the death shop, the restart. The fiction: your soul claws its way back up alone, and Pello's ledger (the death shop) is where it catches its breath. This is fine for the early game — lonely, mechanical, honest.

**After the tavern is bought, death changes.** The death screen fades — and instead of the void, you wake up.

**The beat (written as staged direction + dialogue):**

> *[Fade in: warm light. Wooden ceiling. The smell of stew, somehow, through the screen.]*
>
> Marla: "...there he is. Told you he'd be back by supper. Tovan, he's awake — put the kettle on, would you?"
>
> Tovan: *[already putting the kettle on]* "Mm."
>
> *[Camera eases down to the common room. Sarella is oiling a blade at the big table. Pello is counting coins that aren't his yet. Ilya looks up from the ledger and makes a small mark.]*
>
> Ilya: "Welcome back. Depth [N], if the ledger's honest — and it is. The body didn't make it. The soul did. It always does."
>
> Marla: "Sit up slow. Eat something. The dark can wait — it's very good at waiting, the bastard."
>
> *[Death shop UI opens — reframed as Pello sliding his ledger across the table.]*
>
> Pello: "Now then! While you were *away*, a few things came in. The ledger remembers what the pockets forgot. Spend?"
>
> *[After shopping / on continue:]*
>
> Sarella: "Same time tomorrow? The dark's not going anywhere. Neither are we."
>
> *[Fade to the dungeon entrance. New run begins.]*

**Why this beat works.**
1. **It pays off the breadcrumb trail.** Every "come find me" line from depths 2/4/6/8 lands here — the player *finds them*, all at once, in the first death after the tavern purchase. The four NPCs' foreshadowing converts into a reunion. That's a story arc in four lines of old dialogue.
2. **It reframes death.** Death stops being "game over, try again" and becomes "coming home." The per-death +2% monster ramp is still real — the game gets harder — but the *fiction* says the town gets warmer to compensate. Difficulty up, dread down: that's the emotional signature of the whole game.
3. **It makes the death shop a scene, not a screen.** Pello's "ledger remembers what the pockets forgot" is the in-world justification for spending post-death currency: the soul carried back *value* even though the body lost everything. (This also retroactively justifies Luck feeding the death shop — Pello's ledger is literally the shop's fiction.)
4. **It's cheap to build.** One tavern-common-room backdrop (staged CC0 tavern interior or simple 3D room), five NPC portraits around a table, text popups. The idle AI barks system already proved text-over-scene works on phone.

**Variants (keep it fresh across hundreds of deaths):**
- The full beat plays on the **first death after the tavern purchase** and the **first death after each guild-hall stage upgrade** (4 full beats total — one per stage, each slightly grander: more townsfolk, better room).
- Every other death gets the **short version**: wake in the common room, one rotating line from a random resident ("Back again. Stew's hot." / "The dark's getting pushy down there — ramp's up." / "Ledger's balanced. You're clear to go."), then the shop.
- Deaths *before* the tavern is bought keep the current void-death-screen — the contrast is the point. Loneliness first, home later.

**Honest caveats.**
- The short-version line pool needs ~30 lines minimum or it goes stale fast. Cheap to write, but it must be *scheduled* as content work, not assumed.
- The "ramp's up" line is a nice touch — a resident *noticing* the +2%/run monster ramp in-world ("the dark's getting bolder") — but it must stay flavor. Never show the player the actual ramp number in dialogue; the number lives in the bestiary/codex if anywhere.
- First-death-after-tavern must *always* play the full beat, even if the player is speed-running. It's a one-time-per-stage cinematic; skippable with a tap, but never auto-skipped.

---

## 5. The founding myth — why buffs survive death

**Design purpose:** one short myth, told in-world, that justifies the soul-reincarnation theme — the reason Well Fed / Well Rested / Well Armed / Inspired persist through death while gold, gear, and bodies don't.

**"The First Descent"** — as told by Ilya Venn, in the guild hall's quiet room, on the player's first visit (optional "tell me about the abyss" prompt):

> "Before the town, before the guild, before any ledger — there was a delver named **Corva Ashen**, and she was the first to come back.
>
> "Everyone before her went down and stayed down. The dark kept their bodies, their blades, their coin — it keeps *things*, you understand. Things are easy to keep.
>
> "But Corva had eaten Marla's grandmother's stew before she went down — the recipe's older than the town, don't look at me like that — and she'd slept a full night in a real bed, and she'd learned the sword from someone who loved her, and she carried a luck-charm from a trader with too many pockets. And when the dark took her body on the ninth floor, it found it couldn't take *those*.
>
> "You can't confiscate a full belly. You can't repossess a good night's sleep. You can't steal a lesson, and you can't pickpocket a habit. The dark tried — it's thorough, I'll give it that — and what came back up the stairs was Corva's *soul*, wearing everything the dark couldn't hold.
>
> "She came back down the next day in a new body with the same soul. And the day after that. The dark has been trying to solve her ever since.
>
> "So that's the rule, and it's the only rule the abyss ever gave us for free: **the body is rented. The soul is owned.** Feed the soul, rest the soul, teach the soul, charm the soul — and the dark can take the body every single time, and you'll still win the long game.
>
> "That's why the ledger doesn't record bodies. Bodies are *rentals*. The ledger records souls."

**What this myth does mechanically.**
- Justifies all four breadcrumb buffs surviving death (each maps to a line: stew / sleep / sword-lesson / luck-charm — Marla, Tovan, Sarella, Pello are the myth's *living proof*).
- Justifies prestige/ascension (the soul accumulates; the cycle is the soul's, not the body's).
- Justifies the death shop (the soul carries back *value* the dark couldn't confiscate — Pello's ledger).
- Gives Ilya's line "the ledger remembers what the body forgets" a source.
- Names the game's thesis in one sentence: **"The body is rented. The soul is owned."** — candidate tagline for the store page, with James's approval.

**Honest caveats.**
- Corva Ashen is deliberately *gone* — a myth, not an NPC. Do not bring her back as a boss or a ghost. Myths stay powerful by staying off-screen.
- The myth mentions "Marla's grandmother" — that's a deliberate loose thread tying Marla's family to the deep history. Don't resolve it. Loose threads are load-bearing in folklore.
- Keep the myth optional (a prompt in Ilya's room, not a forced cutscene). Players who want systems without stories should never be held hostage by lore.

---

## Design takeaways

1. **Every system gets a face, and the face explains the system.** Marla = max HP, Tovan = regen, Sarella = attack, Pello = luck/death shop, Ilya = prestige, Vess = ascension. If a future system can't be given a face, that's a design smell — it means the system isn't legible enough yet.
2. **The breadcrumb trail is a staffing montage.** Depths 2/4/6/8 aren't just buffs — they're the player *hiring their town* before the town exists. The tavern purchase is the payoff, and the first death-in-town is the curtain call. Space any future NPC additions the same way: meet them in the dark, recruit them to the light.
3. **Vess's rule: name it and it's true.** Every future prestige perk gets one line of Vess dialogue naming it. This is a free, infinite flavor template — use it.
4. **Ilya's rule: the ledger remembers kindly.** Every system that tracks the player (cycle records, epitaphs, death counts) should read like Ilya wrote it — wry, warm, never mocking the player's failures. The game is hard; the *record-keeping* should be gentle.
5. **Death is a homecoming, not a failure screen.** The fiction must always move in the opposite direction from the difficulty: ramp goes up, warmth goes up faster. If a future system makes death feel punishing in-fiction, it fights the game's thesis.
6. **"The body is rented. The soul is owned."** — every permanent-progression decision should pass this test: does it attach to the soul (keep) or the body (lose)? If a designer can't answer, the progression is in the wrong place.
7. **Phone-first dialogue discipline held throughout:** no NPC speaks more than 5 short lines per meeting; barks use the existing HUD popup system; full beats are skippable and rare (4 per playthrough for the death-in-town full beat). Lore depth lives in *optional* prompts (Ilya's myth), never in the critical path.
8. **IP hygiene:** all names invented (Marla Bramble, Tovan Ashe, Sarella Vex, Pello Quin, Ilya Venn, Vess, Corva Ashen). "Half-Drowned God" is a descriptive title. No borrowed pantheons, no borrowed archetypes with serial numbers filed off. If a name ever feels familiar, rename it — the list above is cheap to change before art exists.

## Open questions for James

1. **Buff numbers:** proposed starters are Well Fed +10% max HP, Well Rested +15% regen, Well Armed +8% attack, Inspired +10% luck. Too strong / too weak against the floor-10 attempt-3 balance target? And should the four buffs scale with anything (guild stage? cycle count?), or stay flat forever?
2. **Breadcrumb reset on ascension:** the paper has the four NPCs re-meetable each cycle with a "you've done this before" line. Is re-earning the buffs each cycle good (a reason to re-delver early floors), or should ascension keep them permanently and the re-meetings be pure flavor?
3. **Ilya's gating:** the quiet room unlocks at guild stage 2, but prestige mechanics stay available from the death screen from day one. Right call? Or should Ilya be findable earlier — say, a tent by the dungeon entrance pre-tavern?
4. **Vess's HQ shrine:** the flooded shrine room at guild stage 4 where Vess is "sensed but never spoken to" — want it, or keep Vess strictly to the ascension ritual with no other presence at all?
5. **The death-in-town full beat:** 4 full plays per playthrough (first death after tavern + after each guild stage). Skippable with a tap, never auto-skipped. Good? And who else should be at the table in the stage-3/4 versions — any townsfolk beyond the core five?
6. **Pello = the death shop's face:** the paper makes Pello's ledger the in-world fiction for the death shop. Does that sit right, or should the death shop stay metaphysical/unofficial with Pello as just a trader?
7. **The tagline:** "The body is rented. The soul is owned." — store-page worthy, or too clever by half? Alternatives on the table: "Die. Remember. Descend." / "The dark keeps things. Not you."
8. **Corva Ashen stays a myth?** Confirm: she never appears, never a boss, never a ghost — or do you want the First Delver to show up somewhere down the line?
9. **Vess's voice:** written here as slow, fragmentary, half-remembered ("...a threshold. Again."). Does that read well in HUD popups on a phone, or should Vess speak more plainly?
10. **Epitaph pool:** Ilya's auto-generated one-line cycle epitaphs ("Cycle 3: reached depth 14. Died to a cave lurer.") — worth the content work (~20 templates to start), or cut it and keep the ledger purely numerical?

---

*Credits: design & writing by Milo, directed by James Greenlee ("Aethelwarden Solas"). Built for Abysmal — no AI-generated assets, staged CC0 only, per project rules.*

---

## Addendum 2026-10-10 — breadcrumb revision

**The trail is now 2/4/6/8/10.** James's Oct 10 decision revises the breadcrumb trail: a fifth NPC joins at depth 4, the existing NPCs shift down, and Pello at depth 10 now grants the tavern deed. Full revised schedule and rationale are recorded in `design-decisions-2026-10-10.md` §9; this addendum writes the new resident in the paper's style.

### Depth 4 — Harlan Slate, the miner → **Well Stocked (material yield)**

**Who.** A broad, dust-grey man in his forties with a lamp strapped to his brow and hands that look carved from the rock he works. He hums while he digs — old pit songs, half-remembered, in a voice roughened by stone dust.

**Backstory (one paragraph).** Harlan was a pit-hauler at the same mountain hold Sarella Vex smithied for — he carried her ore up out of the deep cuts for six years, and they knew each other by the sound of each other's work before they ever traded names. When the hold fell, Harlan was below it; he came up through the smoke into a world that had no use for a man whose whole trade was underground, so he walked *down* instead, following the bleedstone veins past where the maps end. He digs at depth 4 because the veins are richest where the dark is still thin — "the deep hoards its best rock for the patient, and I've got nothing but time." He stays because the surface forgot his hold's name, and down here the rock still remembers it.

**Where he stands.** A timbered dig: rough wooden supports braced against the cavern walls, a hand-cart half-full of broken ore, a sorting table where he grades stone by lantern-light, and a chalk tally on the rock face — his lifetime count of cartloads, still climbing. The pocket smells of dust and lamp-oil; the SFX layer should carry the distant *tink* of his pick between dialogue lines.

**The meeting dialogue (short — phone-first):**
- Harlan: "Ho! Mind the cart — she's loaded. You're the delver Marla's been feeding, aren't you. Sit a minute, the rock can wait. It always does."
- Harlan: "You walk past more wealth than you know, friend. See this? Bleedstone's cousin — worthless to a smith, but the deep's full of things that *aren't*. The trick's in the seeing."
- *[Well Stocked gained: +material yield]*
- Harlan: "There. I can't give you my eyes, but I gave your soul the habit of 'em — you'll pull more from every vein, every chest, every crack in the dark. The soul remembers the veins. Bodies just carry the pick."
- Harlan: "They say someone's buying that old tavern up top. A town needs a *mine*, friend, same as it needs a kitchen — somebody's got to know what's under it. *Come find me when you've bought it.* I'll read the ground for you."

**Flavor justification.** Well Stocked = +material yield because Harlan doesn't hand the player ore — he hands them *the habit of seeing ore*. It sits beside Sarella's "the soul remembers how to hit" as the same reincarnation logic applied to gathering: technique, not treasure, is what survives death. It also closes the breadcrumb's economy loop: Marla feeds the body, Harlan feeds the *materials* that feed the Undercrucible and the blacksmith.

**Foreshadow beat.** The mine line makes Harlan the town's future quartermaster of stone and ore — when the town exists, he's the reason the blacksmith's material stock and the town's building upgrades have a face. Depth 4 plants him exactly where the player first starts drowning in junk drops — and his buff makes that junk worth more.

### The revised trail — design summary table

| Depth | NPC | Trade | Buff | Soul-flavor | Town role |
|---|---|---|---|---|---|
| 2 | Marla Bramble | Farmer | Well Fed (+max HP) | The soul remembers being fed | Tavern kitchen |
| 4 | Harlan Slate | **Miner** | **Well Stocked** (material yield) | The soul remembers the veins | Town quarry / material stock |
| 6 | Tovan Ashe | Woodcutter | Well Rested (regen) | The soul learned how to rest | Tavern hearth / inn |
| 8 | Sarella Vex | Blacksmith | Well Armed (+attack) | The soul remembers how to hit | Guild blacksmith (crafts for gold) |
| 10 | Pello Quin | Trader | Inspired (+luck) **+ tavern deed** | The soul learned the habit of luck — and the town gets its home | Town market / death-shop face |

**Why the new order works.** The buffs still arrive in the order a struggling player needs them, with the economy arriving earlier: survivability (HP) → materials (yield — just as junk starts piling up) → sustainability (regen) → damage (attack) → economy (luck) → home (the deed). The story order gains a beat too: warmth → *labor* → quiet → defiance → hope → home.

**Harlan–Sarella thread (deliberate).** Harlan hauled ore for Sarella's forge for six years before the fall. They are the only two NPCs with a shared past — write it as mutual, unspoken recognition, never exposition. When both are in town, one idle line each: Sarella: "That one's swing is older than my forge." / Harlan: "She still owes me for six years of hauling. I'll collect in stew." Loose, warm, load-bearing — the town feels *inhabited* because its people knew each other before the player arrived.

### The tavern deed at depth 10

Meeting Pello at depth 10 now grants the **tavern deed** — player ownership of the tavern. Mechanically:
- The tavern becomes the player's **home base**: the first guild-hall stage is *owned*, not rented.
- **Death returns here once the guild hall is established** — the death-in-town beat (§4 of this paper) fires on the first death after the deed, exactly as designed; the deed is what *establishes* it.
- The deed is the breadcrumb trail's payoff: five meetings, five buffs, one home. Every "come find me when you've bought that old tavern" line in this paper now resolves through Pello handing the player the deed — he was the closer all along.

### Groundwork status

**NPCs still aren't embodied in-game.** This addendum — like the rest of the paper — is data-level groundwork only: buff schedule, story beats, dialogue text, the Harlan–Sarella thread, the deed mechanic. No pockets, no portraits, no barks are built. Embodiment is a later build phase; when it comes, Harlan's dig (timbers, cart, chalk tally, the *tink* of the pick) is specced above and ready.

---

*Addendum written Oct 10, 2026 — directed by James Greenlee ("Aethelwarden Solas"). IP hygiene: "Harlan Slate" is an original name; no borrowed lore, no borrowed archetypes.*
