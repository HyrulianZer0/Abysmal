# Design Notes — Gemini Design Session (Aug 2026, shared by James Sept 2026)

Source: James's August 2026 design conversation with Google Gemini ("First-Person Roguelike Incremental Games").
Saved for future test builds. These are James's own words/ideas — treat as canon design direction.

## The Core Vision
- **2.5D first-person incremental RPG roguelike**: Barony / Legends of Dragaea style grid dungeon crawling fused with Incremental Infinity style uncapped exponential math.
- One game, not a concept. James is the **director/producer** ("Agent A" — the vision; AI/devs work at his pace).
- **Godot 4** — free, open-source, MIT, no royalties. Chosen engine.
- Movement: **classic grid-step** (W/S step, A/D snap-turn 90°) — already our implementation.

## Math & Scaling (already aligned with our BigNumbers autoload)
- Uncapped exponential scaling into **scientific notation** (10^30, 10^100, 10^300).
- Suggested tech: **break-nihility** — a GDExtension port of break_infinity.js for Godot 4, handles values up to 10^300 without crashing GDScript. (Future upgrade path for our GDScript BigNumbers.)
- Action-driven uncapped skills, Barony-style: swinging a sword levels swordsmanship, taking hits levels defense — **no caps**, feeding exponential multipliers.
- **Prestige / Ascension / Transcend** loops: reset runs for massive global multipliers as monster/boss difficulty scales infinitely.

## Letter & Named Rarities — CANON (refined with James, 2026-09-26)
The full 39-rung ladder, sorted. Nothing cut.

**Mundane tiers:** Common → Uncommon → Rare → Epic → Legendary → Mythic → Exotic

**Letter tiers** (plus chains: each letter supports +1 through +9; "+" alone = +1):
F, F+ → E, E+ → D, D+ → C, C+ → B, B+ → A, A+ → S, S+ → SS, SS+ → SSS, SSS+
→ Ω, Ω+ *(the end of measurement)* → X, X+ *(unclassifiable)* → Z, Z+ *(past the end)*
→ ZZ *(way past the end)* → EX *(outside the system entirely)*
(Repeater letters like AAA/XXX deemed excessive — dropped. Story-ordered Ω→EX per James.)

**Cosmic / abstract tiers:** Cosmic → Astral → Void → Eldritch → Transcendent → Infinite

## Prestige & Ascension — CANON (2026-09-26)
- **Prestige (ladder reset):** climb the rarity ladder, then prestige — ladder resets to Common, drops start over. Each prestige permanently multiplies weapon/armor **base power**: ×2 per prestige, compounding (P1 = ×2, P2 = ×4, P3 = ×8…). Each climb goes faster and pushes higher.
- **Ascension (star refinement):** the bigger reset. Each ascension grants a **★ refinement** (★1, ★2, ★3…), a global overlay multiplier on everything — e.g. each ★ = ×10. Displayed on gear: "SSS+ ★3 Iron Sword".
- Example: 10 ATK sword, Prestige 3 (×8), SSS tier (×1000), ★2 (×100) = 8,000,000 ATK.
- Rhythm: climb → prestige (gear stronger) → climb higher → ascend (earn a star) → repeat, stars forever.

## Dungeons (future content)
- Procedural, endless, **50+ themes** (sci-fi, ancient, medieval, cosmic...).
- Suggested tech: **Gaea** — open-source procedural generation addon for Godot 4.
- Endless floor scaling with exponential enemy stat multipliers per floor.

## Town Building & Guild (long-term meta game)
- Build a town from a **tiny tavern → bustling metropolis**: inns, shops, mines, lumber yards, part-time community jobs.
- **Guild system**: hire NPC adventurers, dispatch guild squads to raid the dungeon and farm resources for you while you manage the town.
- This is the "incremental infinity" endgame wrapper around the crawler. Big scope — far future.

## Team
- **Jeff the Ferret** — James's friend, may join as co-op/dev partner. James planned to send him these notes via Steam chat (Aug 2026 plan).
- James posted a condensed version of this pitch to Godot project-help threads on Discord.

## Skills — CANON (designed with James, 2026-09-26)
RuneScape-style meets incremental infinity. 14 skills, level-by-doing, no level cap (virtual levels past 99, scientific notation). Each skill prestiges independently: hit 99 → **Master** it → resets to 1 with a permanent ×1.5 stacking multiplier to that skill's effect. Skills are the progression that STAYS — gear resets each run, skills persist unless mastered by choice. Death shop sells skill unlocks.

**Design principle ("almost overpowering"):** every skill compounds multiplicatively per level (×1.01–1.02 typical). At 99 that's ×2.7–7 per skill; across 14 skills the player feels godlike — for their depth. Enemy power scales ×~1.2 per depth, so depth always eventually wins. XP costs grow exponentially (RS-style curve), so the treadmill never ends.

**Combat (stat boosters):**
1. **Attack** — +1.5% damage/level (accuracy + crit flavor)
2. **Strength** — +2% melee damage/level
3. **Defense** — +1.5% damage reduction/level
4. **Vitality** — +2% max HP/level
5. **Agility** — +1% dodge chance/level (cap 60%), +move speed

**Delving:**
6. **Dungeoneering** — XP per floor descended; +idle delve speed, better stairs
7. **Lockpicking** — chests/locked doors; rarer chests, disarm traps
8. **Stealth** — shrinks monster detection radius
9. **Perception** — +sight/minimap radius, secret rooms
10. **Luck** — the loot engine: more drops, better rarity, more gold. Fuels the keep-playing loop and the death-shop economy (absorbs old Salvaging + Greed)

**Crafting:**
11. **Smithing** — reforge gear base power (synergy with prestige ×2 loop)
12. **Alchemy** — brew/upgrade potions from drops
13. **Enchanting** — pushes drops UP the rarity ladder

**Survival:**
14. **Regeneration** — passive HP regen/level

Future (combat systems don't exist yet): Ranged, Magic.

## Future discussion points (James, 2026-09-26 — not for current builds)
- Accessibility options
- Dungeon textures: old, moss-covered stone. Must tile seamlessly (unique + symmetrical, no visible seams) — James explicitly does not want anything that reads as "AI slop"
- Character models: proper models for the monsters already in the game (current roster)
- Audio: dark fantasy RPG vibe; copyright-free temp music + SFX (volume sliders by number in options). Alkakrab free packs (no-AI, no copyright) grabbed 2026-09-26 → assets/audio/alkakrab/. **Credits: "Producer/Director: Aethelwarden Solas" (pseudonym — James's real name stays off the project). "Special thanks to Alkakrab for their music". James's legacy wish: publish the finished game on itch.io with an "In memory of James" dedication.** Bookmarked for possible later purchase: [Dark Fantasy Studio](https://www.gamedevmarket.net/asset/dark-fantasy-studio-immortals), [PixelLoops dungeon pack](https://pixelloops.itch.io/fantasy-dungeon-music-pack-dark-rpg-dungeon-loops)
- **Death shop**: ✅ IMPLEMENTED 2026-09-26 (code complete, no APK cut yet) — Brotato-style, on the death screen: 4 random charm offerings (8 stackable permanent charms: Blood Vial, Whetstone, Iron Plate, Lucky Coin, Scholar's Quill, Alchemist Flask, Troll Salve, Hunter's Mark; re-roll for gold; Luck skill adds offerings up to 6) + Skills tab with the canon 14 (10 purchasable/wired: Attack, Strength, Defense, Vitality, Agility, Dungeoneering, Stealth, Perception, Luck, Enchanting, Regeneration; Lockpicking/Smithing/Alchemy shown as coming soon). Catalog in `scripts/shop.gd`; buy logic + effect mults in `game_state.gd`; tabs in death panel (`hud.gd`). Regression: `tests/buy_check_scene.tscn`.
- **Options → loot filter** (idle behavior presets): gather room-by-room / clear the whole floor / straight to the exit (brave mode — extra hard, pairs with the coming monster floor)
- **Monster floor**: ✅ IMPLEMENTED 2026-09-26 (code complete, no APK cut yet) — a special floor event, Barony-minotaur-style. A horde of weak/average monsters (slimes + bats only). Intent is to OVERWHELM, not kill — survivable! The challenge is being surrounded (action economy), not a death trap. Tuning knobs (all in `dungeon_gen.gd`): `MONSTER_FLOOR_CHANCE` 0.12, `MONSTER_FLOOR_MIN_DEPTH` 2, `HORDE_MULT` 3, `HORDE_CAP` 80; horde attack softened ×0.6 in `main.gd`. Log announces "The air grows thick… MONSTER FLOOR!" Beta results: 12-min forced-horde stress passed (2 floors cleared, 0 deaths, p95 frame 7ms headless).
- Room-by-room loot AI tweak (enter room → grab loot while fending off monsters) — queued, pending final confirmation

## What this means for upcoming builds
- Keep one-step-at-a-time pacing (James's ADD/ADHD).
- Next systems in the pipeline per James: armor/weapons depth (Phase 2 gear), skills, magic, prestige, ascension — placeholders already in HUD.
- When we outgrow GDScript big numbers, evaluate break-nihility.
- Rarity ladder expansion and town/guild systems are parked until core loop is solid.

## Guild & town long-term vision (James, 2026-09-26)
- **Transition:** player goes from personal delving → guild/town management, with the option to delve personally anytime (rescues, expeditions, pushing max depth).
- **Hirelings:** random names/stats, injury timer on "death" (NOT permadeath — lighter on device resources, less punishing). They delve with the same idle autoplay brain; player watches via guild board and collects loot/cut.
- **Guilds:** Adventurers guild PLUS Thieves, Mages, Warriors, Archers, Clerics (healing magic) — nod to the anime *I Parry Everything*. Each guild should get a mechanical identity (e.g. thieves find more loot/secret rooms, warriors hold hordes, clerics sustain parties).
- **Town buildings:** blacksmith, tavern, temple, inn (travelers), houses (residents). Town level gates hireling quality — the exponential growth engine.
- **Comeback loop (confirmed):** death should make the player stronger via dungeon gear + death shop skills, never weaker. Per-death monster ramp capped at +50% (implemented 2026-09-26 in `main.gd` hunger_mult).

## Guild decisions (James, 2026-09-26)
- **Unlocks:** major guilds are free to join; sub-guilds/specializations cost time and sometimes gold, depending on relevance and lore.
- **Class switching:** free/instant between major-guild classes (FFXIV armory style); switching into a specialization costs time + sometimes gold.
- **Multiclassing:** unlimited — any citizen can learn ALL classes, each leveled independently (FFXIV-style, not Tree of Savior's pick-3 lock-in).
- **Hireling delves:** both solo and parties.
- **Names:** generic fantasy names safe to use; FFXIV-coined ones (Gunbreaker, Pictomancer, Viper, Reaper) get renamed.

## FFXIV name swaps (James's picks, 2026-09-26)
- Gunbreaker → **Gunblade**
- Pictomancer → **Inkmage**
- Viper → **Serpent**
- Reaper → **Harvester**
- Astrologian → **Oracle**
All other FFXIV job names used as-is (generic fantasy terms).
