extends Node
const ShopScript := preload("res://scripts/shop.gd")
const GuildHallScript := preload("res://scripts/guild_hall.gd")
## GameState autoload — single source of truth for the current run.
## Player stats, run stats, and signals the HUD listens to.

signal stats_changed
signal log_message(text: String)
signal player_died
signal depth_changed(new_depth: int)
signal mode_changed(new_mode: int)

# --- Phase 3: game state (dungeon / town / overworld) -----------------------
# The state machine itself lives in scripts/game_mode.gd (class GameMode);
# this is the current state plus the guarded transition entry point.
# Town is the between-runs hub: entered on run end, left via delve/travel.
var mode: int = GameMode.State.DUNGEON


## Guarded transition: returns false (and changes nothing) on an illegal
## move — see GameMode.can_transition. Same-state is a no-op true.
func set_mode(next: int) -> bool:
	if next == mode:
		return true
	if not GameMode.can_transition(mode, next):
		push_warning("set_mode: illegal transition %s -> %s" % [
			GameMode.state_name(mode), GameMode.state_name(next)])
		return false
	mode = next
	mode_changed.emit(next)
	return true


# --- Run state -------------------------------------------------------------
var run_number: int = 1
var depth: int = 1
var alive: bool = true
# Idle ON by default: the crawler delves on its own; the player opts OUT
# to take manual control (director's call).
var idle_mode: bool = true

## Dev-only speed multiplier for stress testing (never a player-facing stat).
## Scales the idle brain's action rate and the player's move animation.
## 1.0 = normal. Set via the -- --speed=N cheat flag or by beta tests.
var speed_mult: float = 1.0
## Dev-only one-shot (hidden dev corner button): when true, the NEXT floor
## main.gd generates is forced to be a monster floor, reusing the normal
## horde machinery. Consumed at generation time. Runtime-only — it is in
## no save dict and no settings file, so it never survives an app restart.
var dev_force_next_monster_floor: bool = false
## Lifetime idle-brain actions taken (telemetry for beta/stress tests).
var brain_steps: int = 0

# --- Lifetime totals (across runs; prestige/ascension hooks later) ---------
var kills: int = 0
var gold: float = 0.0

# --- Current-run stats -----------------------------------------------------
var run_kills: int = 0
var run_gold: float = 0.0

# --- Player stats ----------------------------------------------------------
var level: int = 1
var xp: float = 0.0
var xp_next: float = 20.0
var max_hp: float = 50.0
var hp: float = 50.0
var atk: float = 6.0
var def: float = 1.0

# --- Equipment (Phase 2 PRIORITY: inventory/equipment UI) -------------------
# Design: the crawler delves on its own — the PLAYER's job is gear.
# Each slot holds an item Dictionary or is empty ({}).
# Item shape: {"name": String, "slot": String, "rarity": String,
#              "atk": float, "def": float, "max_hp": float, "level": int}
# TODO Phase 2: equipment/inventory UI — loot drops, equip/unequip,
#   upgrades, rarity tiers. Then wire gear_bonus() into combat stats.
var equipment: Dictionary = {
	"weapon": {},
	"armor": {},
	"trinket": {},
}


## Equip an item dict into a slot (replaces whatever was there).
func equip(slot: String, item: Dictionary) -> void:
	if not equipment.has(slot):
		return
	equipment[slot] = item
	stats_changed.emit()


## Remove whatever is in a slot.
func unequip(slot: String) -> void:
	if equipment.has(slot):
		equipment[slot] = {}
		stats_changed.emit()


## Sum of a named bonus across all equipped items (e.g. "atk", "def").
func gear_bonus(stat_name: String) -> float:
	var total := 0.0
	for slot in equipment:
		var item: Dictionary = equipment[slot]
		if not item.is_empty() and item.has(stat_name):
			total += float(item[stat_name])
	return total


# --- Potions (v0.2.0: loot pickups; mana is a stub for the magic system) ----
var health_potions: int = 0
var mana_potions: int = 0
const POTION_HEAL_FRAC := 0.40

# --- Run telemetry (feeds beta tests + future stats UI) ---------------------
var chests_opened: int = 0
var loot_collected: int = 0
var gear_equipped: int = 0
var potions_drunk: int = 0
## Floor-1 onboarding: paused popup tutorial. Shown once on a fresh boot.
var tutorial_done: bool = false

# --- Offline earnings (v0.6.0): rolling 30-min measurement of live ------
# kills/gold. The medians ride in the save; the tracker itself never
# persists (a fresh process starts measuring from zero).
var offline := OfflineEarnings.new()

# --- Run loot + heirlooms (v0.3.0) -----------------------------------------
# Every weapon/armor found this run (equipped OR sold) — shown on the
# game-over screen so the player can sort the haul.
var run_gear: Array = []
# Gear chosen on the game-over screen to carry into the next run.
# Persists across runs until the player picks replacements.
var heirloom_weapon: Dictionary = {}
var heirloom_armor: Dictionary = {}


## Set the heirlooms chosen on the game-over screen.
func set_heirlooms(weapon: Dictionary, armor: Dictionary) -> void:
	heirloom_weapon = weapon
	heirloom_armor = armor


func add_potion(kind: String) -> void:
	if kind == "health_potion":
		health_potions += 1
	elif kind == "mana_potion":
		mana_potions += 1
	stats_changed.emit()


## Quaff a health potion. Returns false if none left or already full.
func drink_health_potion() -> bool:
	if not alive or health_potions <= 0 or hp >= max_hp:
		return false
	health_potions -= 1
	hp = minf(max_hp, hp + max_hp * POTION_HEAL_FRAC * potion_mult())
	potions_drunk += 1
	add_log("Quaffed a health potion (+%s HP)." % BigNumbers.format(max_hp * POTION_HEAL_FRAC * potion_mult()))
	stats_changed.emit()
	return true


## Combat-effective stats: base + equipped gear bonuses.
func eff_atk() -> float:
	return atk + gear_bonus("atk")


func eff_def() -> float:
	return def + gear_bonus("def")


# --- Phase 2+ stubs (TODO: skills / magic) --------------------------------
var skills: Dictionary = {}        # skill id -> level (persistent; death shop)
var charms: Dictionary = {}        # charm id -> copies owned (persistent shop items)
var spells: Dictionary = {}        # TODO: magic system (mana, spellbook)
# Prestige/ascension meta progression lives in the Prestige autoload
# (autoload/prestige.gd) — tokens, cycle depth records, ascension perks.

# --- Guild hall (Phase 2: separate meta track, NOT a death-shop tab) -------
# Linear 4-stage unlock chain: run-down tavern -> guild -> expanded guild ->
# adventurers' guild HQ. Bought with gold; later stages need lifetime depth
# milestones. Meta progression — persists across runs AND deaths, never
# wiped. See scripts/guild_hall.gd (data + rules) and
# scripts/guild_hall_view.gd (stub 3D stage representation).
var guild_stage: int = 0           # highest stage owned (0 = nothing yet)
var max_depth: int = 1             # deepest floor reached on ANY run


## --- Death-shop helpers ------------------------------------------------
## Skills and charms persist across runs — they're the progression that
## STAYS. Bought with gold on the death screen, active from the next delve.

func skill_level(skill_id: String) -> int:
	return int(skills.get(skill_id, 0))


func charm_count(charm_id: String) -> int:
	return int(charms.get(charm_id, 0))


## Buy the next level of a skill. Returns true on success.
func buy_skill(skill_id: String) -> bool:
	var s := ShopScript.skill_by_id(skill_id)
	if s.is_empty() or not bool(s.get("available", true)):
		return false
	var price := ShopScript.skill_price(skill_id, skill_level(skill_id))
	if gold < price:
		return false
	gold -= price
	skills[skill_id] = skill_level(skill_id) + 1
	stats_changed.emit()
	return true


## Buy one copy of a charm. Returns true on success.
func buy_charm(charm_id: String) -> bool:
	var it := ShopScript.item_by_id(charm_id)
	if it.is_empty():
		return false
	var price := ShopScript.item_price(charm_id, charm_count(charm_id))
	if gold < price:
		return false
	gold -= price
	charms[charm_id] = charm_count(charm_id) + 1
	stats_changed.emit()
	return true


## --- Guild-hall helpers ------------------------------------------------
## Stages are bought strictly in order (only guild_stage + 1 is purchasable).
## Gold cost + lifetime depth milestones per GuildHall.can_purchase.
## Never wiped by death — guild progress is meta progression.

func guild_next_stage() -> int:
	return guild_stage + 1


func guild_stage_info() -> Dictionary:
	return GuildHallScript.stage(guild_stage)


func guild_next_info() -> Dictionary:
	return GuildHallScript.stage(guild_next_stage())


## Buy the next guild-hall stage. Returns true on success.
func buy_guild_stage() -> bool:
	var next := guild_next_stage()
	var check := GuildHallScript.can_purchase(next, gold, max_depth, guild_stage)
	if not bool(check.get("ok", false)):
		return false
	gold -= GuildHallScript.stage_price(next)
	guild_stage = next
	var s := GuildHallScript.stage(next)
	add_log("The guild hall grows: %s!" % str(s.get("name", "")))
	stats_changed.emit()
	return true


## --- Persistent effect multipliers (canon per-level scaling) ------------
func dmg_dealt_mult() -> float:
	return pow(1.02, skill_level("attack")) * pow(1.02, skill_level("strength")) \
		* pow(1.025, charm_count("hunter_mark"))


func dmg_taken_mult() -> float:
	return 1.0 / pow(1.02, skill_level("defense"))


func dodge_chance() -> float:
	return minf(0.005 * skill_level("agility"), 0.60)


func vitality_mult() -> float:
	return pow(1.02, skill_level("vitality"))


func gold_mult() -> float:
	return pow(1.03, skill_level("luck")) * pow(1.05, charm_count("lucky_coin")) \
		* Prestige.gold_mult_bonus() * LifeTree.gold_mult_bonus()


func xp_mult() -> float:
	return pow(1.04, charm_count("quill"))


func potion_mult() -> float:
	return pow(1.05, charm_count("flask"))


func regen_rate() -> float:
	return 0.1 * skill_level("regeneration") + 0.4 * charm_count("troll_salve") \
		+ LifeTree.regen_bonus()


func delve_speed_mult() -> float:
	return pow(1.02, skill_level("dungeoneering"))


## Depth walk speed: the crawler strides faster the deeper they delve, so
## bigger deep maps don't feel like a slog. Gentle ramp, hard cap.
## (Tamed 1x→3x down to 1x→2x: at depth 10+ the old pace outran the eye.)
func depth_walk_mult() -> float:
	return minf(1.0 + 0.04 * float(maxi(depth - 1, 0)), 2.0)


## Player-facing delve pace (Settings → Delve pace). Presentation speed
## ONLY: it scales the brain tick and stride/yaw visuals, never damage,
## drops, prices, or any per-action outcome. A speed knob, not a lever.
func delve_pace_mult() -> float:
	return Settings.pace_mult()


func aggro_mult() -> float:
	return maxf(pow(0.995, skill_level("stealth")), 0.40)


func sight_mult() -> float:
	return pow(1.02, skill_level("perception"))


func rarity_luck() -> float:
	# Bonus chance (0-1-ish) for loot to shift one rarity tier up.
	return 0.01 * skill_level("luck") + 0.005 * skill_level("enchanting") \
		+ LifeTree.rarity_bonus()


## Material yield (v0.11.0): Well Stocked multiplies material gains.
## No consumer yet — gathering zones arrive in a later push.
func material_yield_mult() -> float:
	return LifeTree.material_yield_mult()


## Enemy stat multiplier: grows with depth, plus a small bump per run so
## repeated runs stay spicy (roguelike difficulty ramp). The per-death hunger
## ramp caps at +50% — death costs the run, never future power.
func enemy_mult() -> float:
	return pow(float(depth), 1.2) * hunger_mult()


## Per-death monster hunger ramp: +2%/run normally, +5%/run in Hardcore
## (opt-in via the very-hidden settings easter egg). The +50% cap never
## moves — the ramp punishes streaks, not the player's future.
func hunger_step() -> float:
	return 0.05 if Settings.hardcore else 0.02


func hunger_mult() -> float:
	return minf(1.0 + hunger_step() * float(maxi(run_number - 1, 0)), 1.5)


func reset_run() -> void:
	depth = 1
	alive = true
	idle_mode = true  # every run starts auto-delving; player opts out
	run_kills = 0
	run_gold = 0.0
	level = 1
	xp = 0.0
	xp_next = 20.0
	max_hp = 50.0
	hp = max_hp
	atk = 6.0 + 3.0 * charm_count("whetstone") + LifeTree.atk_bonus()
	def = 1.0 + 2.0 * charm_count("iron_plate")
	# Fresh run, fresh gear — except heirlooms chosen on the game-over
	# screen, which carry into the new run (softens permadeath).
	equipment = {"weapon": {}, "armor": {}, "trinket": {}}
	if not heirloom_weapon.is_empty():
		equipment["weapon"] = heirloom_weapon
		max_hp += float(heirloom_weapon.get("max_hp", 0.0))
	if not heirloom_armor.is_empty():
		equipment["armor"] = heirloom_armor
		max_hp += float(heirloom_armor.get("max_hp", 0.0))
	# Persistent death-shop bonuses: Vitality scales everything, Blood Vials
	# add flat HP. Bought on the death screen, active from the next delve.
	# Founder gifts (Life Tree) add flat HP the same way — the soul keeps
	# them across runs, so reset_run recomputes them from base every time.
	max_hp = max_hp * vitality_mult() + 15.0 * charm_count("blood_vial") \
		+ LifeTree.max_hp_bonus()
	hp = max_hp
	health_potions = 0
	mana_potions = 0
	chests_opened = 0
	loot_collected = 0
	gear_equipped = 0
	potions_drunk = 0
	run_gear = []
	depth_changed.emit(depth)
	stats_changed.emit()


func next_depth() -> void:
	var cleared := depth
	depth += 1
	max_depth = maxi(max_depth, depth)
	# Small breather between floors: recover some HP.
	hp = minf(max_hp, hp + max_hp * 0.30)
	# Prestige hook: token on a 10->11 descend, cycle depth record.
	Prestige.notify_descend(cleared, depth)
	depth_changed.emit(depth)
	stats_changed.emit()
	add_log("You descend to depth %d…" % depth)


func gain_xp(amount: float) -> void:
	xp += amount
	while xp >= xp_next:
		xp -= xp_next
		level += 1
		xp_next = 20.0 * pow(float(level), 1.6)
		max_hp += 10.0 * vitality_mult()
		atk += 2.0
		def += 1.0
		hp = max_hp
		add_log("Level up! You are now level %d. HP restored." % level)
	stats_changed.emit()


func add_gold(amount: float, track: bool = true) -> void:
	gold += amount
	run_gold += amount
	# Tracked by default: awarded gold feeds the offline-earnings medians.
	# Offline credit itself passes track=false so it can never inflate its
	# own measurement window.
	if track:
		offline.record_gold(amount, OfflineEarnings.now_sec())
	stats_changed.emit()


func add_kill() -> void:
	kills += 1
	run_kills += 1
	offline.record_kill(OfflineEarnings.now_sec())
	stats_changed.emit()


## Medians for the save snapshot (safe defaults when no live data yet).
func offline_snapshot() -> Dictionary:
	return offline.snapshot(OfflineEarnings.now_sec())


## Returns true if this damage killed the player.
## This is the single point where enemy damage is applied to the player —
## the only caller in game code is main.gd's enemy-strike path.
func damage_player(amount: float) -> bool:
	if not alive:
		return false
	# DEV god mode (very-hidden dev corner): enemy hits never reduce HP.
	# Hunger ramp, economy, and XP flow through other paths and are
	# untouched — only this HP loss is nullified.
	if Settings.dev_god_mode:
		return false
	# Agility: dodge the hit outright.
	if randf() < dodge_chance():
		add_log("Dodged!")
		return false
	# Defense skill: multiplicative damage reduction.
	var taken: float = maxf(0.0, amount * dmg_taken_mult())
	hp = maxf(0.0, hp - taken)
	stats_changed.emit()
	if hp <= 0.0:
		alive = false
		player_died.emit()
		return true
	return false


func add_log(text: String) -> void:
	log_message.emit(text)


## --- Save/load -----------------------------------------------------------
## to_dict/from_dict cover every field the save system persists: both the
## run state and the cross-run meta progression (skills, charms, gold,
## heirlooms, guild hall, lifetime max depth). The floor itself is saved
## separately by main.gd.

func to_dict() -> Dictionary:
	return {
		"run_number": run_number, "depth": depth, "alive": alive,
		"mode": mode,
		"idle_mode": idle_mode, "kills": kills, "gold": gold,
		"run_kills": run_kills, "run_gold": run_gold,
		"level": level, "xp": xp, "xp_next": xp_next,
		"max_hp": max_hp, "hp": hp, "atk": atk, "def": def,
		"equipment": equipment.duplicate(true),
		"health_potions": health_potions, "mana_potions": mana_potions,
		"skills": skills.duplicate(), "charms": charms.duplicate(),
		"heirloom_weapon": heirloom_weapon.duplicate(true),
		"heirloom_armor": heirloom_armor.duplicate(true),
		"run_gear": run_gear.duplicate(true),
		"guild_stage": guild_stage,
		"max_depth": max_depth,
		"chests_opened": chests_opened, "loot_collected": loot_collected,
		"gear_equipped": gear_equipped, "potions_drunk": potions_drunk,
		"tutorial_done": tutorial_done,
	}


func from_dict(d: Dictionary) -> void:
	run_number = int(d.get("run_number", 1))
	depth = int(d.get("depth", 1))
	alive = bool(d.get("alive", true))
	# Phase 3: hub state round-trips through saves. Clamp garbage to the
	# dungeon default; the boot path routes to the restored mode.
	mode = int(d.get("mode", GameMode.State.DUNGEON))
	if not GameMode.is_valid(mode):
		mode = GameMode.State.DUNGEON
	idle_mode = bool(d.get("idle_mode", true))
	kills = int(d.get("kills", 0))
	gold = float(d.get("gold", 0.0))
	run_kills = int(d.get("run_kills", 0))
	run_gold = float(d.get("run_gold", 0.0))
	level = int(d.get("level", 1))
	xp = float(d.get("xp", 0.0))
	xp_next = float(d.get("xp_next", 20.0))
	max_hp = float(d.get("max_hp", 50.0))
	hp = float(d.get("hp", 50.0))
	atk = float(d.get("atk", 6.0))
	def = float(d.get("def", 1.0))
	equipment = (d.get("equipment", {}) as Dictionary).duplicate(true)
	if equipment.is_empty():
		equipment = {"weapon": {}, "armor": {}, "trinket": {}}
	health_potions = int(d.get("health_potions", 0))
	mana_potions = int(d.get("mana_potions", 0))
	skills = (d.get("skills", {}) as Dictionary).duplicate()
	charms = (d.get("charms", {}) as Dictionary).duplicate()
	heirloom_weapon = (d.get("heirloom_weapon", {}) as Dictionary).duplicate(true)
	heirloom_armor = (d.get("heirloom_armor", {}) as Dictionary).duplicate(true)
	run_gear = (d.get("run_gear", []) as Array).duplicate(true)
	guild_stage = clampi(int(d.get("guild_stage", 0)), 0, GuildHallScript.STAGE_COUNT)
	max_depth = maxi(maxi(int(d.get("max_depth", 1)), 1), depth)
	chests_opened = int(d.get("chests_opened", 0))
	loot_collected = int(d.get("loot_collected", 0))
	gear_equipped = int(d.get("gear_equipped", 0))
	potions_drunk = int(d.get("potions_drunk", 0))
	tutorial_done = bool(d.get("tutorial_done", false))
	depth_changed.emit(depth)
	stats_changed.emit()
