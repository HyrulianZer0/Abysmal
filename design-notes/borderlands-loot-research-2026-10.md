# Borderlands Loot Generation — Design Reference for Abysmal
*Researched Oct 7, 2026. James's brief: richly randomized yet readable loot, adapted for melee weapons, simplified not complex. All mechanics summarized in original wording with source links — no wiki tables reproduced verbatim.*

## 1. Parts-based procedural generation (the core system)

**Borderlands 1 (2009).** Marketed as "87 bazillion guns" (well over 17 million actual). Gearbox described an AI/gear-builder: define manufacturers, materials, weapon classes, and component pools (barrels, scopes, stocks), then let the software assemble guns. Whatever drops is final — the chase is finding the great roll. Noted criticism: pure stat randomization felt like "+10% vs +11% damage" — variety without personality. Sequels fixed this with manufacturer identity.

**Borderlands 2.** The refined formula. Each gun assembled from part slots:
- **Body** — determines the gun's manufacturer, therefore its most fundamental behavior.
- **Barrel** — biggest performance lever.
- **Grip** — handling. **Sight** — optics (white-rarity guns get no real sights). **Stock** — stability. **Elemental Capacitor** — imbues element; absent = plain bullets. **Accessory** — optional extras, guaranteed on purple/orange.

Two legibility rules: **Barrel + Body = the weapon's Title** (base name), standout parts grant a **Prefix**. Parts are visually distinct per manufacturer — readable at a glance.

**Borderlands 3.** Same skeleton; big change: **per-manufacturer part suites** (every maker has its own complete part sets, more cohesive per brand). ~69.4M weapons (~4B with anointments). Added: alt-fire modes, alien-infested parts, Item Score (single quick-read power number), **Anointments** — red-text mutators triggered by action-skill use, layered on top of rarity, not a tier.

**Borderlands 4 (Sept 2025).** **Licensed Parts**: one gun can mix traits from multiple makers (~30B combos). The steal-worthy structure: **rarity gates licensed-part count** (Common 1 → Uncommon 2 → Rare 3 → Epic 4 → Legendary 3 + 1 unique legendary behavior). Gearbox also deliberately made legendaries rarer again after BL3 devalued them — "added the magic back to the loot chase."

## 2. Manufacturers as identity (the "forge houses" template)

BL2's eight makers, each with **one signature behavior, one visual language, one naming style**: Jakobs (huge semi-auto damage, never elemental), Maliwan (always elemental), Torgue (everything explodes), Vladof (fire rate climbs while held), Hyperion (reverse recoil — more accurate the longer you fire), Dahl (burst when aiming), Tediore (reload by throwing the gun — it explodes), Bandit (enormous mags, poor everything else). BL4 newcomers follow the same one-gimmick rule.

**Translation for Abysmal:** 4–6 original "forge houses," each one combat gimmick learnable in seconds — crit-house, lifesteal-house, slow-heavy-house, flurry-house, elemental-house, counter/parry-house. The forge mark is the melee equivalent of the gun Body: sets personality, and (per BL2's Title rule) **Forge + Blade determines the weapon's name**.

## 3. Rarity tiers — what each tier actually changes

White → Green → Blue → Purple → Orange. The mechanical truth: **rarity controls part access, not just numbers.** White: no real sight, no accessory — visibly plain. Purple/Orange: guaranteed accessory; better part grades. BL4 formalized it: rarity = how many special parts can appear.

## 4. The melee precedent: Tiny Tina's Wonderlands

Gearbox already solved "Borderlands parts for melee" in the fantasy spin-off with the same procedural tech: Element group (0–1), Blade Mod group (1–2: damage vs. crit variants), Hilt group (attack speed / crit / status variants), plus Hilt Mods as the on-hit excitement slot (lifesteal on hit, cooldown refund on hit, etc.), and melee manufacturers with one-gimmick identities. **Proof the system ports cleanly to swords with just 3–4 part groups.**

## 5. Melee parts proposal for Abysmal (5 slots, per the simplicity rule)

- **Forge mark** (Body analog) — sets personality/gimmick + visual style; with Blade, names the weapon. 4–6 forge houses.
- **Blade** (Barrel analog) — the damage profile, biggest stat lever. Variants: Cleaver (high dmg, slow), Duelist (fast, low dmg), Piercer (high crit), Crusher (armor-shred).
- **Hilt** (Grip analog) — handling: Swift (+attack speed), True (+crit chance), Steady (+status chance).
- **Guard** (Stock analog) — defense/utility: Warden (+block), Duelist (+parry window), Bulwark (+damage reduction on hit taken).
- **Charm** 0–1 (Accessory analog) — the excitement slot, only rolls at Rare+: Ember (fire), Leech (lifesteal), Echo (on-kill effect), Rune (socket for the death-shop enchantment library).

**Naming (BL2 Title/Prefix rule, simplified):** Forge + Blade = Title ("Emberfall Cleaver"); best-rolled remaining part = Prefix ("Swift Emberfall Cleaver"). Every drop gets a readable name evaluable in under two seconds on a phone.

**Charm as the chase:** like BL2 accessories (guaranteed only at purple+), the Charm slot stays empty on Common/Uncommon — it's the thing you hope for. The Rune-charm variant plugs into the Dungeons-II-style enchantment library concept: a persistent, upgradeable enchantment collection in the death shop, socketed into weapons.

## 6. What NOT to steal (too fiddly for an idle phone game)

1. Anointment micromanagement (BL3) — pure build-fiddling overhead.
2. Licensed-parts maximalism (BL4) — cap part pools at 3–4 variants/slot for phone readability.
3. Mayhem-style run mutators — the per-death +5% ramp already covers this.
4. Item Score chasing — the 39-rung ladder already serves this.
5. Manufacturer weapon-type exclusions — every forge house makes every melee type, for simplicity.

## 7. Rarity chart integration (the 39-rung ladder)

**Don't add rungs — gate parts instead (the BL4 licensed-parts model).** The 39-rung ladder (Common→Exotic plus F→EX) stays as the *power* ladder. Borderlands generation becomes the *horizontal* variety within each rung:
- **Common:** Forge + Blade only. Plain, readable, disposable.
- **Uncommon:** + Hilt. **Rare:** + Guard. **Epic:** + Charm slot unlocked; better part grades.
- **Legendary:** all 5 slots + one signature behavior (BL4's "3 + 1 unique legendary behavior" rule).
- **Exotic and letter tiers (F→EX):** pure power rungs; parts rolled at Epic/Legendary structure.

The Charm slot staying empty at low rarity *is* the chase.

## 8. IP hygiene (James's standing rule)

Steal the system, rename everything. None of these go into Abysmal: any manufacturer name, "Anointed"/anointments, "Eridium," any flavor text or item names from the games. Write original forge-house names, original lore, original bark text. Practical guidance, not legal advice — trademark search before commercial release still applies.

## Design takeaways (simplified-but-deep)

1. **Parts are stats you can see.** One part sets identity — turns "millions of combinations" from noise into a readable loot language.
2. **Rarity = part access, not just bigger numbers.** Higher rarity literally unlocks more of the weapon. Map onto the 39-rung ladder unchanged.
3. **One gimmick per forge house, learnable in seconds.** 4–6 houses, each a single combat verb. If a house needs a paragraph to explain, cut it.
4. **The Charm slot is the chase.** Keep it empty at low rarity so its appearance means something — and the Rune variant ties into the death-shop enchantment library.
5. **Name every drop with Forge + Blade (+ Prefix).** Two seconds to read on a phone. The name IS the item card.

Sources: Borderlands Wiki (Weapon Components, Manufacturer), MentalMars (BL2/BL3/BL4 weapons, Wonderlands melee), RPS, VG247, G2A, TweakTown, GameUpNews, DeltiasGaming, GamesRadar, Lootlemon, PCGamesN, WindowsCentral — full URLs in ~/workspace/research/abysmal-borderlands-loot-reference.md
