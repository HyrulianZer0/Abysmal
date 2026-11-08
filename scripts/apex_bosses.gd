class_name ApexBosses
extends RefCounted
## Apex boss treatments — Wave 4 (Oct 29, 2026).
##
## WHAT THIS IS: form + voice + behavior + slot-drop PROPOSAL data and a
## pure state machine for all 16 named apex bosses. The 16th boss
## (Cerberus, head slot) landed Nov 1, 2026, in a director-authorized
## build (memo: design-notes/cerberus-director-memo.md; CC-BY 3.0
## election confirmed Oct 29, 2026); its model is verified headless
## but still awaits James's in-editor visual review before shipping.
## The full-set capstone counts 16 pieces (see CAPSTONE below); all
## 16 are now wired, the 16th being Cerberus's Gatekeeper's Triune
## Helm.
##
## CREDITS: Aethelwarden Solas only. Never James's real name.
##
## SCOPE RULES (all enforced by tests/apex_bosses_test.gd):
## - FORM: all 16 bosses now wire a sourced model — Cerberus
##   (director-authorized build Nov 1, 2026) plus 15 guide-built
##   bespoke apex models (Nov 2, 2026 apex pass, visual review
##   PASSED Nov 2). NEVER a human stand-in, NEVER a reskinned
##   normal monster presented as a boss: the 15 are bespoke apex
##   sculpts, not roster reuses (the bestiary rows anzu/tarasque
##   are separate smaller builds at different paths). Hooks stay
##   documented-not-activated (see SPAWN below).
##   AI-MODEL DECISION (Oct 29 update, hold lifted in principle):
##   the 8 AI-generated models were checked for apex fit (see
##   design-notes/wave4-apex-bosses.md §6). Seven fail Godot 4.7.2
##   import outright (required KHR_mesh_quantization extension
##   unsupported); the eighth parses but is the wrong read for every
##   apex boss. NONE is wired here — no forced fit. Every wired
##   model in a future pass still needs James's in-editor visual
##   review before shipping. Election-flagged models stay HELD and
##   are never wired — EXCEPT Cerberus, whose hold lifted Nov 1,
##   2026 (CC-BY 3.0 election confirmed Oct 29 + director
##   authorization). Bone Golem remains unwired (no matching type). No AI-use disclaimer text is included here:
##   its wording is pending James's approval elsewhere.
## - VOICE: pools come from scripts/voice_map.gd APEX_VOCAL_POOLS
##   (layered pools, e.g. beast+demon). No new recordings, no invented
##   per-boss audio files. Pools named in APEX_ONLY_POOLS ("abyssal",
##   "human") have no staged clips: they are listed as unwired and
##   NEVER resolve to a clip. The flagged audio file appears in NO
##   pool and is never referenced (voice_map_test already proves the
##   pools are clean; this file's tests re-prove it for apex paths).
##   Playback: resolve_apex_vocal() returns the same shape the
##   existing AudioManager voice API uses (pool + clip + pitch +
##   volume, with the existing idle/attack/death modifiers mirrored).
##   AudioManager.play_monster_vocal() itself only accepts the 28
##   staged TYPE_VOICE ids (voice_map_test pins that at 28), so the
##   one-function AudioManager apex entry point is a named next-push
##   step — it is NOT silently invented here.
## - BEHAVIOR: boss-specific code lives HERE, never in behaviors.gd
##   (which is untouched by this wave) and never in enemy.gd's combat
##   math or scaling curves. Generic mechanics are REUSED from
##   behaviors.gd (breath_cone_hit, aoe_damage_at, venom fraction),
##   not duplicated. Signature patterns come from
##   design-notes/behavior-catalog-phase1.md §5 and
##   design-notes/apex-bosses-lore-strategies.txt.
## - SLOT DROPS: PROPOSAL ONLY (James decides). Every slot entry is
##   flagged "PROPOSAL" in this file and in the design doc. The
##   Surtr→Weapon / Orochi→legs (greaves) resolution from the lore
##   doc is kept: both wanted Weapon (Orochi's tail-sword), Surtr
##   takes Weapon, Orochi's greaves carry the serpent's scale.
##   NO set bonus is implemented beyond this data.
## - MATERIAL DROPS: finalized from James's FILLED materials list
##   (design-notes/monster-material-list-filled-2026-10-29.txt), via
##   the list's own inheritance rule ("variants inherit their base
##   creature's materials"). Each apex boss rides its roster base
##   type (catalog §5), so "material" below is that base type's
##   filled-list entry — never invented. The two bosses whose own
##   name IS a filled-list entry (Anzu, Tarasque) are marked
##   "name_match": true; the other 13 are base-type inheritance and
##   are marked as such, so James can flip them to blank with a
##   one-line change if he wants apex-name-only strictness.
## - SPAWN: apex bosses are NEVER in the normal spawn picker. This
##   file does not touch dungeon_gen.gd or _pick_type(). Encounter
##   hooks (encounter_hook / encounter_available) are DOCUMENTED
##   CONDITIONS ONLY — nothing in gameplay calls them yet. The next
##   push decides activation; activation is a small, separate step.
## - CAPSTONE: data only (name + the action-expression rule). NO
##   endgame sequence is built, and there is NO world-destroying
##   endgame. The removed alternative is not an option in this file.
##
## STAT DERIVATION (explicit, test-pinned — never a silent second
## scaling system):
##   boss_HP(depth)  = base_hp  * APEX_HP_MULT  * depth^1.2
##   boss_ATK(depth) = base_atk * APEX_ATK_MULT * depth^1.05
##   boss_DEF         = base_def + APEX_DEF_BONUS  (flat, all depths)
## The depth exponents are the LOCKED curves (HP × depth^1.2,
## ATK × depth^1.05, flat defense). APEX_HP_MULT / APEX_ATK_MULT /
## APEX_DEF_BONUS are the single explicit boss-tier step, applied
## ONCE, here, and pinned by tests at depths 1/10/30. "base_hp /
## base_atk / base_def" are the boss's roster-base creature values
## (Wave 4 explicit where no staged base exists; the two staged
## analogues on record are wolf 22/7/0 for Fenrir's Great Wolf base
## and oni 38/9/2 for Shuten-dōji's Oni base — the apex bases below
## are deliberately larger than those staged values, as befits a
## boss tier, and the difference is stated, not hidden).
##
## TELEGRAPH FAMILIES (kept consistent across bosses, catalog §5):
## ground cracks -> eruption/snare under the player; shadow -> aerial
## dive landing spot; eye-glow -> gaze; inhale -> breath cone;
## pawing/bellowing -> charge; long windup -> interrupt-or-escape;
## post-attack recovery -> punish window. No boss reassigns a tell
## to a different meaning.

const _VoiceMap = preload("res://scripts/voice_map.gd")
const _Behaviors = preload("res://scripts/behaviors.gd")

## --- Explicit boss-tier scaling (ONE step, test-pinned) ----------------
const APEX_HP_MULT := 5.0
const APEX_ATK_MULT := 2.0
const APEX_DEF_BONUS := 2.0

## --- Phase / timing knobs (explicit, test-pinned) ----------------------
const APEX_PHASE2_HP_FRACTION := 0.5  # phase 2 at/below 50% HP
const APEX_ATTACK_COOLDOWN := 3.0  # seconds between signature attacks
const APEX_PHASE2_COOLDOWN_MULT := 0.75  # phase 2 attacks come faster
const APEX_PHASE2_DAMAGE_MULT := 1.25  # phase 2 hits harder
const APEX_DRINK_EVERY_NTH_ATTACK := 4  # Shuten-dōji drinking pause
const APEX_BROOD_CALL_INTERVAL := 12.0  # Echidna summon wave interval
const APEX_FRENZY_MAX_BONUS := 0.5  # Shuten-dōji: +50% at 0 HP fraction

## Full-set capstone (DATA ONLY — no endgame sequence is built).
const CAPSTONE := {
	"name": "Crown of the Deep",
	"pieces_required": 16,
	"pieces_in_wave4": 16,
	"excluded_piece_note": "COMPLETE Nov 1, 2026: all 16 pieces are now wired. The 16th piece is Cerberus's Gatekeeper's Triune Helm (head slot), landed in the Nov 1 Cerberus build (director-authorized; CC-BY 3.0 model, attribution required; visual review still pending). The set is completable.",
	"expression_rule": "The crown's good/evil is expressed through the PLAYER'S ACTIONS, not a menu choice.",
	"endgame_note": "There is NO world-destroying endgame and NO endgame sequence built here. Capstone data only.",
	"set_bonus": "NOT IMPLEMENTED beyond this data entry (proposal data only; James decides).",
	"proposal": true,
}

## Boss entries. "slot" + "slot_item" are PROPOSAL ONLY (James decides).
## "model" is now a sourced path for every boss (Cerberus Nov 1; the other 15 Nov 2).
const BOSSES := {
	"medusa": {
		"display": "Medusa", "base_type": "Gorgon",
		"base_hp": 30.0, "base_atk": 8.0, "base_def": 2.0,
		"material": "petrified scale", "material_source": "filled list, base-type inheritance (Gorgon)", "name_match": false,
		"silhouette": "Humanoid upper body ringed by a mass of independently writhing serpent hair; stone-grey skin, tall and narrow.",
		"scale_m": 2.2, "scale_axis": "y",
		"colors": ["#8a8f7a", "#3d5a3a", "#e8dcc0"],
		"features": "Serpent hair (separately targetable snakes); glowing eyes during gaze windup; chipped-stone shoulders from old victims.",
		"idle_motion": "Serpents sway and strike at air in turn; slow coiling sway of the torso; eyes dim between gazes.",
		"attack_motion": "Eye-glow swell then gaze burst; snakes lunge in sequence; overarm shard throws.",
		"death_motion": "Serpents go limp one by one, then the body greys and cracks into a statue that crumbles.",
		"model": "res://assets/models/apex/medusa.glb", "model_note": "Guide-built bespoke model, Nov 2, 2026 (staging apex pass); visual review PASSED Nov 2; flat colors, texture paint pending over this same path. Hooks stay documented-not-activated.",
		"voice_pitch": 1.1, "voice_volume": 0.9,
		"slot": "face", "slot_item": "Petrifying visage mask", "slot_proposal": true,
		"encounter_depth": 12, "encounter_condition": "Boss arena room at depth 12+; gaze mechanic is the gate (turn/strafe during eye-glow).",
		"twist": "Separately targetable serpent hair: clearing snakes buys safe windows.",
		"counters": "Turn or strafe during the gaze windup — never face it. Attack hard during the long gaze cooldown. Clear snakes for safe windows.",
		"attacks": [
			{"name": "Petrifying Gaze", "tell": "eye_glow", "counter": "Turn or strafe away; never face the gaze when it fires.", "mechanic": "gaze", "damage_mult": 1.0},
			{"name": "Serpent Hair", "tell": "snakes_coil", "counter": "Clear snakes one at a time; each downed snake thins the multi-hit.", "mechanic": "multi_hit", "damage_mult": 0.8},
			{"name": "Stone Shards", "tell": "overarm_throw", "counter": "Sidestep the thrown chips; they are projectiles, not a cone.", "mechanic": "volley", "damage_mult": 0.9},
		],
	},
	"typhon": {
		"display": "Typhon", "base_type": "Ur-Dragon class",
		"base_hp": 60.0, "base_atk": 14.0, "base_def": 3.0,
		"material": "genesis-scale fragment", "material_source": "filled list, base-type inheritance (Ur-Dragon)", "name_match": false,
		"silhouette": "Colossal storm-giant frame wreathed in a crown of lesser serpent heads; broad, towering, many-headed.",
		"scale_m": 6.0, "scale_axis": "y",
		"colors": ["#2e3440", "#5a6b7a", "#c9a227"],
		"features": "Hundred-headed crown (lesser heads are a dodge-not-farm distraction); storm-grey hide; volcanic glow at the joints.",
		"idle_motion": "Lesser heads sway and hiss out of sync; chest heaves like a bellows; storm gusts ripple the arena dust.",
		"attack_motion": "Main head rears for the damage strike while lesser heads spit fans; ground cracks spider out before eruption.",
		"death_motion": "Lesser heads droop in waves, then the giant kneels and sinks as if buried, embers guttering out.",
		"model": "res://assets/models/apex/typhon.glb", "model_note": "Guide-built bespoke model, Nov 2, 2026 (staging apex pass); visual review PASSED Nov 2; flat colors, texture paint pending over this same path. Hooks stay documented-not-activated.",
		"voice_pitch": 0.7, "voice_volume": 1.0,
		"slot": "chest", "slot_item": "Storm-giant stormplate", "slot_proposal": true,
		"encounter_depth": 40, "encounter_condition": "Boss arena room at depth 40+; storm-arena fight (keep moving).",
		"twist": "Lesser heads are a distraction: only the main head is the damage target.",
		"counters": "Keep moving — winds punish standing still. Step off cracked ground before eruption. Hit the main head; dodge the lesser heads.",
		"attacks": [
			{"name": "Storm Winds", "tell": "chest_heave", "counter": "Keep moving; gusts knock back anyone standing still.", "mechanic": "wind_gust", "damage_mult": 0.8},
			{"name": "Serpent Volley", "tell": "lesser_heads_rear", "counter": "Dodge the fans laterally; do not farm the lesser heads.", "mechanic": "volley", "damage_mult": 0.9},
			{"name": "Eruption", "tell": "ground_cracks", "counter": "Step off cracked ground before the burst lands.", "mechanic": "ground_crack", "damage_mult": 1.2},
		],
	},
	"echidna": {
		"display": "Echidna", "base_type": "Lamia class",
		"base_hp": 40.0, "base_atk": 10.0, "base_def": 2.0,
		"material": "serpentine scaled underbelly", "material_source": "filled list, base-type inheritance (Lamia)", "name_match": false,
		"silhouette": "Half-woman upper body rising from massive coiled serpent coils; wide ground footprint, low-slung coils.",
		"scale_m": 3.5, "scale_axis": "z",
		"colors": ["#6b4a2f", "#3f6b4a", "#d8c49a"],
		"features": "Thick coils that sweep the ground ring around her; brood pits at the coil edge where summons emerge.",
		"idle_motion": "Coils breathe and re-settle; upper body sways; brood pits stir between waves.",
		"attack_motion": "Coils unspool into the sweep; head rears and spits arcing venom; a brood wave spills from the pits.",
		"death_motion": "Coils unwind flat, then still; brood pits go dark and quiet.",
		"model": "res://assets/models/apex/echidna.glb", "model_note": "Guide-built bespoke model, Nov 2, 2026 (staging apex pass); visual review PASSED Nov 2; flat colors, texture paint pending over this same path. Hooks stay documented-not-activated.",
		"voice_pitch": 0.9, "voice_volume": 0.9,
		"slot": "neck", "slot_item": "Serpent-coil torc", "slot_proposal": true,
		"encounter_depth": 35, "encounter_condition": "Boss arena room at depth 35+; brood waves are the gate (burn her down or clear the brood first).",
		"twist": "Brood Call summons lesser monsters in waves on a timer.",
		"counters": "Decide fast: burn her down and eat the swarm, or clear the brood first. Never stand in the sweep ring. Step out of venom pools at once.",
		"attacks": [
			{"name": "Brood Call", "tell": "brood_pits_stir", "counter": "Choose burn-down vs. clear-first before the wave lands.", "mechanic": "summon", "damage_mult": 0.7},
			{"name": "Tail Sweep", "tell": "coils_unspool", "counter": "Fight from range or dive past the tail; never stand in the sweep ring.", "mechanic": "sweep_ring", "damage_mult": 1.1},
			{"name": "Venom Spit", "tell": "head_rear", "counter": "Step out of venom pools at once; they linger.", "mechanic": "venom_pool", "damage_mult": 0.9},
		],
	},
	"fenrir": {
		"display": "Fenrir", "base_type": "Great Wolf",
		"base_hp": 45.0, "base_atk": 12.0, "base_def": 2.0,
		"material": "colossal wolf pelt", "material_source": "filled list, base-type inheritance (Great Wolf)", "name_match": false,
		"silhouette": "Enormous wolf, long-legged and gaunt, jaws oversized; broken chain links drag from one foreleg.",
		"scale_m": 3.0, "scale_axis": "y",
		"colors": ["#3a3f45", "#7a7f85", "#b8b0a0"],
		"features": "Broken Gleipnir chain remnant; scarred muzzle; oversized jaw (the frontal bite cone).",
		"idle_motion": "Pacing circle with head low; chain links drag and clink; hackles rise before a pounce.",
		"attack_motion": "Jaw unhinges for the crushing bite; full-body crouch then long leap; head thrown back for the howl.",
		"death_motion": "Staggers, chain goes slack, then collapses onto its side, breath slowing to stillness.",
		"model": "res://assets/models/apex/fenrir.glb", "model_note": "Guide-built bespoke model, Nov 2, 2026 (staging apex pass); visual review PASSED Nov 2; flat colors, texture paint pending over this same path. Hooks stay documented-not-activated. Staged wolf (22/7/0) is the small analogue, not the boss.",
		"voice_pitch": 0.8, "voice_volume": 1.0,
		"slot": "hands", "slot_item": "Wolf-claw gauntlets", "slot_proposal": true,
		"encounter_depth": 20, "encounter_condition": "Boss arena room at depth 20+; pounce/bite positioning fight.",
		"twist": "Pounce always lands where the player stood — keep moving and it misses by itself.",
		"counters": "Never trade the bite — sidestep the frontal cone. Keep moving so the pounce misses. Punish the long recovery after a missed pounce.",
		"attacks": [
			{"name": "Bone Bite", "tell": "jaw_unhinge", "counter": "Sidestep the frontal cone; never trade it.", "mechanic": "melee_arc", "damage_mult": 1.5},
			{"name": "Pounce", "tell": "crouch_pawing", "counter": "Keep moving — it lands where you stood.", "mechanic": "charge_line", "damage_mult": 1.2},
			{"name": "Death Howl", "tell": "head_thrown_back", "counter": "Break close range before the howl; it is a close-range fear stagger.", "mechanic": "aoe_ring", "damage_mult": 0.7},
		],
	},
	"jormungandr": {
		"display": "Jörmungandr", "base_type": "World Wurm",
		"base_hp": 70.0, "base_atk": 13.0, "base_def": 4.0,
		"material": "trench-carved colossal scale", "material_source": "filled list, base-type inheritance (World Wurm)", "name_match": false,
		"silhouette": "World serpent: immense ringed body filling the arena rim, head raised at the center; the rim itself is the danger.",
		"scale_m": 8.0, "scale_axis": "z",
		"colors": ["#1f3a2f", "#4a6b52", "#c8b060"],
		"features": "Ringed coils at the arena edge; venom-slick scales; head crest that flares before a spray.",
		"idle_motion": "Coils ripple around the rim in slow waves; head sways above the center; venom drips from the jaw.",
		"attack_motion": "Tail whips along the rim; head rears and sprays venom pools; a coil surge rolls inward as a wave.",
		"death_motion": "Coils slacken ring by ring from the tail inward; the head lowers last and stills.",
		"model": "res://assets/models/apex/jormungandr.glb", "model_note": "Guide-built bespoke model, Nov 2, 2026 (staging apex pass); visual review PASSED Nov 2; flat colors, texture paint pending over this same path. Hooks stay documented-not-activated.",
		"voice_pitch": 0.7, "voice_volume": 1.0,
		"slot": "waist", "slot_item": "World-serpent belt", "slot_proposal": true,
		"encounter_depth": 45, "encounter_condition": "Boss arena room at depth 45+; rim-danger fight (fight near the head, not the rim).",
		"twist": "The arena rim is owned by the tail — positioning, not damage, is the fight.",
		"counters": "Poison resistance or a cleanse is near-mandatory. Fight near the head, not the rim. Move out of venom pools, never stand in them.",
		"attacks": [
			{"name": "Tail Sweep", "tell": "rim_coils_tighten", "counter": "Leave the arena rim; the tail owns the edges.", "mechanic": "sweep_ring", "damage_mult": 1.1},
			{"name": "Venom Spray", "tell": "crest_flare", "counter": "Move out of pools at once; they linger.", "mechanic": "venom_pool", "damage_mult": 0.9},
			{"name": "Coil Surge", "tell": "coils_roll_inward", "counter": "Brace toward the head; the wave pushes back from the rim.", "mechanic": "surge_wave", "damage_mult": 1.0},
		],
	},
	"surtr": {
		"display": "Surtr", "base_type": "Fire Giant",
		"base_hp": 55.0, "base_atk": 15.0, "base_def": 3.0,
		"material": "cinderscorched plate skin", "material_source": "filled list, base-type inheritance (Fire Giant)", "name_match": false,
		"silhouette": "Towering fire giant, broad-shouldered, gripping a sword brighter than the sun; flame-wreathed silhouette.",
		"scale_m": 4.5, "scale_axis": "y",
		"colors": ["#1a1a1a", "#e86a1a", "#ffd23f"],
		"features": "Sun-bright sword (the Weapon-slot proposal); ember skin with glowing seams; scorched ground trail.",
		"idle_motion": "Slow breathing ember-pulse; sword tip drags sparks; heat shimmer rises off the shoulders.",
		"attack_motion": "Slow sword windup into huge arcs; arm sweeps to launch the fire wave; ground glows before pillars erupt.",
		"death_motion": "Sword light dims to ember, then the giant kneels and crumbles into cooling slag.",
		"model": "res://assets/models/apex/surtr.glb", "model_note": "Guide-built bespoke model, Nov 2, 2026 (staging apex pass); visual review PASSED Nov 2; flat colors, texture paint pending over this same path. Hooks stay documented-not-activated.",
		"voice_pitch": 0.7, "voice_volume": 1.0,
		"slot": "weapon", "slot_item": "World-fire sword", "slot_proposal": true,
		"encounter_depth": 30, "encounter_condition": "Boss arena room at depth 30+; fire-resistance fight (never stand on scorched ground).",
		"twist": "Keeps the Weapon slot per the lore-doc resolution (Orochi's tail-sword yields to greaves).",
		"counters": "Fire resistance first. The sword arc has a slow windup and a long recovery — that recovery is your window. Ranged shines during fire-wave windup.",
		"attacks": [
			{"name": "Flame Sword Arc", "tell": "sword_windup", "counter": "Dodge the slow windup; punish the long recovery.", "mechanic": "melee_arc", "damage_mult": 1.5},
			{"name": "Fire Wave", "tell": "arm_sweep", "counter": "Ranged attacks shine during the wave windup; do not stand in its path.", "mechanic": "surge_wave", "damage_mult": 1.1},
			{"name": "Eruption Pillars", "tell": "ground_glow", "counter": "Step off glowing ground before pillars erupt.", "mechanic": "ground_crack", "damage_mult": 1.2},
		],
	},
	"fafnir": {
		"display": "Fafnir", "base_type": "Elder Wyrm",
		"base_hp": 60.0, "base_atk": 13.0, "base_def": 4.0,
		"material": "ancient layered scale plate", "material_source": "filled list, base-type inheritance (Elder Wyrm)", "name_match": false,
		"silhouette": "Elder wyrm coiled over a hoard mound; long serpentine neck, heavy tail, gold glinting between the coils.",
		"scale_m": 5.0, "scale_axis": "z",
		"colors": ["#6b5a1a", "#3d5a2a", "#ffd23f"],
		"features": "Hoard mound under the coils (arena dressing, not loot until victory); layered scale plates; heavy tail.",
		"idle_motion": "Coils settle over the hoard; neck sways; jaw drips venom; tail tip twitches.",
		"attack_motion": "Inhale swell before the poison breath cone; tail rears for the rear arc; body straightens for the hoard charge.",
		"death_motion": "Neck collapses across the hoard; coils slacken; venom cloud thins and clears.",
		"model": "res://assets/models/apex/fafnir.glb", "model_note": "Guide-built bespoke model, Nov 2, 2026 (staging apex pass); visual review PASSED Nov 2; flat colors, texture paint pending over this same path. Hooks stay documented-not-activated.",
		"voice_pitch": 0.75, "voice_volume": 1.0,
		"slot": "shoulders", "slot_item": "Dragon-scale pauldrons", "slot_proposal": true,
		"encounter_depth": 25, "encounter_condition": "Boss arena room at depth 25+; flank fight (breath frontal, tail rear).",
		"twist": "Hoard Charge cannot turn — sidestep it and the recovery is the best damage window in the fight.",
		"counters": "Poison resistance. Stay to the flank — breath is frontal, tail is rear. Sidestep the charge; punish its recovery.",
		"attacks": [
			{"name": "Poison Breath", "tell": "inhale", "counter": "Leave the frontal cone; the lingering cloud punishes standing in it.", "mechanic": "cone", "damage_mult": 1.1},
			{"name": "Tail Sweep", "tell": "tail_rear", "counter": "Never stand in the rear arc; the flank is safe.", "mechanic": "tail_arc", "damage_mult": 1.1},
			{"name": "Hoard Charge", "tell": "pawing", "counter": "Sidestep — it cannot turn; punish the recovery.", "mechanic": "charge_line", "damage_mult": 1.2},
		],
	},
	"baba_yaga": {
		"display": "Baba Yaga", "base_type": "Witch",
		"base_hp": 28.0, "base_atk": 11.0, "base_def": 1.0,
		"material": "brewed herb pouch", "material_source": "filled list, base-type inheritance (Witch)", "name_match": false,
		"silhouette": "Stooped witch in a flying mortar, pestle in hand; skull-topped fence posts ring the arena; chicken-legged hut looms behind.",
		"scale_m": 2.0, "scale_axis": "y",
		"colors": ["#4a3a2a", "#7a2a2a", "#e8dcc0"],
		"features": "Mortar + pestle + broom; fence-skull totems (destructible, thin the volley); hut on chicken legs as arena dressing.",
		"idle_motion": "Mortar bobs and circles; pestle taps a rhythm; broom sweeps the trail behind her.",
		"attack_motion": "Mortar climbs, shadow slides across the floor, then the dive slam; pestle sweeps wide; skulls spit bolts; hex casting glows.",
		"death_motion": "Mortar tips and grounds; pestle drops; the hut turns away and the fence skulls go dark.",
		"model": "res://assets/models/apex/baba-yaga.glb", "model_note": "Guide-built bespoke model, Nov 2, 2026 (staging apex pass); visual review PASSED Nov 2; flat colors, texture paint pending over this same path. Hooks stay documented-not-activated. NEVER a human stand-in — the mortar + pestle + hut silhouette is the read, not a humanoid model.",
		"voice_pitch": 1.0, "voice_volume": 0.9,
		"slot": "trinket", "slot_item": "Chicken-legged hut charm", "slot_proposal": true,
		"encounter_depth": 15, "encounter_condition": "Boss arena room at depth 15+; shadow-read fight (watch the shadow, not the witch).",
		"twist": "Skull totems are destructible: destroying them thins the volley.",
		"counters": "Watch the shadow, not the witch — the dive lands on the shadow. Interrupt the hex cast. Destroy skull totems. Punish the post-dive pause.",
		"attacks": [
			{"name": "Mortar Dive", "tell": "shadow", "counter": "Move off the shadow before the slam lands; punish the pause after.", "mechanic": "shadow_dive", "damage_mult": 1.3},
			{"name": "Pestle Sweep", "tell": "pestle_raise", "counter": "Step out of the wide melee arc.", "mechanic": "melee_arc", "damage_mult": 1.0},
			{"name": "Skull Volley", "tell": "skulls_glow", "counter": "Destroy skull totems to thin the volley.", "mechanic": "volley", "damage_mult": 0.8},
			{"name": "Hex", "tell": "hex_glow", "counter": "Interrupt the cast; the hex slows and weakens if it lands.", "mechanic": "debuff_cast", "damage_mult": 0.6},
		],
	},
	"koschei": {
		"display": "Koschei the Deathless", "base_type": "Lich",
		"base_hp": 32.0, "base_atk": 12.0, "base_def": 2.0,
		"material": "phylactery glass dust", "material_source": "filled list, base-type inheritance (Lich)", "name_match": false,
		"silhouette": "Gaunt lich, tall and skeletal, wreathed in cold light; a hidden vessel glints somewhere in the arena each phase.",
		"scale_m": 1.9, "scale_axis": "y",
		"colors": ["#2a2a33", "#7a8a9a", "#9ae8d8"],
		"features": "Needle-egg-duck-hare-chest nesting is the lore: each phase hides one vessel; breaking it ends invulnerability.",
		"idle_motion": "Slow drift; fingers weave death magic; cold light pulses with each vessel phase.",
		"attack_motion": "Death bolts lance out; bone summons rise as a screen; drain beam channels with a visible tether.",
		"death_motion": "Vessel shatters last; the lich unravels into dust and cold light, no body left.",
		"model": "res://assets/models/apex/koschei.glb", "model_note": "Guide-built bespoke model, Nov 2, 2026 (staging apex pass); visual review PASSED Nov 2; flat colors, texture paint pending over this same path. Hooks stay documented-not-activated.",
		"voice_pitch": 0.85, "voice_volume": 0.9,
		"slot": "ring_l", "slot_item": "Death-needle ring", "slot_proposal": true,
		"encounter_depth": 50, "encounter_condition": "Boss arena room at depth 50+; vessel-hunt fight (find and break the hidden vessel each phase).",
		"twist": "Deathless Guard: invulnerable phases while a hidden vessel lives — damage is 0 until the vessel breaks.",
		"counters": "Each phase, find and break the hidden vessel — that ends invulnerability. Interrupt the drain channel at all costs. Ignore summons while a vessel is exposed.",
		"attacks": [
			{"name": "Death Bolts", "tell": "fingers_weave", "counter": "Sidestep the heavy aimed bolts.", "mechanic": "volley", "damage_mult": 1.1},
			{"name": "Deathless Guard", "tell": "vessel_glint", "counter": "Find and break the vessel; body damage is 0 until then.", "mechanic": "vessel_phase", "damage_mult": 0.0},
			{"name": "Bone Summons", "tell": "ground_stir", "counter": "Ignore the screen while a vessel is exposed; they are the distraction.", "mechanic": "summon", "damage_mult": 0.7},
			{"name": "Life Drain", "tell": "drain_tether", "counter": "Interrupt the channel at all costs — it heals him.", "mechanic": "drain_channel", "damage_mult": 0.8},
		],
	},
	"humbaba": {
		"display": "Humbaba", "base_type": "Cedar Guardian",
		"base_hp": 50.0, "base_atk": 11.0, "base_def": 3.0,
		"material": "sacred cedar resin", "material_source": "filled list, base-type inheritance (Cedar Guardian)", "name_match": false,
		"silhouette": "Massive cedar guardian: trunk-sized arms, bark-plated torso, terror-face; roots trail at the feet.",
		"scale_m": 4.0, "scale_axis": "y",
		"colors": ["#4a3826", "#2f4a2a", "#c8b060"],
		"features": "Trunk arms; bark plates; root system that erupts as snares; boulder piles at the arena edge.",
		"idle_motion": "Slow root-creep; arms sway like branches; breath rumbles like a flood.",
		"attack_motion": "Arms rise high for the slam, shockwave ring rippling out; jaw opens for the terror roar; ground cracks before snares.",
		"death_motion": "Arms drop and splinter; bark plates shed; the guardian topples and roots go still.",
		"model": "res://assets/models/apex/humbaba.glb", "model_note": "Guide-built bespoke model, Nov 2, 2026 (staging apex pass); visual review PASSED Nov 2; flat colors, texture paint pending over this same path. Hooks stay documented-not-activated.",
		"voice_pitch": 0.7, "voice_volume": 1.0,
		"slot": "arms", "slot_item": "Cedar-bark vambraces", "slot_proposal": true,
		"encounter_depth": 18, "encounter_condition": "Boss arena room at depth 18+; crack-read fight (step off cracked ground).",
		"twist": "Root Snare erupts under the player on cracked ground — the crack IS the tell.",
		"counters": "Step off cracked ground before the snare erupts. The slam recovery is long — that is the window. One sidestep clears the slow boulders.",
		"attacks": [
			{"name": "Cedar Slam", "tell": "arms_raise", "counter": "Punish the long slam recovery; the shockwave ring is the outer edge.", "mechanic": "aoe_ring", "damage_mult": 1.4},
			{"name": "Terror Roar", "tell": "jaw_open", "counter": "Spread from the roar's center; it is a wide fear stagger.", "mechanic": "aoe_ring", "damage_mult": 0.7},
			{"name": "Root Snare", "tell": "ground_cracks", "counter": "Step off cracked ground before vines erupt.", "mechanic": "ground_crack", "damage_mult": 1.0},
			{"name": "Boulder Throw", "tell": "boulder_lift", "counter": "One sidestep clears the slow, heavy throw.", "mechanic": "volley", "damage_mult": 1.2},
		],
	},
	"shuten_doji": {
		"display": "Shuten-dōji", "base_type": "Oni",
		"base_hp": 48.0, "base_atk": 13.0, "base_def": 2.0,
		"material": "ogre brow horn", "material_source": "filled list, base-type inheritance (Oni)", "name_match": false,
		"silhouette": "Drunken demon king: huge oni frame, great club, sake gourd at the hip; horns and wild hair.",
		"scale_m": 3.2, "scale_axis": "y",
		"colors": ["#7a1a1a", "#3a2a1a", "#e8c060"],
		"features": "Great iron club; sake gourd (the off-hand slot proposal); drunken sway that sharpens into frenzy as HP falls.",
		"idle_motion": "Drunken sway and gourd-swigging; club drags; sway quickens as frenzy builds.",
		"attack_motion": "Club raised high, slow and devastating; sake breath haze billows; bull rush straight across the room.",
		"death_motion": "Club drops, gourd spills, then the king slumps as if asleep — the legendary opening, taken.",
		"model": "res://assets/models/apex/shuten-doji.glb", "model_note": "Guide-built bespoke model, Nov 2, 2026 (staging apex pass); visual review PASSED Nov 2; flat colors, texture paint pending over this same path. Hooks stay documented-not-activated. Staged oni (38/9/2) is the small analogue, not the boss.",
		"voice_pitch": 0.8, "voice_volume": 1.0,
		"slot": "off_hand", "slot_item": "Demon king's sake gourd", "slot_proposal": true,
		"encounter_depth": 28, "encounter_condition": "Boss arena room at depth 28+; race fight (frenzy means longer fights get harder).",
		"twist": "Drunken Frenzy: speed and damage rise as HP falls; the mid-fight drinking pause is the legendary opening.",
		"counters": "Never trade the club — dodge the windup, always. Take the drinking pause. Confusion protection or distance beats sake breath. End it fast.",
		"attacks": [
			{"name": "Great Club Slam", "tell": "club_raised", "counter": "Dodge the windup, always; never trade it.", "mechanic": "melee_arc", "damage_mult": 1.5},
			{"name": "Sake Breath", "tell": "gourd_swigs", "counter": "Confusion protection or distance; the haze confuses and slows.", "mechanic": "cone", "damage_mult": 0.8},
			{"name": "Oni Charge", "tell": "pawing", "counter": "Sidestep the bull rush; it runs straight.", "mechanic": "charge_line", "damage_mult": 1.2},
			{"name": "Drunken Frenzy", "tell": "sway_quickens", "counter": "End it fast — frenzy scales with missing HP.", "mechanic": "frenzy", "damage_mult": 1.0},
		],
	},
	"orochi": {
		"display": "Yamata no Orochi", "base_type": "Hydra",
		"base_hp": 65.0, "base_atk": 12.0, "base_def": 3.0,
		"material": "multi-headed regenerative blood", "material_source": "filled list, base-type inheritance (Hydra)", "name_match": false,
		"silhouette": "Eight-headed, eight-tailed serpent mass; heads fan out above a coiled body; tails fill the rear arc.",
		"scale_m": 7.0, "scale_axis": "z",
		"colors": ["#2a4a3a", "#6b2a2a", "#c8b060"],
		"features": "Eight heads (head-count thinning: each head downed thins the volley); eight tails (massive rear arc); storm-breath maw.",
		"idle_motion": "Heads sway out of sync, tasting the air; tails lash idly; one head dips to drink between volleys.",
		"attack_motion": "Multiple heads strike at once from many angles; heads droop after drinking; tails sweep the rear; storm breath cones wide.",
		"death_motion": "Heads droop one by one until the last falls; tails still; the tail-sword lore (Kusanagi) is lore text only, not a second Weapon drop.",
		"model": "res://assets/models/apex/orochi.glb", "model_note": "Guide-built bespoke model, Nov 2, 2026 (staging apex pass); visual review PASSED Nov 2; flat colors, texture paint pending over this same path. Hooks stay documented-not-activated.",
		"voice_pitch": 0.75, "voice_volume": 1.0,
		"slot": "legs", "slot_item": "Eight-tail scale greaves", "slot_proposal": true,
		"encounter_depth": 38, "encounter_condition": "Boss arena room at depth 38+; head-focus fight (one head at a time).",
		"twist": "Head-count thinning: heads_remaining = ceil(8 × HP fraction), minimum 1; volley strength scales with heads.",
		"counters": "Focus one head at a time — each head downed thins the volley. When heads droop after drinking, that is the damage window. Front is safer than rear.",
		"attacks": [
			{"name": "Eight-Head Volley", "tell": "heads_rear", "counter": "Focus one head; each downed head thins the volley.", "mechanic": "volley", "damage_mult": 1.0},
			{"name": "Drunken Stagger", "tell": "heads_droop", "counter": "Attack hard during the droop — it is the damage window.", "mechanic": "drink_pause", "damage_mult": 0.0},
			{"name": "Tail Sweep", "tell": "tails_rear", "counter": "Never stand in the tail arc; the front is safer than the rear.", "mechanic": "tail_arc", "damage_mult": 1.2},
			{"name": "Storm Breath", "tell": "inhale", "counter": "Leave the wide elemental cone.", "mechanic": "cone", "damage_mult": 1.1},
		],
	},
	"ravana": {
		"display": "Ravana", "base_type": "Rakshasa",
		"base_hp": 42.0, "base_atk": 12.0, "base_def": 2.0,
		"material": "illusion-woven beast pelt", "material_source": "filled list, base-type inheritance (Rakshasa)", "name_match": false,
		"silhouette": "Ten-headed demon king: central warrior frame ringed by nine lesser heads; blades in hand; phantom doubles flicker at the edges.",
		"scale_m": 3.0, "scale_axis": "y",
		"colors": ["#3a2a4a", "#8a2a2a", "#e8c060"],
		"features": "Ten heads in a fan; illusion doubles that flicker (the tell — fakes flicker, the true king does not); scholar-warrior regalia.",
		"idle_motion": "Heads turn independently, scanning; blades trace slow arcs; doubles shimmer in and out.",
		"attack_motion": "Heads spit projectile fans; sorcery bolts lance from the hands; blade flurry storms at close range.",
		"death_motion": "Doubles gutter out first, then heads droop in sequence; the true king falls last.",
		"model": "res://assets/models/apex/ravana.glb", "model_note": "Guide-built bespoke model, Nov 2, 2026 (staging apex pass); visual review PASSED Nov 2; flat colors, texture paint pending over this same path. Hooks stay documented-not-activated. NEVER a human stand-in — the ten-head fan is the read.",
		"voice_pitch": 0.85, "voice_volume": 1.0,
		"slot": "ring_r", "slot_item": "Ten-headed signet", "slot_proposal": true,
		"encounter_depth": 33, "encounter_condition": "Boss arena room at depth 33+; tell-read fight (illusions flicker; ignore the fakes).",
		"twist": "Illusion Doubles mirror attacks in phase 2; the true king does not flicker — learn the tell and ignore fakes.",
		"counters": "Learn the flicker tell and ignore fakes. Dodge volleys laterally, never backward. The blade flurry has a long recovery — that is the punish window.",
		"attacks": [
			{"name": "Ten-Head Volley", "tell": "heads_rear", "counter": "Dodge laterally, never backward.", "mechanic": "volley", "damage_mult": 1.0},
			{"name": "Sorcery Bolts", "tell": "hands_glow", "counter": "Sidestep the heavy aimed bolts.", "mechanic": "volley", "damage_mult": 1.1},
			{"name": "Blade Flurry", "tell": "blades_spin", "counter": "Survive the storm, then punish the long recovery.", "mechanic": "melee_arc", "damage_mult": 1.3},
			{"name": "Illusion Doubles", "tell": "doubles_flicker", "counter": "Ignore flickering fakes; hit the non-flickering king.", "mechanic": "illusion", "damage_mult": 0.5},
		],
	},
	"anzu": {
		"display": "Anzu", "base_type": "Anzu",
		"base_hp": 38.0, "base_atk": 12.0, "base_def": 2.0,
		"material": "storm-bird beak fragment", "material_source": "filled list, own-name entry (Anzu)", "name_match": true,
		"silhouette": "Great storm-bird: lion-headed eagle, huge wings, talons; storm clouds gather under the wings.",
		"scale_m": 4.0, "scale_axis": "x",
		"colors": ["#3a3a3a", "#7a6a3a", "#e8e0c0"],
		"features": "Lion head on an eagle body; broad storm wings; the stolen Tablet motif as arena dressing (not loot).",
		"idle_motion": "Wings beat slow circles overhead; storm gusts ripple dust; head tracks the player.",
		"attack_motion": "Wings fold for the plunging dive (shadow first); wings beat walls of wind; ground zones flare before lightning.",
		"death_motion": "Wings fold and the bird drops to the arena floor, storm clouds thinning overhead.",
		"model": "res://assets/models/apex/anzu.glb", "model_note": "Guide-built bespoke model, Nov 2, 2026 (staging apex pass); visual review PASSED Nov 2; flat colors, texture paint pending over this same path. Hooks stay documented-not-activated.",
		"voice_pitch": 0.9, "voice_volume": 1.0,
		"slot": "feet", "slot_item": "Storm-bird talon boots", "slot_proposal": true,
		"encounter_depth": 22, "encounter_condition": "Boss arena room at depth 22+; marked-zone fight (leave marked ground before lightning).",
		"twist": "Tablet Pulse is a radial shockwave; gusts punish open-floor positioning (back to a wall).",
		"counters": "Move out of marked zones before lightning lands. Punish the long dive recovery. Position with your back to a wall so gusts cannot throw you into hazards.",
		"attacks": [
			{"name": "Storm Dive", "tell": "shadow", "counter": "Move off the shadow; punish the long dive recovery.", "mechanic": "shadow_dive", "damage_mult": 1.3},
			{"name": "Wind Gusts", "tell": "wings_beat", "counter": "Back to a wall so gusts cannot throw you into hazards.", "mechanic": "wind_gust", "damage_mult": 0.8},
			{"name": "Lightning Strikes", "tell": "ground_marks", "counter": "Leave marked zones before they detonate.", "mechanic": "marked_zone", "damage_mult": 1.2},
			{"name": "Tablet Pulse", "tell": "tablet_glow", "counter": "Step out of the radial shockwave's inner ring.", "mechanic": "shockwave", "damage_mult": 1.0},
		],
	},
	"tarasque": {
		"display": "The Tarasque", "base_type": "Tarasque",
		"base_hp": 70.0, "base_atk": 11.0, "base_def": 5.0,
		"material": "impenetrable carapace plate", "material_source": "filled list, own-name entry (Tarasque)", "name_match": true,
		"silhouette": "River-dragon: lion's head, ox's body, tortoise shell, six legs, serpent's tail; low, wide, armored.",
		"scale_m": 3.5, "scale_axis": "z",
		"colors": ["#4a5a3a", "#6b5a3a", "#8a7a5a"],
		"features": "Tortoise shell (frontal hits shrug off — attack the underside after a missed charge); six legs; serpent tail.",
		"idle_motion": "Six-legged amble; shell plates shift; tail lashes idly; river-surge water laps the arena edge.",
		"attack_motion": "Body rolls into the shell charge; tail rears for the rear lash; river surge rolls across the room.",
		"death_motion": "Shell settles flat, legs fold, tail stills; the river surge drains away.",
		"model": "res://assets/models/apex/tarasque.glb", "model_note": "Guide-built bespoke model, Nov 2, 2026 (staging apex pass); visual review PASSED Nov 2; flat colors, texture paint pending over this same path. Hooks stay documented-not-activated.",
		"voice_pitch": 0.75, "voice_volume": 1.0,
		"slot": "back", "slot_item": "River-dragon shell cape", "slot_proposal": true,
		"encounter_depth": 16, "encounter_condition": "Boss arena room at depth 16+; charge-punish fight (sidestep, then hit the underside).",
		"twist": "Frontal shell armor: frontal hits are reduced (see intent frontal_damage_mult 0.5); the underside after a missed charge is the window.",
		"counters": "Sidestep the charge — it cannot turn, and the recovery is long. The shell shrugs off frontal hits; attack the softer underside after a missed charge.",
		"attacks": [
			{"name": "Shell Charge", "tell": "pawing", "counter": "Sidestep — it cannot turn; punish the long recovery.", "mechanic": "charge_line", "damage_mult": 1.2},
			{"name": "Tail Lash", "tell": "tail_rear", "counter": "Never stand in the rear arc.", "mechanic": "tail_arc", "damage_mult": 1.1},
			{"name": "River Surge", "tell": "water_rises", "counter": "Water resistance helps; step out of the wave's path.", "mechanic": "surge_wave", "damage_mult": 1.0},
			{"name": "Bite", "tell": "jaw_snap", "counter": "Step out of short snap range.", "mechanic": "melee_arc", "damage_mult": 0.9},
		],
	},
	"cerberus": {
		"display": "Cerberus", "base_type": "Hellhound",
		"base_hp": 50.0, "base_atk": 12.0, "base_def": 3.0,
		"material": "sulfurous canine fang", "material_source": "filled list, base-type inheritance (Hellhound)", "name_match": false,
		"silhouette": "Massive three-headed guardian hound: center head flanked by left and right heads, serpent tail, sulfurous bulk; the gate itself is the arena.",
		"scale_m": 3.0, "scale_axis": "y",
		"colors": ["#22201e", "#c23b1a", "#e8dcc0"],
		"features": "Three independently tracking heads (center, left, right); serpent tail; sulfurous fangs; ember glow at the joints.",
		"idle_motion": "Heads sway and scan independently, center head tracking the player; tail serpent coils; ember breath puffs.",
		"attack_motion": "Heads strike in sequence for the triple bite; tail lashes sideways with little warning; all three heads rear and bellow for the gate roar.",
		"death_motion": "Heads droop one by one, then the body collapses at the gate, ember light guttering out.",
		"model": "res://assets/models/apex/cerberus_v003_fixed.glb", "model_note": "Sourced model (NOT procedural): Animated Cerberus (CC-BY 3.0, Clement Wu, Nikolaus & Botanic — REQUIRED attribution in game credits). v003 rework (Nov 2, 2026): stockier build (X×1.22, torso/head Z×1.08) + 6 sharp bone horns that move WITH the heads, verified Godot 4.7.2 headless Nov 2, 2026: 57 nodes, 5 clips (Attack/Idle/Walk/die/hit), 7 meshes, grounded, 3.0155 m, texture embedded. James eyeballed the fixed preview Nov 4, 2026 and authorized the v003 wire. Height-normalised to 3.0 m. The v002 file (cerberus_v002_full.glb) stays on disk as the shelved fallback, no longer wired. The old cerberus_v002.glb (Walk only, flat grey) is reference only, never wired.",
		"voice_pitch": 0.8, "voice_volume": 1.0,
		"slot": "head", "slot_item": "Gatekeeper's Triune Helm", "slot_proposal": true,
		"encounter_depth": 55, "encounter_condition": "Boss arena room at depth 55+; gate fight (flank so one head tracks; leave the front arc during the roar windup). Deepest hook: the head piece completes the set.",
		"twist": "Three heads strike in sequence — flank so only one head tracks you; the Gate Roar's long windup is the punish window after the Triple Bite (heads need a breath).",
		"counters": "Fight from one flank so only one head tracks you. The roar has a long windup — step out of the front arc. Punish after the triple bite; the heads need a breath before the next set.",
		"attacks": [
			{"name": "Triple Bite", "tell": "heads_rear", "counter": "Flank — only one head can track you at a time; punish after the third bite while the heads draw breath.", "mechanic": "multi_hit", "damage_mult": 1.2, "side_effect": "stab", "side_effect_note": "Nov 1, 2026 refinement (James): the heads' horns stab as they bite — Cerberus must read intimidating, not a lean greyhound. Mesh mass/horns pass is a separate modeling step; this field carries the treatment."},
			{"name": "Tail Serpent", "tell": "tail_coil", "counter": "Sidestep the sideways lash — it comes with little warning, so keep moving.", "mechanic": "tail_arc", "damage_mult": 1.1},
			{"name": "Gate Roar", "tell": "roar_windup", "counter": "Leave the front arc during the long windup; the roar staggers.", "mechanic": "aoe_ring", "damage_mult": 0.7},
		],
	},
}

## Per-boss mutable state for the boss machine. Plain data, no nodes,
## so headless tests drive it directly (same pattern as behaviors.gd).
class ApexState extends RefCounted:
	var boss_id: String = ""
	var hp: float = 0.0
	var max_hp: float = 0.0
	var atk: float = 0.0
	var def: float = 0.0
	var phase: int = 1
	var attack_index: int = 0
	var attack_timer: float = 0.0
	var dead: bool = false
	# Twist state.
	var heads_remaining: int = 0  # Orochi: 8 at full HP, min 1
	var vessel_alive: bool = false  # Koschei: invulnerable while true
	var totems_remaining: int = 0  # Baba Yaga: 3 skull totems
	var illusions_active: bool = false  # Ravana: phase 2
	var summon_timer: float = 0.0  # Echidna brood interval
	var attacks_done: int = 0  # Shuten-dōji drink cadence


static func boss_ids() -> Array:
	var out: Array = []
	for k in BOSSES:
		out.append(str(k))
	return out


static func is_apex(boss_id: String) -> bool:
	return BOSSES.has(boss_id)


static func boss(boss_id: String) -> Dictionary:
	if BOSSES.has(boss_id):
		return BOSSES[boss_id]
	return {}


## Locked curves + the ONE explicit boss-tier step (see header).
static func scaled_stats(boss_id: String, depth: int) -> Dictionary:
	var b: Dictionary = boss(boss_id)
	if b.is_empty() or depth < 1:
		return {}
	return {
		"hp": float(b["base_hp"]) * APEX_HP_MULT * pow(float(depth), 1.2),
		"atk": float(b["base_atk"]) * APEX_ATK_MULT * pow(float(depth), 1.05),
		"def": float(b["base_def"]) + APEX_DEF_BONUS,
	}


static func new_state(boss_id: String, depth: int = 1) -> ApexState:
	var s := ApexState.new()
	s.boss_id = boss_id
	var st: Dictionary = scaled_stats(boss_id, depth)
	if st.is_empty():
		return s
	s.max_hp = float(st["hp"])
	s.hp = s.max_hp
	s.atk = float(st["atk"])
	s.def = float(st["def"])
	s.phase = 1
	if boss_id == "orochi":
		s.heads_remaining = 8
	if boss_id == "koschei":
		s.vessel_alive = true
	if boss_id == "baba_yaga":
		s.totems_remaining = 3
	s.summon_timer = APEX_BROOD_CALL_INTERVAL
	return s


## --- Voice wiring (pools from voice_map.gd, no new files) ---------------
## Layering rule: pools are layered in APEX_VOCAL_POOLS order. The
## first WIRED pool is the primary; further wired pools layer under
## it; unwired pools (APEX_ONLY_POOLS) are listed, never resolved.
## Voice-map keys are display names, not snake_case ids.
const ID_TO_VOICE_KEY := {
	"medusa": "Medusa", "typhon": "Typhon", "echidna": "Echidna",
	"fenrir": "Fenrir", "jormungandr": "Jörmungandr", "surtr": "Surtr",
	"fafnir": "Fafnir", "baba_yaga": "Baba Yaga", "koschei": "Koschei",
	"humbaba": "Humbaba", "shuten_doji": "Shuten-dōji",
	"orochi": "Yamata no Orochi", "ravana": "Ravana", "anzu": "Anzu",
	"tarasque": "Tarasque", "cerberus": "Cerberus",
}


static func apex_vocal_pools(boss_id: String) -> Array:
	var key: String = str(ID_TO_VOICE_KEY.get(boss_id, ""))
	var pools: Array = _VoiceMap.APEX_VOCAL_POOLS.get(key, [])
	var out: Array = []
	for p in pools:
		out.append(str(p))
	return out


static func apex_voice_entry(boss_id: String) -> Dictionary:
	var b: Dictionary = boss(boss_id)
	if b.is_empty():
		return {}
	var pools: Array = apex_vocal_pools(boss_id)
	var wired: Array = []
	var unwired: Array = []
	for p in pools:
		if _VoiceMap.VOCAL_POOLS.has(str(p)):
			wired.append(str(p))
		else:
			unwired.append(str(p))
	var primary := ""
	var clip := ""
	if not wired.is_empty():
		primary = str(wired[0])
		var clips: Array = _VoiceMap.VOCAL_POOLS[primary]
		if not clips.is_empty():
			clip = str(clips[0])
	return {
		"pools": pools, "wired_pools": wired, "unwired_pools": unwired,
		"primary_pool": primary, "clip": clip,
		"pitch": float(b["voice_pitch"]), "volume": float(b["voice_volume"]),
		"note": "Layered pools in APEX_VOCAL_POOLS order; unwired pools never resolve to a clip; no new recordings.",
	}


## Same shape as the existing voice API, with its context modifiers
## mirrored (attack +5% pitch / +10% volume; death -15% pitch).
static func resolve_apex_vocal(boss_id: String, context: String = "idle") -> Dictionary:
	var e: Dictionary = apex_voice_entry(boss_id)
	if e.is_empty():
		return {}
	var pitch := float(e["pitch"])
	var volume := float(e["volume"])
	if context == "attack":
		pitch *= 1.05
		volume *= 1.1
	elif context == "death":
		pitch *= 0.85
	return {
		"pool": str(e["primary_pool"]), "clip": str(e["clip"]),
		"pitch": pitch, "volume": clampf(volume, 0.0, 1.0),
		"wired_pools": e["wired_pools"], "unwired_pools": e["unwired_pools"],
	}


## --- Encounter hooks (DOCUMENTED CONDITIONS ONLY — not activated) -------
## Nothing in gameplay calls these yet. Activation is a separate,
## small next-push step: consult encounter_available() from the boss
## arena gate, never from the normal spawn picker.
static func encounter_hook(boss_id: String) -> Dictionary:
	var b: Dictionary = boss(boss_id)
	if b.is_empty():
		return {}
	return {
		"boss_id": boss_id, "display": str(b["display"]),
		"depth_min": int(b["encounter_depth"]),
		"condition": str(b["encounter_condition"]),
		"proposal": true,
		"activated": false,
	}


static func encounter_available(boss_id: String, depth: int) -> bool:
	var hook: Dictionary = encounter_hook(boss_id)
	if hook.is_empty():
		return false
	return depth >= int(hook["depth_min"])


## --- Boss mechanics -------------------------------------------------------
## Damage multiplier the PLAYER's hits take against this boss state:
## 0.0 while a Koschei vessel lives (Deathless Guard), 1.0 otherwise.
## Frontal-shell reduction for the Tarasque is reported separately in
## the intent (frontal_damage_mult), so the caller applies it only
## to frontal hits — never silently to all hits.
static func damage_taken_mult(state: ApexState) -> float:
	if state == null:
		return 1.0
	if state.boss_id == "koschei" and state.vessel_alive:
		return 0.0
	return 1.0


static func break_vessel(state: ApexState) -> bool:
	if state == null or state.boss_id != "koschei" or not state.vessel_alive:
		return false
	state.vessel_alive = false
	return true


static func destroy_totem(state: ApexState) -> bool:
	if state == null or state.boss_id != "baba_yaga" or state.totems_remaining <= 0:
		return false
	state.totems_remaining -= 1
	return true


static func frenzy_mult(state: ApexState) -> float:
	if state == null or state.boss_id != "shuten_doji" or state.max_hp <= 0.0:
		return 1.0
	var missing := 1.0 - (state.hp / state.max_hp)
	return 1.0 + APEX_FRENZY_MAX_BONUS * missing


static func orochi_heads(state: ApexState) -> int:
	if state == null or state.max_hp <= 0.0:
		return 0
	return maxi(1, ceili(8.0 * state.hp / state.max_hp))


## Generic-mechanic reuse (NOT duplication): breath cones and AoE
## falloff are behaviors.gd's generic helpers, called through here
## so boss code never re-implements them.
static func breath_hits(origin: Vector2, facing: Vector2, target: Vector2) -> bool:
	return _Behaviors.breath_cone_hit(origin, facing, target)


static func aoe_damage_at(dist: float, radius: float, base_damage: float) -> float:
	return _Behaviors.aoe_damage_at(dist, radius, base_damage)


static func venom_tick_damage(state: ApexState, delta: float, stacks: int) -> float:
	if state == null or stacks <= 0:
		return 0.0
	return float(stacks) * _Behaviors.VENOM_DPS_PER_STACK_FRACTION * state.atk * delta


## One boss tick. Cycles signature attacks on cooldown; phase 2
## (at/below 50% HP) speeds the cycle and raises damage. The returned
## intent mirrors behaviors.gd's intent shape so the future main-loop
## wiring reads one dialect: action / telegraph / attack_kind /
## damage_mult, plus boss twist flags.
static func update(state: ApexState, delta: float, _ctx: Dictionary = {}) -> Dictionary:
	var intent := {
		"action": "idle", "telegraph": "", "attack_kind": "",
		"damage_mult": 0.0, "phase": 1, "invulnerable": false,
		"heads_remaining": 0, "frenzy_mult": 1.0,
		"illusions_active": false, "totems_remaining": 0,
		"summon_wave": false, "gaze_active": false,
		"frontal_damage_mult": 1.0, "drink_pause": false,
	}
	if state == null:
		return intent
	var b: Dictionary = boss(state.boss_id)
	if b.is_empty():
		return intent
	if state.dead or state.hp <= 0.0:
		state.dead = true
		intent["action"] = "dead"
		return intent
	# Phase + twist state.
	state.phase = 2 if state.hp <= state.max_hp * APEX_PHASE2_HP_FRACTION else 1
	intent["phase"] = state.phase
	if state.boss_id == "orochi":
		state.heads_remaining = orochi_heads(state)
		intent["heads_remaining"] = state.heads_remaining
	if state.boss_id == "koschei":
		intent["invulnerable"] = state.vessel_alive
	if state.boss_id == "baba_yaga":
		intent["totems_remaining"] = state.totems_remaining
	if state.boss_id == "ravana":
		state.illusions_active = state.phase == 2
		intent["illusions_active"] = state.illusions_active
	if state.boss_id == "tarasque":
		intent["frontal_damage_mult"] = 0.5
	# Echidna brood timer (independent of the attack cycle).
	if state.boss_id == "echidna":
		state.summon_timer -= delta
		if state.summon_timer <= 0.0:
			state.summon_timer = APEX_BROOD_CALL_INTERVAL
			intent["summon_wave"] = true
	# Attack cycle.
	state.attack_timer -= delta
	if state.attack_timer > 0.0 and intent["action"] == "idle":
		# Between attacks: hold the last telegraph family out of the
		# intent (no stale tell) and report idle.
		intent["action"] = "idle"
		return intent
	var attacks: Array = b["attacks"]
	if attacks.is_empty():
		return intent
	var atk_entry: Dictionary = attacks[state.attack_index % attacks.size()]
	state.attack_index += 1
	state.attacks_done += 1
	var cooldown := APEX_ATTACK_COOLDOWN
	if state.phase == 2:
		cooldown *= APEX_PHASE2_COOLDOWN_MULT
	state.attack_timer = cooldown
	var mult := float(atk_entry["damage_mult"])
	if state.phase == 2:
		mult *= APEX_PHASE2_DAMAGE_MULT
	# Twist adjustments (explicit, never hidden).
	if state.boss_id == "orochi" and str(atk_entry["name"]) == "Eight-Head Volley":
		mult *= float(state.heads_remaining) / 8.0
	if state.boss_id == "shuten_doji":
		mult *= frenzy_mult(state)
		intent["frenzy_mult"] = frenzy_mult(state)
		if state.attacks_done % APEX_DRINK_EVERY_NTH_ATTACK == 0:
			intent["drink_pause"] = true
			intent["action"] = "drink_pause"
			intent["telegraph"] = "drinking"
			intent["attack_kind"] = "drink_pause"
			intent["damage_mult"] = 0.0
			return intent
	if state.boss_id == "baba_yaga" and str(atk_entry["name"]) == "Skull Volley":
		mult *= float(state.totems_remaining) / 3.0
	if state.boss_id == "medusa" and str(atk_entry["mechanic"]) == "gaze":
		intent["gaze_active"] = true
	intent["action"] = "strike"
	intent["telegraph"] = str(atk_entry["tell"])
	intent["attack_kind"] = str(atk_entry["name"])
	intent["damage_mult"] = mult
	return intent
