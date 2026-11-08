# Wave 4 — Apex boss treatments (Oct 29, 2026)

**Engine:** Godot 4.7.2 headless. **Scope:** NEW `scripts/apex_bosses.gd`
+ NEW `tests/apex_bosses_test.gd` + this doc. **No APK, no release, no
publish, no upload.** Credits use **Aethelwarden Solas** only.
**Nothing else was edited:** `behaviors.gd`, `enemy.gd`,
`dungeon_gen.gd`, `voice_map.gd`, and `monster_models.gd` are untouched
by this wave (verified by file timestamps).

**Roster check:** the lore doc's 16 match the brief's 16 (order differs
only). Wave 4 treats 15; the 16th boss is EXCLUDED (election-flagged
models, HELD) and has no entry, form, voice, or behavior anywhere in
Wave 4 code. This doc refers to it only as "the excluded boss" and
never wires it; the parent report names it for coordination.

## 1. Per-boss treatments (form / voice / behavior / slot proposal)

Form is procedural for all 15 (distinct silhouette, proportions,
colors, scale, procedural idle/attack/death motion — full specs in
`apex_bosses.gd` BOSSES). Voice pools are exactly
`voice_map.gd` APEX_VOCAL_POOLS, layered in order. Slot drops are
PROPOSAL ONLY (James decides). Material drops are the filled-list
entry of the boss's roster base type (filled-list inheritance rule);
Anzu and Tarasque are own-name entries, the other 13 are base-type
inheritance (see §4).

| Boss | Form (procedural, scale) | Voice pools (layered) | Signature behavior (twist + counters) | Slot PROPOSAL | Material (filled list) |
|---|---|---|---|---|---|
| Medusa (Gorgon) | Serpent-haired humanoid, stone-grey, 2.2 m; snakes sway/strike independently | spirit + human_scream | Petrifying Gaze (eye-glow tell; turn/strafe, never face it); Serpent Hair (separately targetable); Stone Shards. Twist: clearing snakes buys safe windows | face — Petrifying visage mask | petrified scale (Gorgon) |
| Typhon (Ur-Dragon) | Colossal storm-giant, crown of lesser serpent heads, 6.0 m | dragon + abyssal (unwired) | Storm Winds (keep moving); Serpent Volley (dodge, don't farm); Eruption (step off cracks). Twist: main head is the only damage target | chest — Storm-giant stormplate | genesis-scale fragment (Ur-Dragon) |
| Echidna (Lamia) | Half-woman over massive coils, 3.5 m long | generic + demon | Brood Call (12 s summon waves); Tail Sweep (never stand in the ring); Venom Spit pools. Twist: burn-down vs. clear-brood choice | neck — Serpent-coil torc | serpentine scaled underbelly (Lamia) |
| Fenrir (Great Wolf) | Enormous gaunt wolf, broken chain, 3.0 m | beast | Bone Bite (frontal cone, never trade); Pounce (lands where you stood); Death Howl. Twist: keep moving and the pounce misses by itself | hands — Wolf-claw gauntlets | colossal wolf pelt (Great Wolf) |
| Jörmungandr (World Wurm) | Ringed world serpent filling the arena rim, 8.0 m long | dragon + beast | Tail Sweep (rim is dangerous); Venom Spray pools; Coil Surge wave. Twist: fight near the head, not the rim | waist — World-serpent belt | trench-carved colossal scale (World Wurm) |
| Surtr (Fire Giant) | Towering flame-wreathed giant, sun-bright sword, 4.5 m | demon + orc | Flame Sword Arc (slow windup, long recovery = window); Fire Wave; Eruption Pillars (glowing ground). Twist: keeps Weapon per the lore-doc resolution | weapon — World-fire sword | cinderscorched plate skin (Fire Giant) |
| Fafnir (Elder Wyrm) | Wyrm coiled over a hoard mound, 5.0 m long | dragon + beast | Poison Breath cone (inhale tell); Tail Sweep rear arc; Hoard Charge (cannot turn). Twist: charge recovery is the best window | shoulders — Dragon-scale pauldrons | ancient layered scale plate (Elder Wyrm) |
| Baba Yaga (Witch) | Stooped witch in a flying mortar + pestle, skull fence, hut behind, 2.0 m | human (unwired — NO clip resolves) | Mortar Dive (shadow is the tell); Pestle Sweep; Skull Volley; Hex (interruptible). Twist: skull totems destructible, thinning the volley | trinket — Chicken-legged hut charm | brewed herb pouch (Witch) |
| Koschei the Deathless (Lich) | Gaunt lich, cold light, hidden vessel glint, 1.9 m | undead + spirit | Death Bolts; Deathless Guard (INVULNERABLE while a vessel lives — damage 0); Bone Summons (distraction); Life Drain (interrupt or he heals). Twist: find + break the vessel each phase | ring L — Death-needle ring | phylactery glass dust (Lich) |
| Humbaba (Cedar Guardian) | Trunk-armed bark guardian, 4.0 m | orc + generic | Cedar Slam (long recovery = window); Terror Roar; Root Snare (cracks are the tell); Boulder Throw (one sidestep). Twist: crack-read fight | arms — Cedar-bark vambraces | sacred cedar resin (Cedar Guardian) |
| Shuten-dōji (Oni) | Huge drunken demon king, great club + sake gourd, 3.2 m | orc + demon | Great Club Slam (never trade); Sake Breath haze; Oni Charge; Drunken Frenzy (speed/damage rise as HP falls). Twist: every 4th attack is a drinking pause — the legendary opening, 0 damage | off-hand — Demon king's sake gourd | ogre brow horn (Oni) |
| Yamata no Orochi (Hydra) | Eight heads + eight tails, 7.0 m long | dragon | Eight-Head Volley; Drunken Stagger (droop = damage window); Tail Sweep rear arc; Storm Breath cone. Twist: heads = ceil(8 × HP fraction), min 1 — volley thins as heads fall | legs — Eight-tail scale greaves (NOT Weapon; see §3) | multi-headed regenerative blood (Hydra) |
| Ravana (Rakshasa) | Ten-headed demon king + flickering doubles, 3.0 m | demon + human (unwired) | Ten-Head Volley (dodge laterally); Sorcery Bolts; Blade Flurry (long recovery); Illusion Doubles (phase 2). Twist: fakes flicker, the true king does not — ignore fakes | ring R — Ten-headed signet | illusion-woven beast pelt (Rakshasa) |
| Anzu (Anzu) | Lion-headed storm eagle, 4.0 m wingspan | dragon + beast | Storm Dive (shadow tell, long recovery); Wind Gusts (back to a wall); Lightning Strikes (leave marked zones); Tablet Pulse shockwave | feet — Storm-bird talon boots | storm-bird beak fragment (own-name entry) |
| The Tarasque (Tarasque) | Lion head, ox body, tortoise shell, six legs, serpent tail, 3.5 m long | dragon + beast | Shell Charge (cannot turn, long recovery); Tail Lash; River Surge; Bite. Twist: frontal shell halves frontal damage (0.5×) — hit the underside after a missed charge | back — River-dragon shell cape | impenetrable carapace plate (own-name entry) |

## 2. Encounter hooks (DOCUMENTED ONLY — not activated)

Nothing in gameplay calls these. Activation is a small, separate
next-push step (§7). Thresholds are PROPOSAL (the lore doc gives no
depths); the condition text is the lore-shaped gate for each fight.
Apex bosses are NEVER in the normal spawn picker
(`dungeon_gen._pick_type()` / `spawn_table()` untouched — test-proven
at depths 1–72, 2000 picker rolls at depth 30).

| Boss | Depth min (proposal) | Gate condition |
|---|---|---|
| Baba Yaga | 15 | Arena room; shadow-read fight |
| The Tarasque | 16 | Arena room; charge-punish fight |
| Humbaba | 18 | Arena room; crack-read fight |
| Fenrir | 20 | Arena room; pounce/bite positioning |
| Anzu | 22 | Arena room; marked-zone fight |
| Fafnir | 25 | Arena room; flank fight |
| Shuten-dōji | 28 | Arena room; race fight (frenzy) |
| Surtr | 30 | Arena room; fire-resistance fight |
| Ravana | 33 | Arena room; tell-read fight (flicker) |
| Echidna | 35 | Arena room; brood-wave choice |
| Yamata no Orochi | 38 | Arena room; head-focus fight |
| Typhon | 40 | Arena room; storm-arena fight |
| Jörmungandr | 45 | Arena room; rim-danger fight |
| Koschei the Deathless | 50 | Arena room; vessel-hunt fight |
| Medusa | 12 | Arena room; gaze mechanic is the gate |

## 3. Slot-drop proposals + the Weapon resolution

All 15 slots below are PROPOSAL ONLY (flagged `slot_proposal: true`
in code). The 16-slot set is completed only by the excluded boss's
piece (head slot), which is NOT built here. Resolution kept from the
lore doc: Surtr's sword and Orochi's tail-sword both wanted Weapon —
**Surtr takes Weapon; Orochi takes legs (eight-tail scale greaves)**,
with the tail-sword kept as lore text only, never a second Weapon
drop. No set bonus is implemented beyond this data
(`CAPSTONE.set_bonus` = "NOT IMPLEMENTED beyond this data entry").

## 4. Material drops (filled-list-first rule)

Per the parent directive, material drops were finalized from James's
filled list (`design-notes/monster-material-list-filled-2026-10-29.txt`,
300 entries verified by parse), via the list's own inheritance rule
("variants inherit their base creature's materials"). Each apex boss
rides its roster base type (catalog §5), so the table in §1 lists that
base's filled entry. Two bosses (Anzu, Tarasque) match the filled list
by their own name; the other 13 are base-type inheritance and are
marked as such in code (`name_match: false`), so James can flip them
to blank with a one-line change if he wants apex-name-only strictness.
Nothing was invented: every material string above is copied from the
filled list.

## 5. Capstone (data only)

- **Name:** Crown of the Deep. **Pieces required:** 16; **Wave 4
  supplies:** 15; the 16th piece belongs to the excluded boss and is
  NOT built or wired here.
- **Good/evil rule:** expressed through the PLAYER'S ACTIONS, not a
  menu choice.
- **No endgame built:** there is NO world-destroying endgame and NO
  endgame sequence in this wave. The removed alternative is not an
  option in code or data.

## 6. AI-model evaluation (Oct 29 decision update)

James approved the AI-generated 3DAssets.dev models in principle, but
has NOT visually reviewed them. Each was checked with the tools
available headlessly (Godot 4.7.2 GLTFDocument parse; Blender 4.5.3
import for one file). **Result: NONE is wired for any apex boss.**
Forcing any of them would violate the no-forced-fit rule, and the
original brief's ban on reskinned normal monsters as bosses still
stands for apex reads.

| AI model | Check result | Apex verdict |
|---|---|---|
| CityWolf.glb (beasts) | Godot parse FAILS: required `KHR_mesh_quantization` unsupported. Blender 4.5.3 imports cleanly (7 meshes: head/paws/tail/torso, materials present) — a Blender re-export pass could make it Godot-usable | NOT WIRED: a realistic wolf scaled up is a reskinned normal monster as Fenrir, not a colossal mythic wolf with a broken chain |
| CornSnake.glb (dragons) | Godot parse FAILS: same extension | NOT WIRED: a corn-snake read is wrong for Jörmungandr/Orochi, and Orochi needs EIGHT heads — a single snake is not creature-true |
| EasternDragon.glb (dragons) | Godot parse FAILS: same extension | NOT WIRED: static generic dragon; not creature-true for Typhon (storm-giant with serpent heads) or Fafnir as an apex read |
| WesternDragon.glb (dragons) | Godot parse FAILS: same extension | NOT WIRED: same as EasternDragon — static, generic, unreviewed |
| CellarSpider.glb (vermin) | Godot parse FAILS: same extension | NOT WIRED: no apex boss is a spider (Medusa's snakes are not spiders) |
| GoblinScavenger.glb (goblin-kin) | Godot parse FAILS: same extension | NOT WIRED: no apex boss is a goblin |
| SkeletonWarrior.glb (undead) | Godot parse FAILS: same extension | NOT WIRED: a generic skeleton warrior is not Koschei the Deathless (gaunt lich with a hidden vessel) |
| StoneGardenGolem.glb (golems) | Godot parses: 4 meshes, 0 textured (flat colors), 1.44 × 1.7 × 0.51 m, no animation clips (static) | NOT WIRED: a garden-ornament read is wrong for Humbaba (cedar/bark guardian) and Surtr (fire giant); static + untextured + unreviewed |

**Flagged for James:** all 8 models above, with the reasons in this
table. The 7 parse failures are a follow-up Blender re-export pass
(verified possible for CityWolf; the other 6 share the identical
failure signature but are unverified per-file) — that pass is for
NORMAL monsters, not apex, unless a converted model is then judged a
genuine apex fit on visual review. **Every model wired in a future
pass needs James's in-editor visual review before shipping** — the
eyeball pass matters more, not less, now that the hold is lifted.
Election-flagged models (the excluded boss's GLBs, Fire/Ice/Stone
Golem, Bone Golem) stay HELD and are never wired. No AI-use
disclaimer text is included in this wave: its wording is pending
James's approval in a separate draft.

## 7. Stat derivation (explicit, test-pinned)

Locked curves + ONE explicit boss-tier step, applied once:

- `boss_HP(depth) = base_hp × 5.0 × depth^1.2`
- `boss_ATK(depth) = base_atk × 2.0 × depth^1.05`
- `boss_DEF = base_def + 2.0` (flat, all depths)

Base values are the roster-base creature values (Wave 4 explicit
where no staged base exists; the two staged analogues on record are
wolf 22/7/0 and oni 38/9/2 — the apex bases below are deliberately
larger, as befits a boss tier). Pinned at depths 1/10/30 in tests.

| Boss | Base HP/ATK/DEF | Boss D1 HP/ATK/DEF | Boss D10 HP/ATK | Boss D30 HP/ATK |
|---|---|---|---|---|
| Medusa | 30/8/2 | 150/16/4 | 2377/180 | 8885/569 |
| Typhon | 60/14/3 | 300/28/5 | 4755/314 | 17769/996 |
| Echidna | 40/10/2 | 200/20/4 | 3170/224 | 11846/711 |
| Fenrir | 45/12/2 | 225/24/4 | 3566/269 | 13327/853 |
| Jörmungandr | 70/13/4 | 350/26/6 | 5547/292 | 20731/925 |
| Surtr | 55/15/3 | 275/30/5 | 4358/337 | 16288/1067 |
| Fafnir | 60/13/4 | 300/26/6 | 4755/292 | 17769/925 |
| Baba Yaga | 28/11/1 | 140/22/3 | 2219/247 | 8292/782 |
| Koschei | 32/12/2 | 160/24/4 | 2536/269 | 9477/853 |
| Humbaba | 50/11/3 | 250/22/5 | 3962/247 | 14808/782 |
| Shuten-dōji | 48/13/2 | 240/26/4 | 3804/292 | 14215/925 |
| Orochi | 65/12/3 | 325/24/5 | 5151/269 | 19250/853 |
| Ravana | 42/12/2 | 210/24/4 | 3328/269 | 12438/853 |
| Anzu | 38/12/2 | 190/24/4 | 3011/269 | 11254/853 |
| Tarasque | 70/11/5 | 350/22/7 | 5547/247 | 20731/782 |

Boss-machine knobs (explicit in code): phase 2 at/below 50% HP
(cooldown ×0.75, damage ×1.25); signature-attack cycle 3.0 s;
Echidna brood wave every 12.0 s; Shuten drink pause every 4th
attack; frenzy +50% at 0 HP fraction. Generic mechanics are REUSED
from behaviors.gd (`breath_cone_hit`, `aoe_damage_at`, venom
fraction) — never re-implemented, never apex-specific code in
behaviors.gd.

## 8. Voice wiring status (honest limit)

Pools resolve through `ApexBosses.resolve_apex_vocal()` to the
first clip of the first WIRED pool, with the existing idle/attack/
death pitch/volume modifiers mirrored. Two pools have no staged
clips and never resolve: `abyssal` (Typhon's secondary) and `human`
(Baba Yaga's only pool, Ravana's secondary). Consequence: Baba Yaga
currently resolves to NO clip (correct — no file invented), Typhon
resolves via dragon, Ravana via demon. `AudioManager.
play_monster_vocal()` only accepts the 28 staged TYPE_VOICE ids
(voice_map_test pins that at 28), so the one-function AudioManager
apex entry point is a named next-push step, not silently invented
here. The flagged audio file appears in no pool and no resolved
clip (test-proven via voice_map.gd's own FLAGGED_FILES list).

## 9. Tests (Godot 4.7.2 headless)

NEW `tests/apex_bosses_test.gd`: **1041 checks, ALL PASS** (one
run, ~2 s). Covers: exactly 15 bosses; excluded boss absent;
apex code text free of the excluded boss's name, HELD markers, the
flagged audio file, and the removed capstone option; all four legs
per boss; 15 unique proposal slots (all slots except head);
Surtr→Weapon / Orochi→legs resolution; voice pools exactly equal
to APEX_VOCAL_POOLS; resolved clips exist + load + unflagged;
unwired pools never resolve; stat pins at depths 1/10/30;
twists (vessel, heads, frenzy, drink pause, brood timer, gaze,
totems, illusions, shell); breath/AoE generic reuse; no apex in
spawn tables or 2000 picker rolls; hooks present but unactivated;
capstone data correct.

## 10. What the next push needs to activate apex encounters

1. **Boss arena gate:** a room/door condition at each hook's depth
   that consults `ApexBosses.encounter_available(boss_id, depth)` —
   NEVER the normal spawn picker. Per-boss activation is then one
   gate call each; thresholds in §2 are proposals for James to
   confirm or change.
2. **Main-loop wiring:** drive `ApexBosses.new_state()` +
   `update()` from the boss fight loop (same intent dialect as
   behaviors.gd); apply `damage_taken_mult()` (Koschei vessel),
   `break_vessel()` / `destroy_totem()` events, and the
   Tarasque frontal-damage rule at the combat call site.
3. **AudioManager apex entry point:** one function mapping a boss
   id to `resolve_apex_vocal()` playback through the existing
   voice pool machinery (TYPE_VOICE stays at 28 staged types).
4. **Visual pass:** procedural forms need an in-editor eyeball
   pass (silhouette/read at phone scale); AI-model conversions
   (Blender re-export) + James's visual review belong to the
   normal-monster follow-up pass, not apex, unless a converted
   model is then judged a genuine apex fit.
5. **James's decisions still open:** slot mapping (proposal only),
   hook depth thresholds (proposal only), whether base-type
   material inheritance stands or apex-name-only blanking applies,
   and the excluded boss's treatment (HELD models undecided).

## 11. Addendum — Cerberus (16th boss) lands (Nov 1, 2026)

Director-authorized build (memo:
`design-notes/cerberus-director-memo.md`). The Wave 4 exclusion is
lifted: CC-BY 3.0 election confirmed Oct 29, 2026, and the director
re-asked in a later turn. Nothing in §§1–10 above was rewritten;
this section records what changed.

**Model verification (Godot 4.7.2 headless, scratch project,
Wave 1 method — editor import + GLTFDocument walk, Nov 1):**

| File | Import | Meshes | Skeleton | Clips | Texture | AABB (m) | Verdict |
|---|---|---|---|---|---|---|---|
| cerberus_v002.glb (Phase 1b listed export) | PASS | 1 (1 surface) | 49 bones, three head chains | Walk only (1.29 s, 43 tracks) | MISSING (flat grey) | 9.41 × 10.32 × 17.36, origin −6.49 | CONDITIONAL — reference only, NOT wired |
| cerberus_v002_full.glb (Wave 1B re-export) | PASS | 1 (1 surface) | 49 bones, three head chains | Attack (1.71 s), Idle (0.88 s), Walk (1.29 s), die (1.46 s), hit (0.88 s) | EMBEDDED (resolves, .ctex produced) | same | WIRED — see below |

The _full file recovers all 5 actions present in the source
`.blend` (NLA strips; no Pose action exists in the file, so none
was authored). Caveats carried into the registry: grounding
required (mesh extends 6.49 m below origin), height-normalised to
3.0 m, and **VISUAL REVIEW REQUIRED — James has not eyeballed
this model** (headless checks prove import, not appearance).

**Treatment (same pattern as the other 15):** Cerberus, base
Hellhound, 50/12/3 (boss-tier step: D1 250/24/5). Form: massive
three-headed guardian hound, 3.0 m. Voice: beast + demon pools
(both wired; already in `APEX_VOCAL_POOLS`). Behavior (lore doc +
behavior catalog §5): Triple Bite (three heads strike in sequence,
front arc), Tail Serpent (sideways lash, little warning), Gate
Roar (bellowing stagger, front arc, long windup). Counters: flank
so one head tracks; leave the front arc during roar windup;
punish after the triple bite (heads need a breath). Slot
PROPOSAL: head — Gatekeeper's Triune Helm (ambush first-strikes
lose their free hit + DEF). Material: sulfurous canine fang
(filled list, Hellhound base-type inheritance). Hook PROPOSAL
(documented-not-activated, like the other 15): depth 55, the
deepest hook — the head piece completes the set.

**Capstone:** Crown of the Deep is now 16/16 wired
(`pieces_in_wave4` = 16). Good/evil still expressed through the
player's actions; still no endgame sequence built.

**Attribution (REQUIRED, CC-BY 3.0):** "Animated Cerberus by
Clement Wu, Nikolaus & Botanic (CC-BY 3.0)" — carried in the
model's LICENSE.md, models/LICENSES.md, and the credits doc's
pointer; also flagged in the apex entry's model_note and the
registry note.

**Files changed:** `scripts/apex_bosses.gd` (Cerberus entry
appended; CAPSTONE 15→16; header scope updated; the other 15
entries untouched), `scripts/monster_models.gd` (Cerberus added
to ROSTER_MODELS; "animated-cerberus" removed from HELD_MARKERS;
Bone Golem stays HELD), `tests/apex_bosses_test.gd` (16 bosses,
16 slots incl. head, Cerberus specifics, capstone 16).
`behaviors.gd`, `enemy.gd`, `dungeon_gen.gd`, `voice_map.gd`
untouched. No APK, no release, no publish.
