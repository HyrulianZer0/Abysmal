# The 39-Rung Rarity Ladder — Implementation Plan for Abysmal
*Written Oct 8, 2026. Builds directly on the Borderlands parts-gating model (section 7 of `borderlands-loot-research-2026-10.md`) and the canon ladder already stored in `scripts/items.gd` (from the 2026-09-26 canon session in `gemini-design-session-2026-08.md`).*

**What this paper is:** a concrete, buildable plan for turning the canon 39-rung ladder from data (it already exists as `RARITY_LADDER` in `items.gd`) into the live loot system: which rungs exist, what each rung changes mechanically, how the current 4-tier fixed items migrate onto it, how names are generated, how Luck interacts with it, how it relates to the game's exponential scaling, and the build order.

**What this paper is not:** a replacement of the Borderlands parts model. Parts generation is the *horizontal* variety; the ladder is the *vertical* power. This paper maps the two together, rung by rung.

**One canon discrepancy to flag up front:** the task brief for this paper suggested rung 1 be **"Fine"** (Common → **Fine** → Rare → Epic …). The canon ladder James refined on 2026-09-26 — and the one already implemented in `items.gd` — uses **"Uncommon"** as rung 1. This paper keeps canon ("Uncommon"). The current fixed item list uses "Fine" for its second tier, which creates a migration question — addressed in §5, and listed as an open question for James in §11.

---

## 1. The 39 rungs, explicitly

The canon ladder, rung index 0–38, weakest → strongest. Total: **7 mundane + 26 letter + 6 cosmic = 39.** ✓

### Mundane tiers (rungs 0–6) — the part-unlock climb
| Rung | Name | Color (canon) | What it means mechanically |
|---|---|---|---|
| 0 | Common | gray `#9aa0a6` | Forge + Blade only. Plain, readable, disposable. Drops from the first floor. |
| 1 | Uncommon | green `#4caf50` | + Hilt slot unlocked. Slightly better part grades. |
| 2 | Rare | blue `#4488ff` | + Guard slot unlocked. |
| 3 | Epic | purple `#b044ff` | **Charm slot unlocked** — the chase begins. Better part grades across the board. |
| 4 | Legendary | orange `#ff9915` | All 5 slots + **one signature behavior** (a forge-house legendary quirk, not just stats — see §3). |
| 5 | Mythic | red `#ff4433` | Legendary part structure (all 5 slots + signature). Power rung. |
| 6 | Exotic | gold `#ffd84d` | Legendary part structure. Power rung. The "you'll remember this drop" tier of the mundane band. |

### Letter tiers (rungs 7–32) — the pure-power climb
Each letter has a plain rung and a `+` rung (the `+` = "one step past," per James's canon: plus chains support +1 through +9, with bare `+` = +1). Story flavor per canon notes is preserved.

| Rung | Name | Color | Meaning |
|---|---|---|---|
| 7 | F | dull bronze `#8c7b5c` | Letter ladder starts. Below-average-by-new-standards gear; the game is telling you the old ladder was just the tutorial. |
| 8 | F+ | `#a08d6a` | Power rung. |
| 9 | E | `#9c8f6b` | Power rung. |
| 10 | E+ | `#b0a179` | Power rung. |
| 11 | D | `#aba184` | Power rung. |
| 12 | D+ | `#bcb294` | Power rung. |
| 13 | C | `#b5b5a8` | Power rung. |
| 14 | C+ | `#c6c6ba` | Power rung. |
| 15 | B | `#b9c6cc` | Power rung. |
| 16 | B+ | `#cbd8de` | Power rung. |
| 17 | A | `#aed6e8` | Power rung — "good" gear by letter standards. |
| 18 | A+ | `#c2e2f2` | Power rung. |
| 19 | S | `#9fe8f5` | Power rung — the classic "super" threshold. |
| 20 | S+ | `#b5f0fa` | Power rung. |
| 21 | SS | `#a5f5e8` | Power rung. |
| 22 | SS+ | `#bcf7ee` | Power rung. |
| 23 | SSS | `#b8ffd8` | Power rung. |
| 24 | SSS+ | `#d0ffe4` | Power rung — the prestige-design paper's example tier (×1000 in the P3/★2 example). |
| 25 | Ω | `#e8fff0` | **"The end of measurement."** Narrative beat: the appraisal system gives up. Power rung with Epic-grade part structure minimum. |
| 26 | Ω+ | `#f5fffa` | Power rung. |
| 27 | X | `#d8b8ff` | **"Unclassifiable."** The forge that made this doesn't exist in any registry. Power rung. |
| 28 | X+ | `#e6ccff` | Power rung. |
| 29 | Z | `#b890ff` | **"Past the end."** Power rung. |
| 30 | Z+ | `#c9a8ff` | Power rung. |
| 31 | ZZ | `#a878ff` | **"Way past the end."** Power rung. |
| 32 | EX | white `#ffffff` | **"Outside the system entirely."** The letter ladder's capstone: no longer measurable, only witnessed. Power rung. |

All letter tiers use the **Legendary part structure** (all 5 slots + signature behavior) — per the Borderlands paper's §7 rule, "Exotic and letter tiers: pure power rungs; parts rolled at Epic/Legendary structure." We standardize on Legendary structure for the full letter band (simpler than splitting Epic/Legendary mid-band, and the signature behavior is the fun part).

### Cosmic / abstract tiers (rungs 33–38) — the endgame band
| Rung | Name | Color | Meaning |
|---|---|---|---|
| 33 | Cosmic | indigo `#5a3fae` | Legendary structure + signature behavior. Post-letter power. |
| 34 | Astral | blue `#7a9fff` | Power rung. |
| 35 | Void | deep purple `#3a245e` | Power rung. |
| 36 | Eldritch | green `#4fff8a` | Power rung. |
| 37 | Transcendent | pale gold `#ffe89e` | Power rung. |
| 38 | Infinite | magenta `#ff9eff` | The top of the ladder. Power rung. Nothing above it by design. |

**Honest caveat:** the letter and cosmic bands are 32 rungs of "pure power" with identical part structure. That is a lot of rungs where the *only* difference is numbers going up. This is intentional — it's the idle-game power fantasy, and the prestige loop (§8, and the gemini canon: prestige resets the ladder to Common, ×2 compounding base power per prestige) exists precisely to make re-climbing it feel fast and good. But it means the letter band's *legibility* has to come from somewhere other than mechanics: colors, names, the announcement moment (OSRS-style rare-drop broadcast from the loot research paper), and the town-hall trophy display. Do not try to invent 26 different mechanics — that way lies the Borderlands "too fiddly" list.

---

## 2. Parts-gating per rung (the Borderlands §7 model, mapped explicitly)

Restating the §7 rule in one line: **rarity gates part access, not just numbers.** Here it is pinned to the 39-rung list:

- **Rung 0 (Common):** Forge + Blade only. Two slots, no prefix (nothing left to prefix *with* — see naming §6).
- **Rung 1 (Uncommon):** + Hilt unlocked. Prefixes begin here (best of Hilt).
- **Rung 2 (Rare):** + Guard unlocked. Prefix = best of Hilt/Guard.
- **Rung 3 (Epic):** + **Charm slot unlocked**. Prefix = best of Hilt/Guard/Charm. This is the first rung where the drop can have the excitement slot — the Borderlands "purple/orange guaranteed accessory" beat.
- **Rung 4 (Legendary):** all 5 slots + **one signature behavior**. Prefix = best remaining part. The signature behavior is the BL4 "3 + 1 unique legendary behavior" rule adapted: 5 normal slots, plus one forge-house signature quirk that only rolls at Legendary and above (e.g. a lifesteal-forge blade that also refunds a potion charge on kill — one gimmick, learnable in seconds, never a paragraph).
- **Rungs 5–6 (Mythic, Exotic):** Legendary structure (all 5 slots + signature). Power rungs.
- **Rungs 7–32 (F → EX):** Legendary structure. Power rungs.
- **Rungs 33–38 (Cosmic → Infinite):** Legendary structure. Power rungs.

Part *grades* (the quality of the roll within a slot, e.g. a Swift hilt rolling +8% vs +12% attack speed) also scale with rung: Uncommon rolls grade 1–2, Rare 1–3, Epic 2–4, Legendary+ 3–5. Grades are the "within-rung" variance so two Epic drops of the same forge/blade still differ.

**Why this shape:** the first four rungs (0–3) are the *tutorial of desire* — each rung visibly adds a piece to the weapon, teaching the player the parts language. By Epic, the player understands the whole system. Everything after is the power chase, and the signature behavior at Legendary+ is the personality chase. "Easy, though not too easy" — the player always understands what got better.

---

## 3. Signature behaviors (Legendary and above)

One per forge house (proposed house names in §6 — names are still James's call). Rules:

1. **One gimmick each**, learnable in seconds — the Borderlands manufacturer rule.
2. Only rolls at rung ≥ 4 (Legendary and up).
3. Never pure stats — it must change *behavior* (on-kill effect, on-hit trigger, conditional bonus), because stats are what rungs already do.
4. Original names/lore only (IP hygiene, standing rule).

These are *examples*, not canon — James approves the real list:

| Forge house (proposal) | Combat verb | Example signature behavior |
|---|---|---|
| Ashvein | crit | "Crimson Ledger": crits mark the enemy; killing a marked enemy refunds 1 potion charge |
| Deepwake | lifesteal | "Tidecall": overhealed lifesteal becomes a 5s damage shield |
| Stonehowl | slow-heavy | "Avalanche": every 4th hit deals double damage and stuns 1s |
| Quickfell | flurry | "Hundred Cuts": attack speed briefly spikes after a dodge |
| Stormmark | elemental | "Skyburst": every 10th hit calls lightning on the enemy's position |
| Ironbell | counter/parry | "Answering Bell": successful parry echoes 50% of the blocked damage back |

Six houses is the top of the "4–6" range from the Borderlands paper. Four would be simpler; six gives the prefix/title name pool more texture. James's call.

---

## 4. Drop-roll mechanics: how a rung is chosen

Current code (`items.gd::_tier_for_depth`): `base = clamp(depth/3, 0, 3)`, jitter ±1, then a 12%-plus-Luck "lucky find" bump of +1 tier. The 39-rung version generalizes this:

```
rung_for_depth(depth, rng, luck_shift_chance, enchant_shift_chance):
    base = depth_to_rung(depth)          # the depth curve, see below
    rung = base + rng.randi_range(-1, 1) # jitter, clamped to 0..38
    if rng.randf() < luck_shift_chance and rung < 38:
        rung += 1                        # Luck: rarity-shift, existing behavior
    if rng.randf() < enchant_shift_chance and rung < 38:
        rung += 1                        # Enchanting skill: second shift source
    return rung
```

**The depth curve** (`depth_to_rung`): the design decision that controls pacing. Proposal — piecewise, so the mundane band is the early game and letters are the long tail:

- Depths 1–20: rungs 0–6 (Common → Exotic). Roughly 3 depths per rung.
- Depths 21–60: letter band, ~1.5 depths per rung, F → EX across 40 depths.
- Depth 61+: cosmic band opens; rung 38 (Infinite) first reachable around depth 90+.

This is a *proposal* — the curve is the single most tuning-sensitive number in this paper and should be exposed as constants (`RUNG_DEPTH_MUNDANE_END = 20`, etc.) in `items.gd`, not buried in logic. The idle promise ("easy, though not too easy"): a fresh run should see its first Uncommon within the first few floors and its first Epic (Charm unlock!) before depth ~12 — the Charm slot appearing early is the hook.

**Jitter stays ±1 rung.** With 39 rungs, ±1 is a small, readable variance instead of the current system's ±1-of-4 (which is huge). Good — drops feel depth-appropriate, Luck provides the spikes.

---

## 5. Migration path: the current 4-tier fixed list

Current fixed items (`items.gd`):

| Current item | Current "rarity" | Target rung |
|---|---|---|
| Rusty Dagger / Cloth Rags | Common | **0 (Common)** — direct |
| Iron Sword / Leather Armor | Fine | **1 (Uncommon)** — nearest canon slot; see the Fine question below |
| Steel Sword / Iron Plate | Rare | **2 (Rare)** — direct |
| Starforged Blade / Starforged Mail | Epic | **3 (Epic)** — direct |

**The "Fine" problem:** "Fine" exists nowhere on the canon ladder. Options: (a) treat Fine as a legacy alias for Uncommon (recommended — same green color family, same position as "second tier"); (b) keep "Fine" as a display-only legacy label on migrated items. Recommend (a): alias it, don't preserve it. Fewer special cases.

### Save-data migration sketch

Item dicts in saves currently carry `"rarity": "Fine"` etc. as strings. Migration:

```gdscript
# Legacy aliases resolved once at load; never written back.
const LEGACY_RARITY_ALIASES := {"Fine": "Uncommon"}

static func migrate_item(item: Dictionary) -> Dictionary:
    var r := str(item.get("rarity", "Common"))
    r = LEGACY_RARITY_ALIASES.get(r, r)
    var idx := rarity_index(r)  # already exists in items.gd
    if idx < 0:
        idx = 0  # unknown rarity -> Common, never crash on old data
    item["rarity"] = r            # canonical name from here on
    item["rung"] = idx            # new: integer rung index, the source of truth
    return item
```

Rules:
1. **Old items keep working.** `gear_score()` and `better()` don't touch rarity — they compare stats. Equipped legacy items stay equipped, still compare, still sell. Nothing the player owns breaks.
2. **`rung` (int) becomes the source of truth** for all new logic (part gating, name generation, drop rolls). The `rarity` string stays for display and save readability.
3. **Migration runs once per item at load**, guarded by the presence of the `rung` key — items that already have it skip migration. Idempotent by construction.
4. **New drops always write both** `rarity` (canonical name) and `rung` (index).
5. The canon `RARITY_LADDER` table is append-only by policy: never reorder, never rename, only append. `rarity_index()` results are stable across versions. (If James ever wants a rung inserted mid-ladder, that's a versioned migration — flag it then, not now.)

---

## 6. Naming conventions: Forge + Blade = Title, best part = Prefix

The Borderlands paper's §5 rule, formalized as generator logic:

```
generate_name(forge, blade, parts: Dictionary, rung: int) -> String:
    title = forge.title_word + " " + blade.blade_word   # e.g. "Ashvein Cleaver"
    if rung == 0:
        return title                                     # Common: no prefix, nothing earned it
    candidates = parts except (forge, blade)             # hilt, guard, charm
    best = the part with the highest grade; ties -> charm > guard > hilt
    prefix = best.prefix_word                            # e.g. "Swift", "Warden's", "Ember"
    return prefix + " " + title
```

Notes:
- **The prefix is earned information.** It names the best-rolled remaining part, so "Swift Ashvein Cleaver" tells the player at a glance: Ashvein forge (crit house), Cleaver blade (slow, heavy), and the hilt rolled Swift (attack speed) at the best grade. Two-second read on a phone — the Borderlands paper's legibility rule.
- **Common items get no prefix** (rung 0 rolls no other parts — nothing to name). This makes the first prefix drop (Uncommon+) a small event: the weapon *gains a word*.
- **Letter/cosmic tiers** use the same generator; the rung is displayed as a tag, never baked into the name: `"SSS+ ★3 Swift Ashvein Cleaver"` (matches the gemini canon display format `"SSS+ ★3 Iron Sword"`). Rung tag + optional ascension stars are suffix/prefix metadata, not part of the generated name. This keeps the name pool clean across prestiges.
- **Armor** mirrors the scheme with its own slot words (armor parts: forge mark + plate/weave + lining + ward + charm — exact armor slot names are a later paper; the generator logic is identical).

### Examples

**Low rung — depth 2 drop:**
- Parts: Forge Ashvein + Blade Cleaver, no other slots (rung 0).
- Name: **"Ashvein Cleaver"**
- The item card shows: gray Common tag, ATK 2-ish, flavor line (one line, original lore).

**Mid rung — depth 14 drop:**
- Parts: Forge Deepwake + Blade Duelist, Hilt Swift (grade 3, best), Guard Warden (grade 2), Charm Ember (grade 2).
- Name: **"Swift Deepwake Duelist"**
- Purple Epic tag, charm icon visible. The player reads: lifesteal forge, fast blade, fast hilt.

**Top rung — depth 95 drop:**
- Parts: Forge Stormmark + Blade Piercer, Hilt True (grade 5), Guard Bulwark (grade 4), Charm Echo (grade 5, best), signature behavior "Skyburst".
- Name: **"Echoing Stormmark Piercer"** (prefix form of Echo: "Echoing" — prefix words need morphological variants; store both, e.g. `prefix: "Echo"`, `prefix_adj: "Echoing"`)
- White EX tag + ★ stars, signature behavior gets its own red-text line on the card (the "excitement slot" treatment).

**Prefix word list** (proposal, 3–4 per part per the simplicity cap): Hilt — Swift, True, Steady; Guard — Warden's, Duelist's, Bulwark; Charm — Ember, Leech, Echo, Rune. All original words, no IP collisions.

---

## 7. Luck interaction: the rarity-shift across 39 rungs

Current state: the Luck skill gives "+2% gold, +1% rarity luck per level" (shop.gd), and `items.gd` implements the "lucky find": a `0.12 + bonus_luck` chance to bump **one tier** on a 4-tier ladder. The Enchanting skill "pushes drops UP the rarity ladder" (canon).

The design question: on a 4-rung ladder, a +1 shift is enormous (25% of the ladder). On a 39-rung ladder, +1 is a 2.6% move — the same mechanic becomes nearly invisible. Options considered:

1. **Linear shift (recommended):** keep the mechanic exactly as-is — a per-drop chance to shift +1 rung (Luck) and a separate smaller chance for a second +1 (Enchanting). The shift is *small per drop* but it applies to *every drop*, and idle games are about volume: across hundreds of drops per session, the rung distribution visibly creeps upward. "Luck stays the player's friend" — it should feel like a tailwind, not a jackpot button.
2. **Scaled shift** (shift size grows with depth/rung — e.g. +1 in mundane, +2 in letters): rejected. It makes the mechanic harder to explain and creates weird breakpoints. Publish one rule.
3. **Diminishing shift** (shift chance falls off at high rungs to protect the chase): partially adopted — see the cap below.

**Proposed formula:**

```
luck_shift_chance  = 0.12 + 0.01 * luck_level        # the existing "lucky find", unchanged
enchant_shift_chance = 0.02 * enchanting_level       # Enchanting: rarer, the second push
# Diminishing guard: above rung 24 (SSS+), each shift chance is halved.
# Above rung 32 (EX), shift chances are quartered. Rung 38 can never shift up.
```

The diminishing guard is the chase protection: SSS+ and above stay *earned by depth*, not by Luck procs. Below that, Luck is the tailwind James wants it to be.

**Transparency rule** (from the OSRS lesson in the loot research paper): the game publishes exactly what Luck modifies. The Luck skill's description becomes: *"+2% gold/level; drops have +1%/level chance to shift one rung up the rarity ladder (reduced above SSS+)."* No myths, no datamining needed.

**Honest caveat:** at 39 rungs, even a generous shift chance means most individual drops won't shift — the *feel* of Luck could go flat compared to the current 4-tier game where 12%+ of drops visibly jump a tier. Counterweight: the death screen's run summary should show a "Luck procs this run: N" line, and the rare-drop announcement moment (OSRS lesson) fires on any shift that crosses a *part-gating boundary* (Uncommon→Rare, Rare→Epic, Epic→Legendary — the rungs where the weapon visibly gains a slot). A shift from D to D+ gets no fanfare; a shift from Rare to Epic gets the trumpet. Fanfare follows meaning, not numbers.

---

## 8. Power scaling: rung vs. the exponential curves

Three multiplicative curves already exist or are canon:

1. **Depth scaling (implemented):** weapon ATK ×(1 + 0.12×(depth−1)), armor DEF the same. Enemies scale ×~1.2/depth (canon design principle).
2. **Per-death monster ramp (implemented):** +2%/run, capped +50% (`hunger_mult` in main.gd; resolved down from +5% on Oct 7).
3. **Prestige (canon):** ladder resets to Common; each prestige permanently ×2 base power, compounding. **Ascension (canon):** each ★ ≈ ×10 global.

The rung multiplier must sit *between* depth scaling and prestige in feel: noticeable per rung, but not so steep that the depth curve stops mattering.

**Proposed rung multiplier:** `rung_mult(r) = 1.14^r`, applied to the item's base stats at generation.

- Rung 0 → ×1.0. Rung 6 (Exotic) → ×2.19. Rung 24 (SSS+) → ×23.2. Rung 32 (EX) → ×66.5. Rung 38 (Infinite) → ×153.
- Sanity check against the gemini example: "10 ATK sword, Prestige 3 (×8), SSS tier (×1000), ★2 (×100) = 8,000,000 ATK." That example implies SSS ≈ ×1000 — far steeper than 1.14^24 ≈ ×23. **These don't have to match** — the example was illustrative ("e.g."), not canon. But the gap is worth naming: if James wants SSS to feel like ×1000, the per-rung base needs to be ~1.33 (1.33^24 ≈ 1065). 1.33/rung makes the mundane band explode too fast (Exotic ×7.6 at depth ~20 — probably fine actually, since enemies scale ×1.2/depth and depth always wins per the canon principle). **Recommendation:** start at 1.14, expose as `RUNG_GROWTH = 1.14`, and tune after the first balance pass — the constant is one line, the playtest data is the real answer. This is the "easy, though not too easy" knob: if early runs stall, raise it; if drops trivialize depths, lower it.
- **Interaction with the death ramp:** the +2%/run monster ramp (cap +50%) is *per run*, the rung curve is *per drop*. They compose correctly by design: each death makes monsters slightly stronger, which pushes the player slightly deeper-or-luckier, which unlocks the next rung band, whose drops outpace the ramp — the OSRS "each era's chase item is the key to the next tier" beat from the loot research paper. The ramp cap (+50%) means the treadmill has a ceiling; the ladder doesn't. Late game is ladder-vs-depth, not ladder-vs-ramp. That's the intended shape.

**Big-number note:** 1.14^38 with prestige ×2^P and ★ ×10^A will overflow float64 display eventually — the gemini notes already flag evaluating break-nihility when GDScript big numbers outgrow. Not this phase's problem; note it and move on.

---

## 9. UI / display rules

- **Rung tag format:** `[SSS+ ★2]` prefix on the item name in lists; full color chip in the item card. Colors are already in `RARITY_LADDER` — use them, don't invent new ones.
- **Item card layout (proposal):** name (generated) → rung tag + stars → forge-mark icon + house name → stat block → parts list (each part on its own line with its grade pips) → signature behavior red-text line (Legendary+) → one-line flavor text.
- **Grade pips:** 5 pips per part, filled to grade. Cheap to render, instantly readable.
- **The ladder codex:** a view (death shop tab or town building later) showing all 39 rungs, with discovered rungs colored and undiscovered grayed — the collection metagame. "Discovered" = has ever dropped. This is the long-tail engagement for the letter band: 39 checkboxes.
- **No Item Score** (Borderlands paper §6, rejected — the rung *is* the score).

---

## 10. Phased rollout (buildable steps)

Each phase is independently shippable and testable. Nothing here rewires drops until Phase 2, honoring the `items.gd` comment ("Do NOT rewire drops to this ladder until a later build").

- **Phase 1 — Data model (small).** Add `RUNG_GROWTH`, depth-curve constants, `LEGACY_RARITY_ALIASES`, and `migrate_item()` to `items.gd`. New drops write `rung` (int) alongside `rarity` (string). Unit tests: alias map, migration idempotency, `rarity_index` stability. *Ships: nothing visible changes.*
- **Phase 2 — Drop roll (medium).** Replace `_tier_for_depth` with `rung_for_depth` (§4): depth curve + ±1 jitter + Luck shift + Enchanting shift + diminishing guard. Map the 4 legacy fixed items onto rungs 0–3 via the migration table (§5). The fixed item *names* stay for now (Rusty Dagger still drops — it's just rung 0 now). Balance test: simulate 10k drops per depth band, check rung distribution vs. the depth curve. *Ships: 39-rung drops, old names.*
- **Phase 3 — Parts generation (large).** Implement the 5 slots with 3–4 variants each, part grades 1–5, and the per-rung gating table (§2). Forge houses as data (names pending James — use `FORGE_1..6` codenames until approved). Stats derive from parts: blade sets base profile, other parts modify. *Ships: generated items replace the fixed list.*
- **Phase 4 — Naming (medium).** The `generate_name` logic (§6) + prefix word lists + rung-tag display + grade pips in the item card. *Ships: every drop has a readable generated name.*
- **Phase 5 — Signature behaviors (medium).** One per forge house, Legendary+ only (§3). Needs the combat hooks (on-kill, on-crit, on-parry events) — coordinate with combat.gd. *Ships: Legendary+ drops feel legendary.*
- **Phase 6 — Chase layer (medium).** Ladder codex (39-rung collection view), rare-drop announcement on part-boundary shifts, "Luck procs this run" in the death summary. *Ships: the letter band becomes engaging, not just numbers.*
- **Phase 7 — Armor parity (later).** Mirror the slot scheme for armor (its own part words). The generator logic is identical; the content is new.

Explicitly **not** in this plan: the Converter (death-shop item sink — that's the next research paper, per the loot paper's #1 steal), enchantment library / Rune charms (tied to the Converter), set bonuses, reforging (Smithing skill, canon but unwired).

---

## Design takeaways

1. **The canon ladder was already right — this paper just gives it mechanics.** 7 mundane + 26 letter + 6 cosmic = 39, already in `items.gd`. Don't redesign the ladder; wire it up.
2. **Rarity = part access, not just numbers** — the single most important sentence in this paper, inherited from the Borderlands research. The mundane band (rungs 0–6) teaches the parts language one slot at a time; everything above is power + personality.
3. **The prefix is earned information.** Common items get no prefix because they've earned no parts. The first prefixed drop is a micro-event. Names are UI.
4. **Luck stays linear and published.** One shift rule, diminishing guard above SSS+, exact text in the skill description. No myths.
5. **The letter band's engagement comes from the codex and the fanfare, not from mechanics.** 26 power rungs can't each have a gimmick — don't try. Collection + announcement + prestige rhythm carry it.
6. **Migration is boring on purpose.** Alias "Fine" → Uncommon, add an int `rung`, keep old items working. The most dangerous migration is the one that tries to be clever.
7. **One-line tuning knobs:** `RUNG_GROWTH`, the depth-curve constants, the diminishing-guard thresholds. The balance pass tunes constants, not systems.

## Open questions for James

1. **"Fine" vs "Uncommon":** canon (and the code) says Uncommon; this paper's brief suggested Fine. This paper aliases Fine → Uncommon in migration. Confirm: is "Uncommon" the final word, or do you want "Fine" back on the ladder?
2. **Forge house names:** §3 and §6 use placeholder proposals (Ashvein, Deepwake, Stonehowl, Quickfell, Stormmark, Ironbell). Approve, rename, or cut to four houses?
3. **Rung growth rate:** 1.14/rung proposed (§8), vs the gemini example's implied ~1.33 (SSS ≈ ×1000). Which feel are you after — steady climb or rocket numbers?
4. **Depth curve:** mundane band across depths 1–20, letters 21–60, cosmic 61+ with Infinite first reachable ~depth 90 (§4). Too fast, too slow, or right?
5. **Diminishing guard on Luck:** shift chances halved above SSS+, quartered above EX (§7). Does that protect the chase enough, or should top-rung shifts be impossible without depth?
6. **EX display:** canon color for EX is pure white `#ffffff` and Infinite is magenta `#ff9eff` — so the *second-highest* rung is the flashiest color. Intentional (EX = "outside the system," Infinite = the actual top)? Or swap?
7. **Armor slots:** mirror the weapon's 5 slots with armor-flavored words, or a different slot set? (Phase 7 — no rush, but the naming generator needs the word lists eventually.)
8. **The Ω/X/Z/ZZ story beats** (§1): the flavor glosses ("the end of measurement," "unclassifiable," "past the end") come from the code comments. Do you want short lore lines for these rungs in the codex, or keep them mysterious?

---
*Related: `borderlands-loot-research-2026-10.md` (§7 parts-gating), `loot-drop-progression-research-2026-10.md` (Luck transparency, announcement moments), `minecraft-dungeons-loot-research-2026-10.md`, `prestige-design-2026-10.md`, `gemini-design-session-2026-08.md` (canon ladder, prestige/ascension). Code: `scripts/items.gd` (`RARITY_LADDER`, `WEAPON_TIERS`, `ARMOR_TIERS`), `scripts/shop.gd` (Luck skill).*
