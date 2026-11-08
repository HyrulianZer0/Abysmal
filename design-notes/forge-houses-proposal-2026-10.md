# Forge Houses — Six Original Behavior Identities for Abysmal's Melee Parts System
*Design proposal, Oct 8, 2026. Builds directly on the melee parts system in borderlands-loot-research-2026-10.md (Forge mark / Blade / Hilt / Guard / Charm slots; Forge + Blade = Title, best part = Prefix). All house names, lore, and flavor below are original — written for Abysmal, not borrowed. All numbers are provisional tuning starting points, not promises.*

## 1. The confirmed rule: houses are behavior, not elements

James's call, restated as the load-bearing constraint of this paper: the **Forge mark** sets a weapon's personality — one combat gimmick plus a visual style. **Elements live in the Charm slot** (Ember, and whatever elemental charms join it later). The two systems must never do each other's job.

Why this matters mechanically: if houses were elemental, the Forge axis and the Charm axis would be one axis wearing two hats — "fire house + fire charm" would be redundant instead of interesting. Behavior × element is multiplicative: 6 behaviors × N charms × 4 blades is a real possibility space, and it's what makes two fire swords feel like different weapons.

**The acceptance test for everything in this paper:** an Ember (fire) charm socketed into a crit-house sword must produce a weapon that *fights completely differently* from the same Ember charm socketed into a lifesteal-house sword — different rhythm, different build-around, different screen. Section 3 runs that test concretely.

## 2. The six forge houses

Each house: one gimmick learnable in seconds, its visual language, example names under the Forge + Blade = Title / best-part = Prefix rule, a provisional tuning starting point, and notes on how it reads in auto-combat (Abysmal is idle — the player is *watching*, so house identity has to survive a phone screen with no hands on it).

---

### Keenbrand — the crit house
**Gimmick:** critical hits open bleeding wounds. Every crit also applies a bleed-over-time. Learnable in three words: *"crits make them bleed."*

**Visual language:** surgical. Needle-narrow blades in bright silver-white steel; hairline etchings along the fuller converging to an off-center needle point; a pale blue-white glint on the edge. Fittings are minimal and precise — no ornament, just edge.

**Example names:** *True Keenbrand Piercer* (True Hilt prefix), *Swift Keenbrand Duelist*, *Keenbrand Cleaver*.

**Tuning start:** bleed deals ~60% of the triggering crit's damage over 3 seconds; refreshes rather than stacks (keeps the ticker budget sane — see §7).

**Idle read:** the screen fills with small red bleed ticks blooming off big yellow crit numbers. Unmistakable.

**Synergy notes:** the natural partner of the Piercer blade (high crit profile) and the True Hilt (+crit chance) — the prefix practically writes itself. Bleed is damage-over-time, which scales gracefully into the per-death +2% monster ramp: this house gets relatively stronger the deeper the ramp goes. That's a feature (it's the "late-run" house), not a bug — but watch it doesn't become the *only* answer past +30% (see §7).

---

### Marrowdeep — the lifesteal house
**Gimmick:** a share of damage dealt returns as health. Learnable in three words: *"hits heal you."*

**Visual language:** vampiric. Dark oxblood channels cut into blackened steel like veins; bone-white hilt wrappings; a faint wet sheen along the blade, as if it never quite dries.

**Example names:** *Leech Marrowdeep Cleaver* (Leech charm prefix), *Ember Marrowdeep Crusher*, *Marrowdeep Duelist*.

**Tuning start:** ~10% of damage dealt returned as HP. No overheal banking (keeps the math honest).

**Idle read:** the health bar visibly ratchets upward mid-fight — the "unkillable" fantasy, on screen.

**Synergy notes:** this is the sustain answer to the per-death ramp — longer runs, deeper delves, bigger death payouts. Critical design point: lifesteal must *extend* runs, never make them endless. Death is the economy's heartbeat (death-shop visits, Converter fuel); a house that deletes death deletes the loop. Cap effective sustain against ramped enemy damage and consider diminishing returns on continuous in-combat healing (§7).

---

### Anvilborn — the slow-heavy house
**Gimmick:** ponderous, enormous swings that stagger enemies. Learnable in four words: *"slow, huge, knocks them senseless."*

**Visual language:** brutalist. Thick slab blades of dark rough-forged iron; visible rivets and hammer marks; a weight-forward silhouette that looks like it wants to fall on something.

**Example names:** *Steady Anvilborn Crusher* (Steady Hilt prefix), *Bulwark Anvilborn Cleaver*, *Anvilborn Cleaver*.

**Tuning start:** ~35% slower swing, ~2.1× damage per hit, and hits carry a stagger chance that briefly interrupts enemy attacks.

**Idle read:** the screen *shakes* on every hit; enemies visibly flinch and lose their attack wind-up. The most tactile house to watch.

**Synergy notes:** stagger is soft mitigation — the "stand your ground" answer to the +2%/run ramp, as opposed to Marrowdeep's "out-heal it" or Knell's "skip the HP pool" (below). Boss rule needed: bosses should resist or ignore stagger while taking full damage, or this house trivializes the executioner's job (§7, open question 6).

---

### Vexwing — the flurry house
**Gimmick:** every swing lands a rapid flurry of small cuts instead of one blow. Learnable in three words: *"hits three times."*

**Visual language:** insectile. Narrow wasp-waisted blades with an iridescent oil-sheen finish; chitin-dark fittings; a feather-light silhouette — the blade looks fast standing still.

**Example names:** *Swift Vexwing Duelist* (Swift Hilt prefix), *Echo Vexwing Cleaver*, *Vexwing Piercer*.

**Tuning start:** 3 strikes per swing at ~45% damage each (≈1.35× total, with the variance smoothed across the flurry rather than gambled on one roll).

**Idle read:** a buzzing storm of small white numbers — the "death by a thousand cuts" fantasy, instantly distinguishable from Anvilborn's single screen-shaking slam.

**Synergy notes:** multi-hit means multi-proc — this house is the strongest charm synergy in the game *by construction* (Echo's on-kill effects, Leech's lifesteal, Ember's burn applications all trigger per hit). Either embrace that as the house's build-around identity ("the proc house") or normalize charm procs per swing. Decide early in tuning; don't discover it late (§7, open question 7). Tech note: flurry triples hit events — VFX must be pooled or Android pays for it.

---

### Mirrorhold — the counter/parry house
**Gimmick:** turning blows aside — when struck, a chance to parry the hit and answer with a devastating riposte. Learnable in four words: *"turns their hits back."*

**Visual language:** serene. Mirror-polished steel, perfect symmetry, concentric ring engravings on the guard, a calm blue-grey palette. The only house whose blades look *calm*.

**Example names:** *Warden Mirrorhold Piercer* (Warden Guard prefix), *Mirrorhold Cleaver*.

**Tuning start:** ~15% base parry chance when hit (scaling with the Guard part — Warden/Bulwark are this house's natural partners); a successful parry answers with a riposte at ~2.5× damage.

**Idle read:** the flash of the parry ring, then the single huge riposte number. The "patience rewarded" house.

**Honesty note:** the auto-delver cannot time parries, so this is a stat-driven chance, not a skill-timed mechanic. The in-game fantasy copy must say "turns blows aside," never "parry at the right moment" — don't promise a timing game the idle format can't deliver. The fantasy survives fine: the *blade* defends itself.

---

### Knell — the executioner house (the sixth pick)
**Gimmick:** the lower the enemy's health, the harder it hits — strikes below a threshold execute outright. Learnable in three words: *"finishes the wounded."*

**Visual language:** funereal. Blackened steel fading to deep violet at the edge; tiny bell motifs etched along the fuller; somber, quiet, final.

**Example names:** *Rune Knell Cleaver* (Rune charm prefix — socket for the death-shop enchantment library), *True Knell Piercer*, *Knell Crusher*.

**Tuning start:** +100% damage vs. enemies under 30% HP; enemies under 10% HP are executed outright (no overkill damage wasted).

**Idle read:** the tolling-bell kill effect on executes — a signature screen moment no other house has.

**Synergy notes:** this house interacts with the per-death ramp in the most interesting way of the six — executes don't care about +50% HP pools the way raw DPS does, making Knell the "boss killer" answer to ramped content. Boss rule needed: no full executes on bosses (bonus damage only, or a halved threshold), or the boss farm collapses to one house (§7, open question 6). Pairs beautifully with the Rune charm: socket a persistent enchantment-library effect into the weapon that specializes in finishing.

*Why executioner over momentum:* momentum (attacks accelerate the longer a fight lasts) was the runner-up, but it overlaps with Vexwing's speed fantasy and Anvilborn's pacing contrast. Executioner gives the roster a sixth *distinct verb* — none of the other five care about the enemy's health bar. (If James prefers momentum, it swaps in cleanly — open question 2.)

---

### The six at a glance

| House | Verb (one gimmick) | Palette | Signature screen moment |
|---|---|---|---|
| Keenbrand | crits bleed | silver-white, needle etchings | red bleed ticks off yellow crits |
| Marrowdeep | hits heal you | oxblood veins on black steel | health bar ratcheting up mid-fight |
| Anvilborn | slow, huge, staggers | rough dark iron, rivets | screen shake; enemies flinch |
| Vexwing | every swing hits 3× | iridescent oil-sheen, wasp-waisted | buzzing storm of small numbers |
| Mirrorhold | turns hits back | mirror polish, blue-grey, ring engravings | parry flash → huge riposte number |
| Knell | finishes the wounded | black-to-violet steel, bell motifs | tolling-bell execute effect |

## 3. The fire-sword test: same charm, two houses

Two Epic drops, both socketing an **Ember** (fire) charm. Per the acceptance test, these must be different weapons demanding different builds — not the same sword in different colors.

**Ember Keenbrand Cleaver — the spike weapon.** Critical hits ignite: crits apply burn stacks on top of the bleed, so the fantasy is *spike windows* — watch for the yellow number, then watch the burn bloom. Build-around: crit chance everywhere (True Hilt, Piercer blade, Luck feeding charm procs). Against packs it's feast or famine; against a single tough enemy it's a detonation timer. The player checks this weapon hoping for crit rolls.

**Ember Marrowdeep Cleaver — the attrition weapon.** Burn ticks feed you: the house lifesteal applies to burn damage as well as direct hits, so the fantasy is *set everything on fire and drink the flames* — slower kills, near-immortal against packs, weaker against burst damage that outpaces the trickle. Build-around: burn duration and coverage (Steady Hilt for status chance, anything that spreads the fire wider). The player checks this weapon hoping for burn rolls.

Different verbs (spike vs. sustain), different stat priorities, different screens, different deaths. The house gimmick *inflects* the charm rather than sitting beside it — and that inflection is a general principle: crits spread burn, burn feeds lifesteal, flurry multi-procs Echo, stagger interrupts extend burn uptime, ripostes can carry charm effects, executes end burn early (Knell's one anti-synergy, which is itself interesting — do you *want* the burn to finish, or the bell to toll?). Keep each pairing to one sentence; there is no matrix to memorize, just verbs meeting adjectives.

## 4. The forge mark, visually: readable in first-person at phone distance

Abysmal is 2.5D first-person — per the design notes, gloved hands and a visible weapon are always on screen. The forge mark has to read at a glance, in peripheral vision, while the weapon is mid-swing. Four layers, cheapest first:

1. **The sigil.** Each house gets one simple geometric maker's mark, etched or faintly glowing on the blade near the guard: Keenbrand a needle-slash, Marrowdeep a droplet/forked vein, Anvilborn an anvil-chevron, Vexwing a triple-stroke, Mirrorhold concentric rings, Knell a bell outline. One shape, high contrast, learnable in a single drop.
2. **Palette + finish.** The house material language (silver-white vs. oxblood-black vs. rough iron vs. iridescent vs. mirror vs. violet-black) does the heavy lifting at distance — you know the house before you read the sigil.
3. **Silhouette bias.** Blade width/length lean per house (Anvilborn wide, Vexwing narrow, Keenbrand needle-long) via non-uniform scale on shared meshes — silhouette reads even in motion blur.
4. **Charm particle tint on top.** The elemental charm adds its particle color over the house base — an Ember Keenbrand blade is silver-white with fire licking the edge; an Ember Marrowdeep blade is oxblood-black with fire in the veins. House first, element second, always.

**Honest asset caveat:** staged CC0 only — Quaternius models, flakdeau textures, no bespoke meshes per house, no AI-generated assets ever. That means differentiation comes from palette swaps + decal sigils + scale bias + particle tints, not unique geometry. That's *enough* at phone viewing distance and it keeps the mesh budget Android-safe. If a house can't be told apart from the others with a palette swap and a decal, the house's visual language is wrong — fix the language, not the budget.

## 5. Rarity and houses: gate parts, not houses

Following the BL4 licensed-parts model from the research paper — **rarity controls part access, not just numbers** — applied to the 39-rung ladder as the *power* axis with houses as the *horizontal* variety axis:

- **All six houses roll at every rarity.** A Common Keenbrand Cleaver still crit-bleeds — it just has no Hilt, Guard, or Charm yet. The gimmick *is* the mark, and the mark is always on. (If houses were rarity-gated, low-rarity drops would be identity-less grey mush — the exact failure the personality system exists to fix. Rarity-gating houses would also teach players that Commons aren't worth reading, which poisons the whole loot-reading habit the naming system is built on.)
- **Rarity gates slots, per the existing proposal:** Common = Forge + Blade; Uncommon adds Hilt; Rare adds Guard; Epic unlocks the Charm slot; Legendary = all five slots at top part grades **plus one signature house behavior** (the BL4 "3 + 1 unique legendary behavior" rule). Examples: Legendary Keenbrand — crits chain-bleed to nearby enemies; Legendary Knell — execute threshold applies at half value to bosses; Legendary Mirrorhold — ripostes strike all nearby enemies. One signature each, designed with James, not in this paper.
- **The 39-rung ladder is untouched.** No new rungs, no rung reordering — houses are variety *within* each rung, exactly as the Borderlands paper framed it.
- **Charm-slot gating is the chase.** The Charm slot staying empty below Rare is what makes its appearance mean something — and the Rune variant ties the whole system into the death-shop enchantment library (Dungeons-II-style persistent enchantments, socketed into run-disposable weapons).

## 6. Why behavior-houses beat element-houses (the long-term argument)

1. **Elements are a damage color; behaviors are verbs.** Fire-vs-ice collapses into a weakness spreadsheet the player solves once and never thinks about again. Flurry-vs-stagger-vs-riposte-vs-execute changes *how the fight looks and feels* — and in an idle game, how the fight looks and feels is the product, because the player is watching, not steering.
2. **No redundancy with the Charm slot.** Charm is already the elemental/excitement axis. An elemental house would be a second element system fighting the first for meaning — two systems, one job, half the clarity.
3. **Multiplicative combos, not additive skins.** 6 behaviors × N charms × 4 blades means "Ember Knell Piercer" and "Ember Marrowdeep Piercer" are different builds with different stat priorities (§3). Element-houses would give you "fire sword, but the fire is... also fire."
4. **Fantasy attachment.** Players say "I'm a Knell player" the way Borderlands players say "I'm a Jakobs guy." Nobody says "I'm a fire guy" with the same loyalty — elements are tools, houses are identities. Anecdotal, but it's the load-bearing kind of anecdotal for retention: identity is what survives balance patches.
5. **Cleaner balance surface.** Six behavior knobs that don't touch the elemental weakness table — you can nerf lifesteal sustain without touching fire damage, buff stagger without touching burn. Element-houses would entangle every tuning change with the whole weakness matrix.
6. **Idle-legibility.** You can *see* the difference between houses on an auto-playing screen (flurry of numbers vs. screen-shake slam vs. bell-toll execute). Elemental differences are particle tints — pretty, but not gameplay. In a game you watch, "watchable difference" is gameplay.

## 7. Balance & idle-game caveats (honest)

- **Marrowdeep vs. the death loop.** Sustain delays death; death is the economy's heartbeat (death-shop visits, Converter fuel, the per-death ramp itself). Lifesteal must extend runs, never make them endless — cap effective sustain against ramped enemy damage, and consider diminishing returns on continuous in-combat healing past ~30 seconds. If a Marrowdeep build can idle forever at +50% ramp, the loop is broken, not the house.
- **Vexwing proc math.** Three hits × per-hit charm procs = the strongest charm synergy in the game by construction. Embrace it as the house's build-around identity ("the proc house") or normalize charm procs per swing — but decide in the tuning pass, not after players build around it.
- **Mirrorhold honesty.** Stat-driven parry chance, not timed parries — the auto-delver can't time anything. In-game copy must never promise a timing game. (Stated in §2; repeated here because it's the easiest promise to accidentally make in flavor text.)
- **Anvilborn stagger vs. bosses.** Stagger must be heavily resisted or ignored by bosses (full damage still applies), or the stagger house trivializes the executioner house's boss-killer niche.
- **Knell executes vs. bosses.** No full executes on bosses — bonus damage only, or a halved threshold. Otherwise the boss farm collapses to one house and the other five are leveling toys.
- **Keenbrand vs. the late ramp.** Bleed (DoT) scales beautifully into high-HP pools, so this house gets relatively stronger as the +2%/run ramp climbs. Fine as the designated "late-run" house — just watch it doesn't become the only correct answer past +30%.
- **Android performance.** Vexwing triples hit events; Keenbrand adds concurrent DoT tickers. Pool hit VFX, cap concurrent tickers, budget it in the tech pass — not as a hotfix after the frame rate dies on a mid-range phone.
- **Luck's role is deliberately unassigned here.** The merged Luck skill feeds the death shop and the global lottery per the loot research — whether it should also weight house rolls is James's call (open question 4).
- **All numbers provisional.** Every percentage and multiplier in §2 is a starting point for the tuning pass, not a promise. The gimmicks are the design; the numbers are dials.

## 8. IP hygiene (James's standing rule)

Steal the system, rename everything — per the research papers. None of Borderlands' manufacturer names, no "Anointed"/anointments, no Eridium, no Diablo or Minecraft names, no borrowed flavor text or item names. All six house names, sigils, and lore above are original to Abysmal. Practical guidance, not legal advice: trademark-search the final house names before commercial release, same as the title check already noted for "Abysmal."

## Design takeaways

1. **Houses are verbs, charms are adjectives.** Never let the two systems do each other's job — the day a house *is* an element, the design has collapsed a dimension.
2. **One gimmick per house, learnable in seconds.** If a house needs a paragraph to explain, cut it. All six pass: crits bleed / hits heal / slow huge stagger / hits three times / turns hits back / finishes the wounded.
3. **The mark is always on.** Houses roll at every rarity; rarity gates parts, not identity. A Common should still teach you what its house *is*.
4. **The fire-sword test is the acceptance criterion** for every future house: same charm, different house = different weapon, different build, different screen. Any proposed seventh house that fails it doesn't ship.
5. **Design for the watcher.** In an idle game, house identity must read on an auto-playing phone screen — silhouette, palette, sigil, and one signature screen moment per house.
6. **Six is a starting roster, not a cap** — but every addition pays the same toll: one verb, one visual language, the fire-sword test, and a boss-rule decision.

## Open questions for James

1. **Final house names are your call.** Keenbrand, Marrowdeep, Anvilborn, Vexwing, Mirrorhold, Knell are proposals — rename, merge, or veto any of them. Nothing here is precious.
2. **Sixth-house pick:** I went with Knell (executioner). The runner-up was momentum (attacks accelerate the longer a fight lasts — the "warm-up" house). Which fantasy do you want in the roster?
3. **Name collision found:** "Duelist" is currently both a Blade variant *and* a Guard variant ("Duelist Mirrorhold Duelist" reads silly as a prefixed title). Suggest renaming the Guard variant — candidates: *Riposte* (+parry window, though it leans into Mirrorhold's theme), *Sidestep*, *Dancer*. Your call.
4. **Should Luck touch houses?** Options: (a) Luck stays out of the forge system entirely; (b) the death shop offers a "favor a house" weighting for a run's drops; (c) Luck subtly weights toward houses matching your equipped build. Luck stays the player's friend either way — this is about where the friendship applies.
5. **Legendary signature behaviors:** one unique twist per house at Legendary (the BL4 "3 + 1" rule, §5) — yes, or keep Legendary as max parts + best grades with no extra behavior?
6. **Boss contract:** confirm stagger heavily resisted on bosses, no full executes on bosses (bonus damage / halved threshold instead). Any exceptions (e.g., mini-bosses fully executable)?
7. **Vexwing proc policy:** embrace multi-proc as the house's build-around identity, or normalize charm procs per swing so no house is the "correct" charm house?

---
*Prepared for James (director), morning reference — Oct 8, 2026. Design credit: Aethelwarden Solas.*
