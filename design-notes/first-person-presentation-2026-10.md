# First-Person Presentation — Abysmal
*Design paper, 2026-10-08. Director: James. Covers three of his locked directives: gloved hands + visible weapon, material-based audio, moss-as-depth-cue. Concrete and build-ready.*

## Context
- Godot 4.7, **Android-first** (phone screen, touch controls, performance budget).
- Dungeon already renders via **MultiMesh** with flakdeau CC0 stone textures; **mossy variants exist in the wall rotation** and **dark ceiling caps** are wired.
- **AudioManager** autoload is live: Music bus, SFX bus, **8-voice SFX pool**.
- Staged assets only: Quaternius enemy models (wired in), Kenney audio, flakdeau CC0. **No AI-generated assets ever.** James's rules: "easy, though not too easy"; original names/lore only.
- Movement already has a walk-bob + even stride cycle (idle spec: stride timing/easing fixed). First-person presentation hooks into that same stride signal.

---

## 1. Gloved Hands + Visible Weapon

### Recommendation: the anchored-camera hand rig with per-weapon-type grip presets (Option B, cheap)

Two honest options:

- **Option A — Static anchor.** One gloved-hand mesh + current weapon mesh parented to the camera. Bob-synced sway (reads the existing bob phase), one swing tween on attack. ~1 day of work, looks fine at phone scale.
- **Option B — Grip presets.** Same anchor rig, but 4 hand-pose presets (blade, crusher, staff, fists) that the hand tween-swaps between on weapon change. Weapon mesh swaps with it. Slightly more work, much better feel — a mace held like a sword looks wrong even on a phone.

**Recommendation: build Option A first, with Option B's grip presets as part of the same pass** — the hand mesh is one low-poly rig (staged/CC0, NOT generated, NOT bare hands — gloves per James); the grips are just 4 saved local transforms. Cost is small, payoff is per-weapon identity every frame.

### What the player actually sees

- **Idle:** hands at rest near bottom-right of screen, weapon angled inward (~20°), subtle breathing sway (sine, ±2px, ~4s period). Hands visible = gloves visible — dark leather, worn.
- **Walking:** sway syncs to the walk-bob's stride phase (same signal driving the camera bob — one source of truth, no drift). Hands dip slightly on each footfall, weapon tip bobs a few pixels. This is why the even stride fix matters: hands can't sway cleanly off a limping bob.
- **Attacking:** swing = a 0.25s tween: weapon pitches up-right 15° then cuts down-left across center, hand leads the motion. Crusher-type weapons get a heavier, slower arc (0.35s) with a small camera kick; blades get the fast cut. Hit lands on the downswing frame — SFX and damage number sync there.
- **Opening chests:** on chest open, right hand releases the weapon grip for the animation: both gloved hands reach forward, weapon slides to bottom-left (holstered pose, still visible), lid creak + loot flash plays, hands return. Keeps the "you did that" ownership feel in both idle-brain and manual mode.
- **Equipping:** 0.5s weapon-swap: old weapon dips out of frame, new one rises in, hands settle into its grip preset. Metal weapons clang (see §2).

### Implementation notes
- Hand rig = one `Node3D` child of the camera (`FirstPersonRig`), hand mesh + weapon pivot. Unshaded or simple material — phone shader budget stays clean.
- Expose `fp_rig.set_grip(weapon_type)` and `fp_rig.play_swing(weapon_type)` — called by the combat code, not the other way around.
- Never shown: character body, shadow of hands (cast shadow off for the rig — camera-space meshes shouldn't cast world shadows).

---

## 2. Material-Based Audio

### The rule
**Sounds come from the material, not the action name.** Footsteps read the *worn armor material* × *floor surface*; gear sounds read the *item material*; weapon swings read the *weapon type*.

### Proposed SFX key map (new keys, fits the existing AudioManager SFX bus)

**Footsteps** (fire on each footfall of the stride cycle — the same event that dips the camera bob):
- `step_leather_soft` — leather boots on stone (James's baseline: "leather footsteps soft")
- `step_metal` — metal sabatons: bright tap with a short stone tail
- `step_cloth` — cloth wraps: near-silent, a soft brush
- `step_moss_leather`, `step_moss_metal` — mossy floors mute everything ~40% (see §3: moss spreads with depth, so deeper = softer steps — a subconscious cue stacked on the visual one)

**Gear / item sounds** (fire on equip, unequip, loot drop, chest loot landing):
- `clang_metal_on_stone` — equipping metal armor, or a metal item dropping to the floor
- `clink_chain` — chainmail-type items (if chain gets its own material tag)
- `thud_leather` — leather item landing
- `swish_cloth` — cloth item handled
- `equip_blade_draw` — blade-type weapon drawn (metal slide)

**Weapon swings** (fire at swing start; impact sounds fire on hit):
- `swing_blade` — whoosh, thin, fast
- `swing_crusher` — heavier whoosh, lower pitch, longer
- `swing_staff` — light swish
- `hit_blade_stone` / `hit_blade_flesh` — metal ring vs. wet thud
- `hit_crusher` — deep thud with a stone-crack tail

### Armor material: where it lives in the data
Add a **`material` tag** to the item data schema (alongside the existing stats/rarity):
- Enum: `cloth | leather | metal | chain | bone | wood` (extendable; start with the first three)
- Default by armor slot if a piece lacks one (boots default leather, plate defaults metal) — no content break on old items.
- The player entity exposes `get_worn_material(slot)`; the footstep code reads the **boots slot** material × the **current cell's floor surface** and builds the key: `step_{material}_{surface}` with fallbacks (`step_leather` if the surface has no variant).

### Materials × surfaces table (the whole system in one grid)

|               | Stone (base)        | Moss-covered (deep)      | Wood (town/doors) | Rubble (caves) |
|---------------|---------------------|--------------------------|--------------------|----------------|
| **Leather**   | `step_leather_soft` | `step_moss_leather`      | soft knock         | soft crunch    |
| **Cloth**     | `step_cloth`        | `step_cloth` (muted)     | near-silent        | soft brush     |
| **Metal**     | `step_metal`        | `step_moss_metal`        | hard clack         | scrape         |

Fill order: implement the **Stone column + moss variants first** (the dungeon is stone + moss for the first 20 depths — that covers 90% of playtime). Wood and rubble columns are stubs for the town/overworld groundwork.

### How it hooks into AudioManager (implementable)
- One helper: `AudioManager.play_step(boots_material, floor_surface)` — builds the key, falls back gracefully, routes to the SFX bus with the 8-voice pool. Footsteps are low priority: they **steal the oldest voice** rather than cutting combat sounds.
- `AudioManager.play_gear(item_material, event)` for equip/drop (`clang_metal_on_stone` on metal equip or metal loot drop).
- All keys are short, looped Kenney/CC0 clips pitched ±10% randomly so strides don't machine-gun.

---

## 3. Moss Progression — "You Can Feel How Deep You Are"

### The directive (James)
Moss spreads deeper with depth: *"through the cracks of the stone, spreading out further into the dungeon floors."* This is both art direction and a **subconscious depth cue** — the player should feel depth in their gut before they read the depth number.

### Proposed curve: moss wall-variant weight by depth

| Depth | Mossy-wall weight | Ceiling-cap moss | Floor moss patches |
|-------|-------------------|------------------|--------------------|
| 1     | 15%               | none             | none               |
| 5     | 25%               | faint tint on 10% of caps | sparse cracks |
| 10    | 40%               | 25% of caps      | crack veins in ~30% of cells |
| 15    | 50%               | 40% of caps      | veins + small patches |
| 20    | 60%               | 55% of caps      | patches common     |
| 25    | 70%               | 65% of caps      | thick, near-continuous |
| 30+   | 78% (cap)         | 75% of caps      | heavy overgrowth   |

- Formula behind the table (for the generator): `moss_weight = min(0.15 + depth * 0.021, 0.78)`. Linear is fine — depth is linear, the cue should be too. Smooth, no steps at thresholds.
- The existing mossy wall variant in the MultiMesh rotation just gets a depth-weighted probability. **No new wall meshes needed** — this is a weighting change, not an asset change.

### "Through the cracks" art direction notes
- Moss lives in **cracks and seams first**, not as full-wall paint: crack-vein decals on floor cells, moss tinting along wall edges/corners, then spreading outward onto faces as depth rises.
- **Ceiling caps** get moss tint starting ~depth 5 — dark ceilings with moss hanging at the edges read as "deep and damp" instantly on a phone screen.
- Color: keep the moss a desaturated green-grey (fits the existing dungeon palette); deep moss (25+) can push slightly more saturated — contrast creep is itself a depth signal.
- **Future hook (traps):** the coming trap/perception system wants *very faint* hints of vines/webs pre-reveal. Moss veins are the natural camouflage for those hints — vines-as-trap-hint and moss-as-depth-cue share the same visual language. Design both together when traps land.

### Moss as a stacked subconscious cue
Three channels carry the same depth message — none of them is the HUD number:
1. **Sight:** moss density (this section).
2. **Sound:** mossy floors mute footsteps ~40% (§2: `step_moss_*` variants).
3. **Touch/feel:** slightly longer stride reverb tail on moss, subtler bob. (Cheap: scale the bob amplitude down 10% on heavy moss — "the floor feels softer.")
James's depth cue = all three, always consistent. The depth number on the HUD is the confirmation, not the signal.

---

## Design Takeaways
1. **One stride signal drives everything.** Camera bob, hand sway, footstep SFX all read the same even stride cycle. The limp fix (idle spec) was a prerequisite for all three sections of this paper.
2. **Materials are data, not audio files.** The `material` tag on items + the materials × surfaces table means new content gets correct sounds for free — designers tag the item, the AudioManager does the rest.
3. **Moss is a system, not decoration.** Depth-weighted wall variants + ceiling tint + muted footsteps + trap-hint camouflage = one feature with four payoffs, zero new art assets.
4. **Hands are the player's body.** Gloved (always), weapon-typed grips, chest-opening reaches — the first-person rig exists to make idle-brain *and* manual play feel owned. No body, no shadows, no bare skin.
5. **Forge houses stay behavior-first.** Per James's locked decision, forge houses are behavior gimmicks, not elements — the first-person rig doesn't need per-forge art unless James says otherwise (see open question 1).

## Open Questions for James
1. **Forge-house identity in the weapon view?** Should the held weapon's look shift with the forge house that made it (subtle hilt/grip tint or charm-slot glow per forge), or stay purely weapon-type? (Your rule: forges = behavior gimmicks, not elements — this would be a *visual* identity, not a mechanical one. Cheap if yes: tint the weapon pivot's accent material.)
2. **Hand visibility toggle?** Some players hide first-person hands. Add a settings toggle (hands on/off), or keep hands always visible as part of Abysmal's identity?
3. **Blood/impact feedback on the weapon?** On hit, should the weapon show a brief impact flash (white) — or keep it clean with just the swing + SFX? Phone readability vs. clutter.
4. **Moss curve steepness.** The proposed curve hits 60% mossy walls at depth 20. Too fast, too slow, or right for the "feel how deep you are" target? (Prestige lives at depth 10 — should the first prestige run already look mossy?)
5. **Chest-opening hands in idle mode.** When the idle brain opens a chest, do we play the full two-hands reach animation (it's the AI acting, not you) — or keep it instant since the player didn't do it? Suggests: play it — the hands are the player's window into what the AI just did.
6. **Chainmail as its own material?** `chain` gets a `clink_chain` sound distinct from plate's `clang`. Worth the extra tag, or fold chain into `metal`?
7. **Ceiling moss vs. dark ceiling readability.** Mossy ceiling caps at 75% by depth 30+ — does the ceiling stay readable as "ceiling" on a phone screen, or should moss on caps stop at ~50% to keep the silhouette dark?
