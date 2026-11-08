class_name Behaviors
extends RefCounted
## Behavior mechanics for Abysmal (Wave 2, Worker 2C).
##
## WHAT THIS IS: the pure mechanics module behind the Phase 1 behavior
## catalog (design-notes/behavior-catalog-phase1.md). It implements venom,
## regen, charge telegraphs, AoE, breath cones, grapple, traps, dazzle,
## ranged/kiting, flying movement, and per-archetype distinctions. It does
## NOT spawn enemies, touch drops, change setup()/combat/scaling in
## enemy.gd, or wire any apex boss pattern. Apex-shared shapes (breath
## cone, AoE) are generic mechanics only; no apex-specific boss code lives
## here (Wave 4 owns apex).
##
## CREDITS: Aethelwarden Solas only. Never James's real name.
##
## SCALING CONTRACT (locked curves, NOT re-implemented here): enemy.gd
## setup() already scales HP = base_HP * depth^1.2, ATK = base_ATK *
## depth^1.05, DEF flat. Every mechanic below reads the state's ALREADY
## SCALED hp/max_hp/atk, so mechanics compose with those curves
## automatically: venom DPS scales with scaled ATK, regen scales with
## scaled max HP, trap/breath/AoE damage scales with scaled ATK. The
## integration step must hand this module scaled values (see below) and
## must NOT rescale inside it.
##
## =====================================================================
## INTEGRATION INTERFACE (for the Wave 2 integration step, enemy.gd)
## =====================================================================
## 1. Create one state per enemy when it spawns (or on first use):
##      var beh := Behaviors.new_state("charger", enemy.max_hp, enemy.atk, enemy.def)
##      beh.position = Vector2(enemy.grid_pos.x, enemy.grid_pos.y)
##    The archetype string may be a canonical archetype (see
##    CANONICAL_ARCHETYPES) or a staged composite string from enemy.gd
##    TYPES (e.g. "flyer/skirmisher", "tanker/regen" is "tank/regen",
##    "grappler/tank"). profile_for() resolves composites by composing
##    their two halves (see "Composite rule" below). Unknown strings
##    fall back to the brawler profile instead of crashing.
## 2. Every tick, call update() and read the returned intent Dictionary:
##      var intent: Dictionary = Behaviors.update(beh, delta, {
##          "player_pos": Vector2(...),   # optional; needed for range logic
##          "allies": 2,                  # optional; alive nearby allies
##          "in_combat": true,            # optional; drives regen variant
##          "want_charge": false,         # charger: request a charge
##          "wall_hit": false,            # charger: hit a wall mid-charge
##      })
##    Intent keys (all always present unless noted):
##      "action": String — "idle", "advance", "strike", "retreat",
##        "telegraph", "charging", "recover", "stunned", "hold",
##        "dive", "climb", "hover", "step_back", "perch", "dead",
##        "hidden" (ambusher still waiting), "drift".
##      "telegraph": String — "" or a readable tell: "pawing",
##        "club_raised", "inhale", "wail_windup", "tail_raised",
##        "reach_out", "dive_line", "shimmer", "crouch". Phone-first:
##        the integration step must RENDER the telegraph visibly (the
##        catalog requires tells that read at a glance on a phone).
##      "move_dir": Vector2 — desired movement direction (zero = stay).
##      "move_speed_mult": float — multiplier on the enemy's base speed.
##      "attack_kind": String — "" or "melee", "charge", "sting",
##        "scream", "breath", "arrow", "bolt", "grapple", "nip".
##      "damage_mult": float — multiplier on scaled ATK for this strike
##        (includes brute windup payoff, pack burst, first strike, ...).
##      "venom_damage": float — DoT damage dealt THIS tick (apply to the
##        player/target; 0 when no venom is active).
##      "healed": float — HP regenerated THIS tick (add to enemy hp,
##        clamped at max_hp by this module).
##      "grapple_damage": float — damage-while-held dealt THIS tick.
##      "dazzle_miss_chance": float — 0.5 while the TARGET is dazzled.
##      "altitude": float — flyer altitude; ground melee can only reach
##        the enemy while altitude < 0.5 (see "Flying rule" below).
##      "charge_phase" / "grapple_phase" / "flight_phase": Strings.
##      "can_player_move": bool — false only while the PLAYER is held
##        in a grapple (integration maps this onto the player, not the
##        enemy). "player_attack_mult": float — 0.5 while held.
## 3. Damage hooks (call these so mechanics stay consistent):
##      Behaviors.notify_damaged(beh, amount) — pauses regen, counts
##        damage taken during a grapple toward the auto-break threshold.
##      Behaviors.apply_venom(beh) — called when a sting/bite lands.
##      Behaviors.apply_dazzle(beh) — called when a dazzle flash lands
##        on a target (the target's own BehaviorState holds the timer).
## 4. Direct mechanic helpers (also used by update()): apply_venom_tick,
##    apply_regen, aoe_damage_at, aoe_staggers, breath_cone_hit,
##    place_trap / update_trap / disarm_trap, grapple_struggle, etc.
##    Tests drive these directly; integration may use them for
##    one-off effects (e.g. a scream) without running full update().
## 5. This module NEVER touches enemy.gd fields, drops, or spawning.
##    Drops stay ONLY the locked mappings (wolf->fur, boar->leather,
##    spider->silk; light/heavy leather by size; teeth/fangs as
##    Undercrucible reagents) — nothing here adds any.
## =====================================================================
## TUNING: every [TUNABLE] knob below is a const at the top of this file
## with a sane initial value. The soak step owns changing them; no knob
## here changes any locked curve or base stat.
## =====================================================================
## RULES DECIDED HERE (catalog left these [OPEN]; each is explicit so
## the soak step can overturn it deliberately, not by accident):
## - Venom: stacks cap 3; reapplying at cap refreshes all stacks.
## - Regen: damage pauses regen 3s. Only tank/regen regenerates.
## - Charge wall impact: STUNS the charger 1.5s (no wall damage).
## - Grapple: see "Grapple rules" below — full player-agency rules.
## - Traps: see "Trap rules" below — persist after the trapper dies.
## - Dazzle: 50% miss chance while active; no movement lock.
## - Flying: ground melee reaches only altitude < 0.5.
## - Phase: drifting wraiths are ALWAYS hittable, but take 50% damage
##   while drifting (the catalog says phase ignores cover for ITS OWN
##   movement; it never says untargetable, so we do not invent that).
## - Ambusher: a faint hint is ALWAYS visible (hint_visible = true);
##   hidden only gates the first-strike bonus, never zero-signal.
## - Composite rule: first half = movement base, second half = attack
##   flavor; combined speed = average, cooldown = faster of the two,
##   damage_mult = larger of the two, plus "secondary" recorded.

## --- Canonical archetypes (task list; each must differ observably) ---
const CANONICAL_ARCHETYPES: Array[String] = [
	"brawler", "brute", "tank", "skirmisher", "charger", "flyer",
	"caster", "ranged", "grappler", "trapper", "swarm", "ambusher",
	"pack", "phase", "venom", "tank/regen",
]

## --- Wave 3 space-form aliases -----------------------------------------
## enemy.gd TYPES uses space-form archetype strings for four types
## ("swarmer", "pack skirmisher", "phase skirmisher", "venom
## skirmisher"). Wave 2 resolved those only via the brawler fallback,
## so the named mechanics never fired (no swarm bonus, pack burst,
## phase drift/shimmer, or sting kind + tail_raised). The fix is this
## ONE mapping, applied by profile_for() and update() alike: the TYPES
## strings themselves are NOT renamed (saves, tests, and the
## procedural-motion profiles in enemy.gd all read the verbatim
## string), and BehaviorState.archetype stays verbatim too — only the
## mechanic lookup canonicalizes.
const ARCHETYPE_ALIASES := {
	"swarmer": "swarm",
	"pack skirmisher": "pack",
	"phase skirmisher": "phase",
	"venom skirmisher": "venom",
}


## Canonical form of one archetype half: the alias target for the four
## space forms above, otherwise the string unchanged. Composites are
## split by the caller before this is applied (update() canonicalizes
## the first half; profile_for() canonicalizes whole strings and
## composites recursively through its table/composite paths).
static func canonical_archetype(p_archetype: String) -> String:
	return str(ARCHETYPE_ALIASES.get(p_archetype, p_archetype))

## --- [TUNABLE] Venom ---
const VENOM_MAX_STACKS := 3  # [TUNABLE] stack cap
const VENOM_DURATION := 6.0  # [TUNABLE] seconds per stack
const VENOM_DPS_PER_STACK_FRACTION := 0.30  # [TUNABLE] x scaled ATK / s / stack
## --- [TUNABLE] Regen (tank/regen only) ---
const REGEN_OUT_OF_COMBAT_FRACTION := 0.02  # [TUNABLE] x max HP / s
const REGEN_IN_COMBAT_FRACTION := 0.005  # [TUNABLE] x max HP / s
const REGEN_PAUSE_AFTER_DAMAGE := 3.0  # [TUNABLE] seconds damage pauses regen
## --- [TUNABLE] Charge ---
const CHARGE_TELEGRAPH_TIME := 0.8  # [TUNABLE] pawing/snorting seconds
const CHARGE_SPEED_MULT := 3.0  # [TUNABLE] x base move speed while charging
const CHARGE_RANGE := 6.0  # [TUNABLE] tiles travelled before recovery
const CHARGE_RECOVER_TIME := 1.0  # [TUNABLE] slow-turn seconds after a miss
const CHARGE_WALL_STUN_TIME := 1.5  # [TUNABLE] stun seconds on wall impact
const CHARGE_COOLDOWN := 3.0  # [TUNABLE] seconds between charges
## --- [TUNABLE] AoE (scream / shockwave) ---
const SCREAM_RADIUS := 3.0  # [TUNABLE] tiles
const SCREAM_EDGE_FALLOFF := 0.25  # [TUNABLE] damage fraction at the edge
const SCREAM_STAGGER_FRACTION := 0.5  # [TUNABLE] stagger within radius * this
## --- [TUNABLE] Breath cone (generic; shared by drake + apex patterns) ---
const BREATH_RANGE := 4.0  # [TUNABLE] tiles
const BREATH_HALF_ANGLE_DEG := 30.0  # [TUNABLE] half-angle (60 deg cone)
const BREATH_DURATION := 1.5  # [TUNABLE] seconds the breath lasts
const BREATH_WINDUP_TIME := 0.8  # [TUNABLE] inhale seconds (the tell)
## --- [TUNABLE] Grapple ---
const GRAPPLE_TELEGRAPH_TIME := 0.5  # [TUNABLE] reach-out seconds
const GRAPPLE_RANGE := 1.5  # [TUNABLE] tiles
const GRAPPLE_HOLD_TIME := 5.0  # [TUNABLE] max hold seconds
const GRAPPLE_HOLD_DPS_FRACTION := 0.5  # [TUNABLE] x scaled ATK / s while held
const GRAPPLE_STRUGGLE_THRESHOLD := 5  # [TUNABLE] struggle inputs to break out
const GRAPPLE_BREAK_DAMAGE_FRACTION := 0.25  # [TUNABLE] x grappler max HP taken during hold auto-breaks it
const GRAPPLE_RECOVER_TIME := 1.0  # [TUNABLE] grappler recovery after a break
const GRAPPLE_HELD_ATTACK_MULT := 0.5  # [TUNABLE] held player's attack damage
## --- [TUNABLE] Traps ---
const TRAP_MAX_ACTIVE := 3  # [TUNABLE] traps alive per trapper
const TRAP_PLACE_COOLDOWN := 8.0  # [TUNABLE] seconds between placements
const TRAP_ARM_TIME := 2.0  # [TUNABLE] seconds before a trap can trigger
const TRAP_TRIGGER_RADIUS := 1.0  # [TUNABLE] tiles
const TRAP_DAMAGE_FRACTION := 1.0  # [TUNABLE] x scaled ATK on trigger
const TRAP_ROOT_TIME := 2.0  # [TUNABLE] seconds the victim cannot move
const TRAP_DISARM_CHANNEL := 1.5  # [TUNABLE] uninterrupted seconds to disarm
const TRAP_DISARM_RANGE := 1.5  # [TUNABLE] tiles (must stand this close)
## --- [TUNABLE] Dazzle ---
const DAZZLE_DURATION := 4.0  # [TUNABLE] seconds
const DAZZLE_MISS_CHANCE := 0.5  # [TUNABLE] miss chance while dazzled
const DAZZLE_TELEGRAPH_TIME := 0.3  # [TUNABLE] flash windup seconds
## --- [TUNABLE] Ranged / kiting ---
const RANGED_MIN_RANGE := 4.0  # [TUNABLE] preferred band, near edge
const RANGED_MAX_RANGE := 7.0  # [TUNABLE] preferred band, far edge
const RANGED_DRAW_TIME := 0.6  # [TUNABLE] draw/aim seconds before loosing
const RANGED_PROJECTILE_SPEED := 12.0  # [TUNABLE] tiles / s
const RANGED_STEP_BACK := 1.0  # [TUNABLE] tiles stepped back when closed on
const RANGED_COOLDOWN := 2.0  # [TUNABLE] seconds between volleys
## --- [TUNABLE] Flying ---
const FLY_HOVER_ALTITUDE := 1.5  # [TUNABLE] cruising altitude
const FLY_DIVE_ALTITUDE := 0.2  # [TUNABLE] altitude at strike (melee-reachable)
const FLY_MELEE_REACH_ALTITUDE := 0.5  # [TUNABLE] ground melee reaches below this
const FLY_DIVE_SPEED_MULT := 2.5  # [TUNABLE] x base speed while diving
const FLY_CLIMB_SPEED_MULT := 1.8  # [TUNABLE] x base speed while climbing away
## --- [TUNABLE] Archetype knobs ---
const BRUTE_WINDUP := 1.0  # [TUNABLE] seconds (the dodge window)
const BRUTE_DAMAGE_MULT := 1.5  # [TUNABLE] x scaled ATK on a clean connect
const BRAWLER_WINDUP := 0.3  # [TUNABLE] seconds
const CASTER_WINDUP := 1.2  # [TUNABLE] long scream windup seconds
const CASTER_COOLDOWN := 3.0  # [TUNABLE] seconds between screams
const SKIRMISHER_DWELL_TIME := 0.8  # [TUNABLE] seconds in range before disengage
const AMBUSH_FIRST_STRIKE_MULT := 1.5  # [TUNABLE] x scaled ATK on first strike from hidden
const PACK_BURST_THRESHOLD := 3  # [TUNABLE] allies needed for a pack burst
const PACK_BURST_MULT := 1.5  # [TUNABLE] x scaled ATK during a pack burst
const PHASE_DRIFT_DAMAGE_TAKEN_MULT := 0.5  # [TUNABLE] damage taken while drifting
const PHASE_MATERIALIZE_TIME := 0.5  # [TUNABLE] shimmer seconds before a phase-strike
const SWARM_ALLY_BONUS := 0.10  # [TUNABLE] +damage fraction per extra ally
const SWARM_ALLY_BONUS_CAP := 0.50  # [TUNABLE] cap on the swarm bonus
const GOBLIN_COURAGE_THRESHOLD := 2  # [TUNABLE] allies at which a goblin stops being cowardly


## Per-enemy mutable state. One instance per enemy; the integration step
## owns it and passes it back every tick. Plain data — no nodes, no
## scene-tree dependency, so headless tests can drive it directly.
class BehaviorState extends RefCounted:
	var archetype: String = "brawler"
	var hp: float = 10.0
	var max_hp: float = 10.0
	var atk: float = 1.0
	var def: float = 0.0
	var position := Vector2.ZERO
	var facing := Vector2(0, 1)
	# Shared timers.
	var attack_cooldown_timer: float = 0.0
	var regen_pause_timer: float = 0.0
	var windup_timer: float = 0.0
	# Venom: one remaining-time entry per stack.
	var venom_stacks: Array[float] = []
	# Charge state machine.
	var charge_phase: String = "idle"  # idle/telegraph/charging/recover/stunned
	var charge_timer: float = 0.0
	var charge_travelled: float = 0.0
	var charge_dir := Vector2.ZERO
	# Grapple state machine.
	var grapple_phase: String = "none"  # none/telegraph/held/recover
	var grapple_timer: float = 0.0
	var struggle_points: int = 0
	var grapple_damage_taken: float = 0.0
	# Traps placed by this enemy.
	var traps: Array[TrapState] = []
	var trap_cooldown_timer: float = 0.0
	# Dazzle on THIS state (when this enemy is the dazzled target).
	var dazzle_timer: float = 0.0
	# Ambusher / phase / flyer / skirmisher state.
	var hidden: bool = false
	var hint_visible: bool = true  # catalog rule: NEVER zero-signal
	var phase_drifting: bool = false
	var phase_timer: float = 0.0
	var altitude: float = 0.0
	var flight_phase: String = "ground"  # ground/hover/dive/climb/perch
	var dwell_timer: float = 0.0
	var in_combat: bool = false
	var dead: bool = false


## One placed trap. Traps are data, not nodes: the integration step
## renders them (with the catalog's very faint hint pre-perception) and
## calls update_trap() as the player moves.
class TrapState extends RefCounted:
	var position := Vector2.ZERO
	var armed: bool = false
	var arming_timer: float = 0.0
	var triggered: bool = false
	var disarmed: bool = false
	var disarm_progress: float = 0.0


## Factory: the integration step's one-line constructor.
static func new_state(p_archetype: String, p_max_hp: float, p_atk: float, p_def: float) -> BehaviorState:
	var s := BehaviorState.new()
	s.archetype = p_archetype
	s.max_hp = maxf(0.0, p_max_hp)
	s.hp = s.max_hp
	s.atk = maxf(0.0, p_atk)
	s.def = maxf(0.0, p_def)
	# Ambushers start hidden (with the faint hint still visible); flyers
	# start at hover altitude; everyone else starts on the ground.
	if profile_for(p_archetype).get("hidden_start", false):
		s.hidden = true
	if profile_for(p_archetype).get("flies", false):
		s.altitude = FLY_HOVER_ALTITUDE
		s.flight_phase = "hover"
	return s


## Archetype profile: the observable numbers that make each archetype
## behave differently. Every canonical archetype differs from every
## other in at least one field here (test-enforced). Fields:
## speed_mult, windup, recovery, attack_cooldown, damage_mult,
## range_min, range_max, retreat (bool), dwell, special (String tag).
static func profile_for(p_archetype: String) -> Dictionary:
	# Wave 3 alias fix: space forms resolve to their canonical profile
	# (never the brawler fallback). Recursion terminates: alias targets
	# are canonical table entries, never aliases themselves.
	if ARCHETYPE_ALIASES.has(p_archetype):
		return profile_for(str(ARCHETYPE_ALIASES[p_archetype]))
	var base: Dictionary = {
		"speed_mult": 1.0, "windup": 0.3, "recovery": 0.4,
		"attack_cooldown": 1.5, "damage_mult": 1.0,
		"range_min": 0.0, "range_max": 1.5, "retreat": false,
		"dwell": 0.0, "special": "none", "flies": false,
		"hidden_start": false, "regen": false, "secondary": "",
	}
	var table := {
		"brawler": {"speed_mult": 1.0, "windup": 0.3, "recovery": 0.4, "attack_cooldown": 1.5, "damage_mult": 1.0, "special": "steady_melee"},
		"brute": {"speed_mult": 0.85, "windup": 1.0, "recovery": 0.8, "attack_cooldown": 2.2, "damage_mult": 1.5, "special": "heavy_overhead"},
		"tank": {"speed_mult": 0.6, "windup": 0.8, "recovery": 1.0, "attack_cooldown": 2.5, "damage_mult": 1.25, "special": "slam"},
		"skirmisher": {"speed_mult": 1.4, "windup": 0.2, "recovery": 0.2, "attack_cooldown": 1.2, "damage_mult": 0.8, "retreat": true, "dwell": 0.8, "special": "hop_weave"},
		"charger": {"speed_mult": 1.0, "windup": 0.8, "recovery": 1.0, "attack_cooldown": 3.0, "damage_mult": 1.2, "special": "charge"},
		"flyer": {"speed_mult": 1.3, "windup": 0.3, "recovery": 0.3, "attack_cooldown": 1.8, "damage_mult": 0.9, "flies": true, "special": "swoop"},
		"caster": {"speed_mult": 0.8, "windup": 1.2, "recovery": 0.6, "attack_cooldown": 3.0, "damage_mult": 1.0, "range_min": 4.0, "range_max": 7.0, "special": "scream"},
		"ranged": {"speed_mult": 1.0, "windup": 0.6, "recovery": 0.4, "attack_cooldown": 2.0, "damage_mult": 1.0, "range_min": 4.0, "range_max": 7.0, "special": "kite_arrow"},
		"grappler": {"speed_mult": 0.7, "windup": 0.5, "recovery": 0.5, "attack_cooldown": 2.0, "damage_mult": 1.0, "special": "grab"},
		"trapper": {"speed_mult": 1.2, "windup": 0.2, "recovery": 0.3, "attack_cooldown": 1.4, "damage_mult": 0.7, "retreat": true, "special": "traps"},
		"swarm": {"speed_mult": 1.3, "windup": 0.15, "recovery": 0.15, "attack_cooldown": 0.9, "damage_mult": 0.6, "special": "nip"},
		"ambusher": {"speed_mult": 1.1, "windup": 0.2, "recovery": 0.5, "attack_cooldown": 1.6, "damage_mult": 1.0, "hidden_start": true, "special": "hidden_first_strike"},
		"pack": {"speed_mult": 1.15, "windup": 0.25, "recovery": 0.3, "attack_cooldown": 1.3, "damage_mult": 0.9, "special": "circle_burst"},
		"phase": {"speed_mult": 1.1, "windup": 0.5, "recovery": 0.3, "attack_cooldown": 1.7, "damage_mult": 1.1, "special": "phase_strike"},
		"venom": {"speed_mult": 1.3, "windup": 0.4, "recovery": 0.3, "attack_cooldown": 2.5, "damage_mult": 0.8, "special": "flank_sting"},
		"tank/regen": {"speed_mult": 0.55, "windup": 0.7, "recovery": 0.9, "attack_cooldown": 2.6, "damage_mult": 1.1, "regen": true, "special": "swat_regen"},
	}
	if table.has(p_archetype):
		for k in table[p_archetype]:
			base[k] = table[p_archetype][k]
		return base
	# Composite (e.g. "flyer/skirmisher"): first half = movement base,
	# second half = attack flavor. Combined speed = average, cooldown =
	# faster of the two, damage = larger of the two, plus "secondary"
	# so the composite is observably distinct from both parents.
	if "/" in p_archetype:
		var parts := p_archetype.split("/")
		if parts.size() == 2:
			var a := profile_for(parts[0])
			var b := profile_for(parts[1])
			a["speed_mult"] = (float(a["speed_mult"]) + float(b["speed_mult"])) * 0.5
			a["attack_cooldown"] = minf(float(a["attack_cooldown"]), float(b["attack_cooldown"]))
			a["damage_mult"] = maxf(float(a["damage_mult"]), float(b["damage_mult"]))
			a["secondary"] = parts[1]
			a["special"] = str(a["special"]) + "+" + str(b["special"])
			if bool(b.get("flies", false)):
				a["flies"] = true
			if bool(b.get("hidden_start", false)) or bool(a.get("hidden_start", false)):
				a["hidden_start"] = true
			if bool(b.get("regen", false)):
				a["regen"] = true
			return a
	# Unknown archetype: brawler fallback, never a crash.
	return base


static func _clamp_delta(delta: float) -> float:
	if delta <= 0.0 or is_nan(delta) or is_inf(delta):
		return 0.0
	return delta


## --- Venom ---
## Reapplying at cap refreshes every stack to full duration (decided
## rule). Returns the new stack count. No-op on dead / zero-ATK states
## beyond bookkeeping (still safe to call).
static func apply_venom(state: BehaviorState) -> int:
	if state == null or state.dead:
		return 0
	if state.venom_stacks.size() >= VENOM_MAX_STACKS:
		for i in state.venom_stacks.size():
			state.venom_stacks[i] = VENOM_DURATION
		return state.venom_stacks.size()
	state.venom_stacks.append(VENOM_DURATION)
	return state.venom_stacks.size()


## Ticks venom: returns damage dealt this tick. Expired stacks drop.
## Damage = stacks * 0.30 * scaled ATK * delta (scales with depth via ATK).
static func apply_venom_tick(state: BehaviorState, delta: float) -> float:
	delta = _clamp_delta(delta)
	if state == null or state.dead or delta == 0.0 or state.venom_stacks.is_empty():
		return 0.0
	var dmg := float(state.venom_stacks.size()) * VENOM_DPS_PER_STACK_FRACTION * state.atk * delta
	var kept: Array[float] = []
	for t in state.venom_stacks:
		var rem := t - delta
		if rem > 0.0:
			kept.append(rem)
	state.venom_stacks = kept
	return dmg


## --- Regen ---
## Only tank/regen regenerates (plain tank does not — catalog §2.3).
## Damage pauses regen for REGEN_PAUSE_AFTER_DAMAGE seconds. Returns HP
## actually restored (0 at full HP, while paused, while dead, or for
## non-regen archetypes). Heals against scaled max HP.
static func apply_regen(state: BehaviorState, delta: float, in_combat: bool) -> float:
	delta = _clamp_delta(delta)
	if state == null or state.dead or delta == 0.0 or state.hp >= state.max_hp:
		return 0.0
	if not bool(profile_for(state.archetype).get("regen", false)):
		return 0.0
	if state.regen_pause_timer > 0.0:
		state.regen_pause_timer = maxf(0.0, state.regen_pause_timer - delta)
		return 0.0
	var frac := REGEN_IN_COMBAT_FRACTION if in_combat else REGEN_OUT_OF_COMBAT_FRACTION
	var healed := minf(frac * state.max_hp * delta, state.max_hp - state.hp)
	state.hp += healed
	return healed


## Shared damage hook: integration MUST call this when the enemy takes
## damage (in addition to enemy.gd take_damage) so regen pausing and
## grapple auto-break stay correct.
static func notify_damaged(state: BehaviorState, amount: float) -> void:
	if state == null or amount <= 0.0:
		return
	state.regen_pause_timer = REGEN_PAUSE_AFTER_DAMAGE
	if state.grapple_phase == "held":
		state.grapple_damage_taken += amount
		if state.grapple_damage_taken >= GRAPPLE_BREAK_DAMAGE_FRACTION * state.max_hp and state.max_hp > 0.0:
			break_grapple(state, "damage_threshold")


## --- Charge telegraphs ---
## Phase machine: idle -> telegraph (pawing/snorting, visible tell) ->
## charging (straight line, cannot steer) -> recover (slow turn) -> idle.
## start_charge() only fires from idle with the cooldown elapsed.
static func start_charge(state: BehaviorState) -> bool:
	if state == null or state.dead or state.charge_phase != "idle":
		return false
	if state.attack_cooldown_timer > 0.0:
		return false
	state.charge_phase = "telegraph"
	state.charge_timer = CHARGE_TELEGRAPH_TIME
	state.charge_travelled = 0.0
	return true


## Advances the charge machine one tick. wall_hit=true while charging
## stuns instead of recovering (decided rule: stun, no wall damage).
## Returns the current phase string.
static func update_charge(state: BehaviorState, delta: float, wall_hit: bool = false) -> String:
	delta = _clamp_delta(delta)
	if state == null:
		return "idle"
	match state.charge_phase:
		"telegraph":
			state.charge_timer -= delta
			if state.charge_timer <= 0.0:
				state.charge_phase = "charging"
				state.charge_travelled = 0.0
		"charging":
			if wall_hit:
				state.charge_phase = "stunned"
				state.charge_timer = CHARGE_WALL_STUN_TIME
			else:
				state.charge_travelled += CHARGE_SPEED_MULT * delta
				if state.charge_travelled >= CHARGE_RANGE:
					state.charge_phase = "recover"
					state.charge_timer = CHARGE_RECOVER_TIME
		"recover", "stunned":
			state.charge_timer -= delta
			if state.charge_timer <= 0.0:
				state.charge_phase = "idle"
				state.attack_cooldown_timer = CHARGE_COOLDOWN
	return state.charge_phase


static func charge_telegraph(state: BehaviorState) -> String:
	if state != null and state.charge_phase == "telegraph":
		return "pawing"
	if state != null and state.charge_phase == "charging":
		return "charge_line"
	return ""


## --- AoE (scream / shockwave, generic) ---
## Linear falloff: full damage at the center, SCREAM_EDGE_FALLOFF at the
## rim, zero outside. Returns damage for a target at `dist` tiles.
static func aoe_damage_at(dist: float, radius: float, base_damage: float) -> float:
	if dist < 0.0 or radius <= 0.0 or base_damage <= 0.0:
		return 0.0
	if dist > radius:
		return 0.0
	var t := dist / radius
	return base_damage * lerpf(1.0, SCREAM_EDGE_FALLOFF, t)


## Stagger (interrupt/knock) only in the inner half of the radius.
static func aoe_staggers(dist: float, radius: float) -> bool:
	if radius <= 0.0 or dist < 0.0:
		return false
	return dist <= radius * SCREAM_STAGGER_FRACTION


## --- Breath cone (generic; drake + apex-shared shape, no apex code) ---
## True when the target sits inside the cone: within range AND within
## half-angle of the facing direction. Zero-length vectors never hit.
static func breath_cone_hit(origin: Vector2, facing: Vector2, target: Vector2, range_tiles: float = BREATH_RANGE, half_angle_deg: float = BREATH_HALF_ANGLE_DEG) -> bool:
	var to_target := target - origin
	if to_target.length_squared() <= 0.0001 or facing.length_squared() <= 0.0001:
		return false
	if to_target.length() > range_tiles:
		return false
	var angle: float = acos(clampf(facing.normalized().dot(to_target.normalized()), -1.0, 1.0))
	return angle <= deg_to_rad(half_angle_deg)


## --- Grapple ---
## GRAPPLE RULES (defined here — the catalog flags grapple as unwired):
## 1. Grab: telegraph 0.5s reach-out, then hold, only within 1.5 tiles.
## 2. While held, the VICTIM: cannot move; may still melee at 0.5x
##    damage; cannot flee/retreat; may struggle (see below). The
##    GRAPPLER keeps dealing 0.5x its scaled ATK per second.
## 3. Break-out, any of: (a) 5 struggle inputs during the hold;
##    (b) the grappler takes >= 25% of its max HP during the hold
##    (see notify_damaged); (c) the hold timer (5s) expires.
## 4. On break: the grappler recovers 1.0s (cannot re-grab), and the
##    victim is free immediately with no lingering penalty.
static func try_grab(state: BehaviorState, dist_to_player: float) -> bool:
	if state == null or state.dead or state.grapple_phase != "none":
		return false
	if dist_to_player > GRAPPLE_RANGE:
		return false
	state.grapple_phase = "telegraph"
	state.grapple_timer = GRAPPLE_TELEGRAPH_TIME
	return true


## Advances the grapple machine. Returns damage-while-held this tick
## (0 unless currently holding). The telegraph completes into a hold
## automatically — the integration step is responsible for letting the
## player dodge/block during the telegraph window.
static func update_grapple(state: BehaviorState, delta: float) -> float:
	delta = _clamp_delta(delta)
	if state == null:
		return 0.0
	match state.grapple_phase:
		"telegraph":
			state.grapple_timer -= delta
			if state.grapple_timer <= 0.0:
				state.grapple_phase = "held"
				state.grapple_timer = GRAPPLE_HOLD_TIME
				state.struggle_points = 0
				state.grapple_damage_taken = 0.0
			return 0.0
		"held":
			state.grapple_timer -= delta
			if state.grapple_timer <= 0.0:
				break_grapple(state, "expired")
				return 0.0
			return GRAPPLE_HOLD_DPS_FRACTION * state.atk * delta
		"recover":
			state.grapple_timer -= delta
			if state.grapple_timer <= 0.0:
				state.grapple_phase = "none"
	return 0.0


## One struggle input from the held player. Returns true if this input
## broke the hold.
static func grapple_struggle(state: BehaviorState) -> bool:
	if state == null or state.grapple_phase != "held":
		return false
	state.struggle_points += 1
	if state.struggle_points >= GRAPPLE_STRUGGLE_THRESHOLD:
		break_grapple(state, "struggle")
		return true
	return false


static func break_grapple(state: BehaviorState, _reason: String) -> void:
	if state == null:
		return
	state.grapple_phase = "recover"
	state.grapple_timer = GRAPPLE_RECOVER_TIME
	state.struggle_points = 0
	state.grapple_damage_taken = 0.0


## Restrictions on the HELD PLAYER (integration applies these to the
## player, not the enemy). Free players get the defaults.
static func grapple_player_restrictions(state: BehaviorState) -> Dictionary:
	if state != null and state.grapple_phase == "held":
		return {"can_move": false, "can_flee": false, "attack_mult": GRAPPLE_HELD_ATTACK_MULT, "held": true}
	return {"can_move": true, "can_flee": true, "attack_mult": 1.0, "held": false}


## --- Traps ---
## TRAP RULES (defined here — the catalog flags trapper as thinnest):
## 1. Placement: max 3 active per trapper, 8s cooldown, 2s arming time
##    (an arming trap cannot trigger). Placing is silent in code; the
##    integration step must render the catalog's very faint hint even
##    before perception reveals the trap fully.
## 2. Trigger: a victim entering within 1.0 tile of an ARMED trap takes
##    1.0x the trapper's scaled ATK and is rooted 2.0s (cannot move).
##    The trap is consumed on trigger.
## 3. Disarm: standing within 1.5 tiles and channeling uninterrupted
##    for 1.5s disarms it (channel progress resets if interrupted or
##    the player moves out of range). Returns true on completion.
## 4. Traps PERSIST after the trapper dies (they are placed objects,
##    not auras). Only trigger/disarm removes them.
static func place_trap(state: BehaviorState, pos: Vector2) -> TrapState:
	if state == null or state.dead:
		return null
	if state.trap_cooldown_timer > 0.0:
		return null
	var live := 0
	for t in state.traps:
		if not t.triggered and not t.disarmed:
			live += 1
	if live >= TRAP_MAX_ACTIVE:
		return null
	var trap := TrapState.new()
	trap.position = pos
	trap.arming_timer = TRAP_ARM_TIME
	state.traps.append(trap)
	state.trap_cooldown_timer = TRAP_PLACE_COOLDOWN
	return trap


## Advances one trap. Returns a result dict: {triggered, damage,
## root_time}. Triggering consumes the trap; arming traps never trigger.
static func update_trap(state: BehaviorState, trap: TrapState, delta: float, victim_pos: Vector2) -> Dictionary:
	var out := {"triggered": false, "damage": 0.0, "root_time": 0.0}
	delta = _clamp_delta(delta)
	if state == null or trap == null or trap.triggered or trap.disarmed:
		return out
	if not trap.armed:
		trap.arming_timer -= delta
		if trap.arming_timer <= 0.0:
			trap.armed = true
		return out
	if trap.position.distance_to(victim_pos) <= TRAP_TRIGGER_RADIUS:
		trap.triggered = true
		out["triggered"] = true
		out["damage"] = TRAP_DAMAGE_FRACTION * state.atk
		out["root_time"] = TRAP_ROOT_TIME
	return out


## One disarm-channel tick. channeling=false or out-of-range resets
## progress. Returns true the tick the trap is disarmed.
static func disarm_trap(trap: TrapState, delta: float, channeling: bool, dist_to_player: float) -> bool:
	delta = _clamp_delta(delta)
	if trap == null or trap.triggered or trap.disarmed:
		return false
	if not channeling or dist_to_player > TRAP_DISARM_RANGE:
		trap.disarm_progress = 0.0
		return false
	trap.disarm_progress += delta
	if trap.disarm_progress >= TRAP_DISARM_CHANNEL:
		trap.disarmed = true
		return true
	return false


## --- Dazzle ---
## Dazzled targets miss 50% of attacks for 4s; movement is NOT locked.
## (The catalog leaves dazzle's effect [OPEN]; this is the decided rule
## for the soak step to tune.) The timer lives on the TARGET's state.
static func apply_dazzle(state: BehaviorState) -> void:
	if state == null or state.dead:
		return
	state.dazzle_timer = DAZZLE_DURATION


static func update_dazzle(state: BehaviorState, delta: float) -> float:
	delta = _clamp_delta(delta)
	if state == null:
		return 0.0
	state.dazzle_timer = maxf(0.0, state.dazzle_timer - delta)
	return state.dazzle_timer


static func dazzle_miss_chance(state: BehaviorState) -> float:
	if state != null and state.dazzle_timer > 0.0:
		return DAZZLE_MISS_CHANCE
	return 0.0


## --- Ranged / kiting ---
## Returns the kiting decision for a target at `dist` tiles:
## "step_back" (too close), "hold" (in band), "advance" (too far),
## "cornered" (too close AND no room to step back).
static func ranged_intent(dist: float, can_step_back: bool = true) -> String:
	if dist < RANGED_MIN_RANGE:
		return "step_back" if can_step_back else "cornered"
	if dist > RANGED_MAX_RANGE:
		return "advance"
	return "hold"


## --- Flying ---
## FLYING RULE: ground melee reaches the enemy only while altitude <
## 0.5. Hover = 1.5 (unreachable), dive strike = 0.2 (reachable),
## climb-away returns to hover. update_flight() moves altitude toward
## the phase target; the integration step picks phases (hover until
## the dive commit, climb immediately after the strike).
static func melee_reachable(state: BehaviorState) -> bool:
	if state == null:
		return false
	return state.altitude < FLY_MELEE_REACH_ALTITUDE


static func update_flight(state: BehaviorState, delta: float, want_dive: bool = false) -> String:
	delta = _clamp_delta(delta)
	if state == null:
		return "ground"
	match state.flight_phase:
		"hover":
			state.altitude = FLY_HOVER_ALTITUDE
			if want_dive:
				state.flight_phase = "dive"
		"dive":
			state.altitude = maxf(FLY_DIVE_ALTITUDE, state.altitude - FLY_DIVE_SPEED_MULT * delta)
			if state.altitude <= FLY_DIVE_ALTITUDE + 0.001:
				state.flight_phase = "climb"
		"climb":
			state.altitude = minf(FLY_HOVER_ALTITUDE, state.altitude + FLY_CLIMB_SPEED_MULT * delta)
			if state.altitude >= FLY_HOVER_ALTITUDE - 0.001:
				state.flight_phase = "hover"
		"perch":
			state.altitude = FLY_HOVER_ALTITUDE
	return state.flight_phase


## --- Ambusher / pack / phase / swarm helpers ---
## First-strike bonus applies ONLY while hidden; striking reveals.
static func ambush_first_strike_mult(state: BehaviorState) -> float:
	if state != null and state.hidden:
		return AMBUSH_FIRST_STRIKE_MULT
	return 1.0


static func ambush_reveal(state: BehaviorState) -> void:
	if state != null:
		state.hidden = false


## Pack burst is live when at least PACK_BURST_THRESHOLD allies fight.
static func pack_burst_active(allies: int) -> bool:
	return allies >= PACK_BURST_THRESHOLD


static func pack_damage_mult(allies: int) -> float:
	return PACK_BURST_MULT if pack_burst_active(allies) else 1.0


## Drifting phase enemies are hittable but take half damage.
static func phase_damage_taken_mult(state: BehaviorState) -> float:
	if state != null and state.phase_drifting:
		return PHASE_DRIFT_DAMAGE_TAKEN_MULT
	return 1.0


## Swarm aggregate bonus: +10% per extra ally, capped at +50%.
static func swarm_damage_mult(allies: int) -> float:
	var extra := maxi(0, allies)
	return 1.0 + minf(float(extra) * SWARM_ALLY_BONUS, SWARM_ALLY_BONUS_CAP)


## Goblin courage rule: cowardly (retreats) alone, committed in numbers.
static func goblin_is_cowardly(allies: int) -> bool:
	return allies < GOBLIN_COURAGE_THRESHOLD


## --- Master tick ---
## Ticks shared timers, runs the archetype's machine, and returns the
## intent Dictionary documented at the top of this file. Safe on
## zero/negative delta, zero HP, and unknown archetypes. Never raises.
static func update(state: BehaviorState, delta: float, ctx: Dictionary = {}) -> Dictionary:
	var intent := {
		"action": "idle", "telegraph": "", "move_dir": Vector2.ZERO,
		"move_speed_mult": 1.0, "attack_kind": "", "damage_mult": 1.0,
		"venom_damage": 0.0, "healed": 0.0, "grapple_damage": 0.0,
		"dazzle_miss_chance": 0.0, "altitude": 0.0,
		"charge_phase": "idle", "grapple_phase": "none",
		"flight_phase": "ground", "can_player_move": true,
		"player_attack_mult": 1.0,
	}
	if state == null:
		return intent
	delta = _clamp_delta(delta)
	var prof := profile_for(state.archetype)
	intent["altitude"] = state.altitude
	intent["charge_phase"] = state.charge_phase
	intent["grapple_phase"] = state.grapple_phase
	intent["flight_phase"] = state.flight_phase
	if state.dead or state.hp <= 0.0:
		intent["action"] = "dead"
		return intent
	# Shared timers.
	if state.attack_cooldown_timer > 0.0:
		state.attack_cooldown_timer = maxf(0.0, state.attack_cooldown_timer - delta)
	if state.trap_cooldown_timer > 0.0:
		state.trap_cooldown_timer = maxf(0.0, state.trap_cooldown_timer - delta)
	intent["venom_damage"] = apply_venom_tick(state, delta)
	intent["healed"] = apply_regen(state, delta, bool(ctx.get("in_combat", false)))
	intent["dazzle_miss_chance"] = dazzle_miss_chance(state)
	update_dazzle(state, delta)
	intent["dazzle_miss_chance"] = dazzle_miss_chance(state)
	# Target geometry (optional context).
	var has_player := ctx.has("player_pos")
	var dist := 999.0
	var dir := Vector2.ZERO
	if has_player:
		var pp: Vector2 = ctx["player_pos"]
		var to_player := pp - state.position
		dist = to_player.length()
		if dist > 0.001:
			dir = to_player.normalized()
	# Archetype machines. `canon` = first half of a composite string,
	# canonicalized through the Wave 3 alias map (so "pack skirmisher"
	# runs the pack machine, "phase skirmisher" the phase machine, etc.
	# — never the default steady-advance arm).
	var canon := canonical_archetype(str(state.archetype).split("/")[0])
	if state.hidden:
		intent["action"] = "hidden"
		intent["damage_mult"] = AMBUSH_FIRST_STRIKE_MULT
		return intent
	match canon:
		"charger":
			if bool(ctx.get("want_charge", false)):
				start_charge(state)
			update_charge(state, delta, bool(ctx.get("wall_hit", false)))
			intent["charge_phase"] = state.charge_phase
			intent["telegraph"] = charge_telegraph(state)
			match state.charge_phase:
				"telegraph":
					intent["action"] = "telegraph"
					intent["move_speed_mult"] = 0.0
				"charging":
					intent["action"] = "charging"
					intent["attack_kind"] = "charge"
					intent["move_dir"] = dir if dir != Vector2.ZERO else state.facing
					intent["move_speed_mult"] = CHARGE_SPEED_MULT
					intent["damage_mult"] = float(prof["damage_mult"])
				"recover":
					intent["action"] = "recover"
					intent["move_speed_mult"] = 0.3
				"stunned":
					intent["action"] = "stunned"
					intent["move_speed_mult"] = 0.0
				_:
					intent["action"] = "advance"
					intent["move_dir"] = dir
					intent["move_speed_mult"] = float(prof["speed_mult"])
		"grappler":
			intent["grapple_damage"] = update_grapple(state, delta)
			intent["grapple_phase"] = state.grapple_phase
			var restr := grapple_player_restrictions(state)
			intent["can_player_move"] = bool(restr["can_move"])
			intent["player_attack_mult"] = float(restr["attack_mult"])
			match state.grapple_phase:
				"telegraph":
					intent["action"] = "telegraph"
					intent["telegraph"] = "reach_out"
				"held":
					intent["action"] = "hold"
					intent["attack_kind"] = "grapple"
				_:
					intent["action"] = "advance"
					intent["move_dir"] = dir
					intent["move_speed_mult"] = float(prof["speed_mult"])
		"caster":
			intent["action"] = "advance"
			intent["move_dir"] = dir
			intent["move_speed_mult"] = float(prof["speed_mult"])
			if has_player and dist <= float(prof["range_max"]) and state.attack_cooldown_timer <= 0.0:
				intent["action"] = "telegraph"
				intent["telegraph"] = "wail_windup"
				intent["attack_kind"] = "scream"
		"ranged":
			var ri := ranged_intent(dist, bool(ctx.get("can_step_back", true))) if has_player else "hold"
			if ri == "step_back":
				intent["action"] = "step_back"
				intent["move_dir"] = -dir
			elif ri == "advance":
				intent["action"] = "advance"
				intent["move_dir"] = dir
			elif ri == "cornered":
				intent["action"] = "cornered"
			else:
				intent["action"] = "hold"
				intent["attack_kind"] = "arrow"
			intent["move_speed_mult"] = float(prof["speed_mult"])
		"flyer":
			update_flight(state, delta, bool(ctx.get("want_dive", false)))
			intent["flight_phase"] = state.flight_phase
			intent["altitude"] = state.altitude
			match state.flight_phase:
				"dive":
					intent["action"] = "dive"
					intent["telegraph"] = "dive_line"
					intent["move_dir"] = dir
					intent["move_speed_mult"] = FLY_DIVE_SPEED_MULT
				"climb":
					intent["action"] = "climb"
					intent["move_speed_mult"] = FLY_CLIMB_SPEED_MULT
				_:
					intent["action"] = "hover"
					intent["attack_kind"] = "bolt" if state.archetype == "flyer/caster" else ""
		"phase":
			state.phase_drifting = true
			intent["action"] = "drift"
			intent["move_dir"] = dir
			intent["move_speed_mult"] = float(prof["speed_mult"])
			intent["telegraph"] = "shimmer"
		"skirmisher", "swarm", "pack", "venom":
			intent["move_speed_mult"] = float(prof["speed_mult"])
			intent["move_dir"] = dir
			if canon == "pack" and pack_burst_active(int(ctx.get("allies", 0))):
				intent["damage_mult"] = PACK_BURST_MULT
				intent["attack_kind"] = "burst"
				intent["action"] = "strike"
			elif canon == "swarm":
				intent["damage_mult"] = swarm_damage_mult(int(ctx.get("allies", 0)))
				intent["attack_kind"] = "nip"
				intent["action"] = "strike" if has_player and dist <= 1.5 else "advance"
			elif canon == "venom":
				intent["attack_kind"] = "sting"
				intent["action"] = "strike" if has_player and dist <= 1.5 else "advance"
				intent["telegraph"] = "tail_raised" if has_player and dist <= 2.0 else ""
			else:
				intent["action"] = "strike" if has_player and dist <= 1.5 else "advance"
				if bool(prof.get("retreat", false)):
					state.dwell_timer += delta
					if state.dwell_timer >= SKIRMISHER_DWELL_TIME:
						state.dwell_timer = 0.0
						intent["action"] = "retreat"
						intent["move_dir"] = -dir
		_:
			# brawler / brute / tank / trapper / ambusher (revealed) /
			# tank/regen and any unknown archetype: steady advance.
			intent["action"] = "strike" if has_player and dist <= 1.5 else "advance"
			intent["move_dir"] = dir
			intent["move_speed_mult"] = float(prof["speed_mult"])
			intent["damage_mult"] = float(prof["damage_mult"])
			if canon == "brute":
				intent["telegraph"] = "club_raised" if has_player and dist <= 2.0 else ""
			if canon == "trapper":
				intent["attack_kind"] = "jab"
	return intent
