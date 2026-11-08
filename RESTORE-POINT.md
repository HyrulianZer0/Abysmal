# ABYSMAL — RESTORE POINT

**Checkpoint:** 2026-10-12T13:20Z (Mon Oct 12, 9:20 AM EDT) — supersedes the Oct 11 8:20 PM checkpoint below. v0.10.0 HAS shipped (see Latest state); do not use the old "build still running / do not claim it finished" line further down — it is kept only as history.
**Purpose:** If interrupted (maintenance team, overnight, mid-task), read this first and resume with zero re-explaining.

## Latest state — Mon Oct 12, 2026 (supersedes In-flight section below)
- **v0.10.0 SHIPPED** — 47.6 MB APK, version code 12, installs over previous builds, same signature. New: first-person hands, denser floors (+33–37% rooms), gentler delve pace/depth curve, turn smoothing, dev cheats (8x cap / god mode / monster floor), door/ceiling fixes. Windows demo v4 for Jeff prepared from the same tree.
- **This week's ONE build token is spent.** Fixes and design work stay in the tree/notes only until the weekly reset (Oct 16) — no new release push before then, per James's rule.
- **Ceilings and doors: diagnosed and FIXED in the tree, riding next week's push.** Ceilings were missing over walkable space (only a thin wall crown existed) — real ceiling slabs now cover every open cell, plus a brick header over doors. Door fault root cause: the door artwork has transparent margins and Godot's box mesh crops the texture, so a tinted margin read as a flat gray half-door; doors rebuilt to show the full blue double door from either side. Bonus: the red shackle was buried inside the slab — now protrudes from both faces.
- **No block/flinch animation exists.** What James read as "blocking" (Oct 12) was the chest-open reach. Readability pass item: chest-open becomes a boot-kick of the lid, sword stays in hand.
- **Abyssal Token review done:** crossing floor 10→11 grants and saves a token, but it is announced only in the combat log, the token count is displayed nowhere, and Prestige/Ascension buttons are still Phase 2 stubs. Proposal on record: retire the token into the platinum/Ambrosia economy with the Soul Tree work, with a real award moment (banner, sound, visible counter) — not a patch.
- **Fresh install note:** updating over the old install hid the cheat menu; James's uninstall/reinstall restored it and runs smooth. x16 cannot corrupt anything — it is only a speed multiplier.
- **Dev slow-mo cheat (James's idea, logged):** 0.5x / 0.25x / 0.1x team-only speeds, complementing the speed cheat, for catching animation/visual issues.
- **Mimic design (Oct 12, full detail in design-notes/morning-briefing-2026-10-11.md):** Mimics are in under their own name (genre staple, not IP-locked). Two tiers — common **Mimics** (faint breathing, glisten along the lid seam) and rare ancient **Tsukumogami** (perfectly still, pristine/too fine for its depth — the richness is the tell). Perception double-check flags Mimics readily, Tsukumogami rarely. Unspotted Mimic gets a free first bite; spotted = player's choice to walk away or open it deliberately. Defeating a mimic pays double loot, increased quality, or both. Tsukumogami tier corrected by James: **mini-boss**, not boss-grade — beatable, avoidable once spotted, carries the floor's best loot.
- **Pace validated by James:** leisurely delve pace feels "relaxed and yet powerful — just right."
- **NPCs:** silhouettes acceptable for now; prefer models close to the existing style if possible.

## Evening decisions — Sun Oct 11, 2026 (7:21–7:53 PM EDT, dev-team side chat)
- **ALL current design questions are now answered.** Only the 4 eyeball checks remain, and they wait on the v0.10.0 build. James's standing instruction: keep adding new questions to the list as they surface; they'll all get addressed in time.
- **Undercrucible currency: Drossglass** — locked name (fusion of "Dross" + "Deepglass").
- **Build order: Soul Tree FIRST.** All parked systems (guild dispatch, Undercrucible, blacksmith crafting, platinum prestige, elements) will eventually be built, but the Soul Tree is the key to infinite growth — many, many branching paths — and everything else plugs into it.
- **Undercrucible extraction: FULL / unrestricted.** Item placement is all random, so extraction and hunting coexist; even an OP weapon is not enough as you delve deeper — depth itself is the safeguard. No drop-only protection tier.
- **Town/overworld: clipboard model, NOT a walked map.** Player manages town as if holding a clipboard (blueprints, available upgrades); tap a building → its menu loads; tap the clipboard → jump to another destination. Recliner-friendly, no walking commute.
- **Tavern/town unlock (fused scene):** tales of the player's delves reach other ears → a passing trader offers to sell the deed to an old run-down town with a tavern for gold → player signs and pays → building-management menu opens; brave adventurers arrive asking to help with the dungeon — this is how town income starts.
- **Forge house names: APPROVED as proposed** — Keenbrand (crits bleed), Marrowdeep (hits heal), Anvilborn (slow, huge, staggers), Vexwing (every swing hits 3×), Mirrorhold (riposte), Knell (executes the wounded). Clarification locked: houses are *behavior* identities (grew out of the Borderlands manufacturer research), NOT elements — elements live in the Charm slot (James's Oct 7 call).
- **Prestige economy REVISED (supersedes the old town-reset version below):** town generates **gold** → leveling up buildings gains **platinum** → platinum is spent on **prestige skills**. No town reset — the town matures instead of vanishing. Only open knob is pacing (platinum income vs Soul Tree cost curve) — tuning, not a design flaw.
- **Ascension requirement: Ambrosia — CANDIDATE, not yet explicitly locked by James.** James proposed it ("what do we need for ascension? Ambrosia?") while saying he was stuck on the question; Milo endorsed it (food of the gods; fits Vess the demigod keeper; ladder gold → platinum → Ambrosia; earned from apex bosses / Delve Endlessly milestones; would replace the old 3× Abyssal Token gate). James moved on to the build request without a separate confirmation — treat as strongly endorsed, confirm at build time if it matters.
- **NPC breadcrumb first names: tentatively approved as workable** — Marla, Tovan, Harlan, Sarella, Pello.
- **Versioning RESOLVED:** next release is **v0.10.0** (numbers are not decimals — 0.10, 0.11… can run for years; **1.0 is reserved for public launch**). Do NOT renumber down to 0.1.0 — it would collide with the v0.8.0 already on James's phone and in Jeff's/Fen's copies. Core dungeon is built and self-sustaining; everything from here is expansion.
- **NEW STANDING RULE (James, Oct 11 PM): at most ONE development push (release build) per week** — less taxing for James, Milo, and the system. Design talk/questions/fixes in the tree can still flow daily; only releases pace out.
- **Team status (James, Oct 11 PM):** Jeff's feedback still pending — he has been fighting for disability for a long time; James expects it may land sooner than he thinks. Fen (Justin) is saving for a new phone. Tristan works for a dental software company and is legally blind — **accessibility pass (large-text / UI-scale option) is now a listed item and a prerequisite before Tristan can test or play**; it gets a real pass, not a rush job.
- **Beta depth test reported 7:53 PM EDT:** depth 40 (38 on second run) with the new code, zero deaths at depth 6+ in those runs; skeleton confirmed fair (same scaling curve, designated brute — earlier death explained by stacking hunger ramp + possible crit at 16x); James's **10-minute watchdog fix proven** — a genuine 372-second no-progress gap rode through and cleared floor 10 (would have failed at the old 6-minute limit); all three soak seeds passed, zero stall trips.

## Pacing update — Sun Oct 11, 2026 (James's call)
- James is at **57% of his free weekly limit; it resets Thu Oct 16 at 3:18 PM EDT**. He asked twice to **pace ourselves** until then — one question at a time is a good day, nothing is on fire, no flooding.
- Scheduled tasks (reminders, Simon watch, chore rollovers, anime check) are saved to disk and persist even if the limit is hit; new heavy work should be held until after the Oct 16 reset where possible.
- **Open design questions: 15 total** — 11 answerable anytime (4 decisions: clock jumps, hardcore rules, tavern deed, pace default; 2 build-order picks; 2 naming calls; 3 design questions) + 4 eyeball checks that must wait for the next build (hands, ceilings, doors, moss). **SUPERSEDED Oct 11 PM: all 11 answerable questions were answered in the evening sweep (see Evening decisions at top); only the 4 eyeball checks remain.**
- **The 3 questions currently out to James** (laid out Sun Oct 11 ~1:20 PM EDT while he folds laundry / remakes the bed — answer by number, no rush):
  1. **Delve pace default** — Settings has leisurely (0.7x) / normal / swift (1.3x). Default to normal, or start gentler for new players?
  2. **Hardcore rules** — as built: death forfeits ALL carried gold + monsters ramp 5%/run, hidden toggle, default off. Approve as-is, or soften the gold part?
  3. **Clock jumps** — offline earnings currently pay in full even if the phone clock is set forward a year. Accept it, cap it at something sane, or add a confirm prompt on huge jumps?
- Note: questions 2 and 3 above are the same two items already listed under "James's calls" below — do not re-ask them as new. Question 1 (pace default) is new in this form.
- **UPDATE 18:25Z: all 3 questions were answered the same afternoon** — see "Afternoon decisions" below. Do not re-ask any of them.
- Unverified: the side chat on Oct 11 described v0.8.0 as "stable on your phone," while the build section below (Oct 10) said the APK was not yet installed. Confirm install status with James before relying on either.

## Afternoon decisions — Sun Oct 11, 2026 (~1:24–2:03 PM EDT, dev-team side chat)
- **Q1 Delve pace:** all three paces (leisurely / normal / swift) stay as an option, **dungeon-only** — nobody rushed, speedrunners free to rush a floor. (The narrower "default for new players" sub-question was not separately answered — don't re-ask unless it matters at build time.)
- **Q2 Hardcore: SCRAPPED.** Replaced by **Delve Endlessly** — one continuous run, no floor saved, death ends the run; a challenge mode, not a punishment. The hidden hardcore toggle built into v0.8.0 is superseded — do not promote it. Many more monster types still planned to fill Endlessly out.
- **Q3 Clock jumps: ANSWERED.** Soft cap, not a wall: full-rate offline earnings for **7 days** base → **1 month** after prestige → **1 year** after ascension; reduced rate beyond, no absolute end, no punishment screen. "Gotta make em work for it." This supersedes the old "full speed, NO cap" locked decision below.
- **Monster roster: DONE** — `design-notes/monster-roster-2026-10.md` (~300 base public-domain folklore creatures, 28 families, 16 named apex bosses; variants/attunements scale to James's ~1,000 ceiling). James's follow-up (2:01 PM EDT): **per-monster behaviors are the next work** — count alone won't hold skilled players; behaviors + mixed packs + attunements will.
- **Game thesis (James, word for word):** "the endless abyss is the endgame, with no end" — no limits on skill, prestige, or ascensions.
- **Room density:** James asked for more rooms squeezed into current floors — improved/increased but NOT maxed out. A density pass is visible in `scripts/dungeon_gen.gd` (modified Oct 11 18:20Z; MIN_ROOMS 10 / MAX_ROOMS 15, ~+40% per floor, area scaling kept). As of this checkpoint it had **not yet been reported to James** (at 2:03 PM EDT he was told it was "still cooking") — confirm before re-doing or re-announcing it.
- **Laundry:** done Sun Oct 11, five days early — the Oct 16 laundry + bed tasks are ticked complete in Google Tasks (checked clean by Milo; nothing wrong was ticked). Next laundry slot per the schedule: Oct 30.

## Done tonight (v0.8.0 build wave — verified in ~/workspace/build/)
- **v0.8.0 Android APK** — `idle-dungeon-roguelike-v0.8.0.apk` (48M, .idsig alongside, same signature, installs over 0.7.0). New: offline earnings full-speed/no-cap + "While You Were Away…" screen, hidden hardcore toggle (default off), plus all Oct 7–10 groundwork.
- **Windows demo v3** for **Jeff and Fen** — full `idle-dungeon-roguelike-windows-v3.zip` (58M) + **8 × 8MB Discord chunks** (`…-v3.zip.part01`–`part08`) + `idle-dungeon-roguelike-windows-v3-README.txt` (reassembly = `copy /b` command); reassembly byte-verified.
- Both builds reported to James in the **"abysmal dev team"** side chat at 8:35 PM EDT.
- Design notes updated: `design-notes/design-decisions-2026-10-10.md` records the finalized Oct 10 batch (superseded items marked).

## In-flight (not yet done as of checkpoint)
- **v0.10.0 build IN PROGRESS** (requested by James 7:45 PM EDT Oct 11) — full regression first, then APK (installs over 0.8.0, same signature) + fresh Windows demo for Jeff from the same tree. At the 7:53 PM EDT report the build was **still running**; no v0.10.0 artifact existed in ~/workspace/build/ at the 8:20 PM EDT checkpoint. This is this week's ONE development push under the new rule.
- Windows demo v3 chunks + README **not yet sent to Jeff and Fen** — James's action on Discord when ready. (v0.10.0 will produce a fresh Jeff demo from the same tree.)
- v0.8.0 APK install status on James's phone: afternoon note said playtested to depths 10–11 Oct 10–11 (see dev-team open threads) — the older "not yet installed" line is superseded; v0.10.0 will install over it anyway.

## Next actions (in order)
1. Finish v0.10.0, then James does the **4 eyeball checks** (hands, ceilings, doors, moss) — the only items left standing after the Oct 11 evening Q&A sweep.
2. Send the Windows demo (v0.10.0 tree) to Jeff and Fen when ready — James's action on Discord.
3. Build order from here: **Soul Tree first** (see Evening decisions), then the other parked systems. Accessibility pass (large-text/UI scale) is a prerequisite before Tristan can test.
4. Keep adding design questions to the list as they surface (James's standing instruction) — 3 at a time, no flooding. §12 leftovers in `design-decisions-2026-10-10.md` that the evening sweep did NOT explicitly close (backstab player bonus, soul bonuses vs old perk registry, Well Stocked tuning numbers, breadcrumb reset on ascension, how many elements, 2^N/10^N visible or hidden, Undercrucible in-world explainer) stay on the list — do not assume the prestige-economy revision or the clipboard-town call silently answered them; the town-reset-dependent one ("what platinum-bought town upgrades survive a reset") is **moot under the revised no-reset economy**.

## Locked decisions (do NOT re-ask)
- Offline earnings: full speed, infinite growth is the reward — **soft cap added Oct 11 PM** (full rate 7 days base / 1 month after prestige / 1 year after ascension, reduced rate beyond, no absolute end).
- Dispatch units can fail but always return with something; no permadeath.
- Undercrucible upgrades existing gear (materials in); blacksmith crafts new gear for gold.
- Death forgiving by default — **hardcore mode SCRAPPED Oct 11 PM**, replaced by Delve Endlessly (one continuous run, no floor saved, death ends it).
- Prestige = town loop — **REVISED Oct 11 PM (see Evening decisions): town generates gold, leveling buildings gains platinum, platinum buys prestige skills; NO town reset.** (Old version — town resets, soul bonuses carry — is superseded.) Ascension = world/universe loop (god status, much more rewarding); ascension gate candidate: **Ambrosia** (endorsed, not yet explicitly locked).
- Soul Tree: persistent, infinite, never resets; break-null = no stat caps; prestige ×2 and ascension ×2 compounding (M = 2^(p+a)); ~10^N platinum costs.
- Elements: damage types with resistances AND interactions (fire melts ice).
- NPC breadcrumb 2/4/6/8/10: farmer/Well Fed, miner/Well Stocked, woodcutter/Well Rested, blacksmith/Well Armed, trader/Inspired, tavern deed at 10. Buffs survive death.
- Rewards 2^N, costs 10^N.

## Standing rules
- **At most ONE development push (release build) per week** (James, Oct 11 PM). Design talk and in-tree fixes can flow daily.
- Side chat = dev-team deliverables; main chat = thought process + durable memory.
- Credits use pseudonym **"Aethelwarden Solas"** — real name stays off the project.
- Android first (phone + recliner, easier on his back); audio stays platform-agnostic; NO Nintendo modding/trainer routes (account safety).
- One step at a time, 3 questions at a time; plain step-by-step instructions, no jargon, no skipped clicks.
- Original names/lore only, no AI-generated assets, staged CC0 music only.
- Restore-point/checkpoint sections stay at the top of active work files (James's standing preference).
