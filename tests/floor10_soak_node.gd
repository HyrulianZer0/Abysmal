extends Node
## Floor-10 balance soak (Oct 7, 2026 validation wave).
##
## James's target: a fresh run should reach floor 10 after a few tries, with
## stats still growing. Method: headless, 16x time scale, FRESH save (no meta),
## the real idle brain. On death, the real death flow: heirloom picks (best
## weapon + armor), death-screen shop purchases with the priority heuristic
## (skills: attack > vitality > luck, cheapest first; charms: whetstone >
## blood_vial > lucky_coin from the rolled offerings), then "Delve Again"
## through town (Phase 3: request_restart parks in town; the harness presses
## the Delve button via start_delve(), exactly like the town UI does).
##
## Per attempt it tracks: max depth, starting atk/max_hp/level, ending
## level, gold earned that run, shop spending, skill levels. Win = descend
## 10 -> 11 (also verifies the prestige token is awarded). Guild-hall
## stage-1 purchasability is spot-checked after each death.
##
## Run: godot --headless --path . tests/floor10_soak_scene.tscn
##      [-- --seed=12345 --max-attempts=5 --soak-scale=16]
## Exits 0 on clean completion (verdict printed); 1 on stall/violations.

const IT := preload("res://scripts/items.gd")
const ShopScript := preload("res://scripts/shop.gd")
const GuildHallScript := preload("res://scripts/guild_hall.gd")

var _frames := 0
var _virtual := 0.0
var _scale := 16.0
var _max_attempts := 5
var _seed := -1

var _main: Node = null
var _attempt := 1
var _attempt_max_depth := 1
var _attempt_start := {}       # atk, max_hp, level at attempt start
var _last_depth := 1
var _last_progress := 0.0
var _was_alive := true
var _deaths := 0
var _violations := 0
var _floor10_reached := false
var _prestige_token_ok := false
var _guild_stage1_ok := false
var _shop_closes := 0
var _rng := RandomNumberGenerator.new()
var _offer_rng := RandomNumberGenerator.new()
var _finished := false

# Priority order for death-shop skill buying (James's heuristic).
const SKILL_PRIORITY := ["attack", "vitality", "luck"]
# Priority order for charm buying from the rolled offerings.
const CHARM_PRIORITY := ["whetstone", "blood_vial", "lucky_coin"]


func _ready() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--seed="):
			var n := a.trim_prefix("--seed=")
			if n.is_valid_int():
				_seed = int(n)
		elif a.begins_with("--max-attempts="):
			var m := a.trim_prefix("--max-attempts=")
			if m.is_valid_int():
				_max_attempts = maxi(1, int(m))
		elif a.begins_with("--soak-scale="):
			var s := a.trim_prefix("--soak-scale=")
			if s.is_valid_float():
				_scale = float(s)
	Engine.time_scale = _scale
	# Fresh save: no meta, exactly like a new player.
	if FileAccess.file_exists("user://savegame.dat"):
		DirAccess.remove_absolute("user://savegame.dat")
	if _seed >= 0:
		seed(_seed)
		_rng.seed = _seed
		_offer_rng.seed = _seed + 7919
	else:
		_rng.randomize()
		_offer_rng.randomize()
	GameState.depth = 1
	var packed: PackedScene = load("res://scenes/main.tscn")
	_main = packed.instantiate()
	get_tree().root.add_child.call_deferred(_main)
	print("SOAK10: fresh save, target floor 10 within %d attempts, time_scale=%sx, seed=%s" % [
		_max_attempts, str(_scale), str(_seed) if _seed >= 0 else "random"])


func _process(delta: float) -> void:
	if _finished:
		return
	_frames += 1
	_virtual += delta
	var gs = GameState
	if _main == null or not is_instance_valid(_main):
		return

	# Floor-clear shop pauses the delve by design; tap through it like the
	# other endurance betas (the soak's shopping happens on the death screen).
	if bool(_main.get("_shop_open")):
		_shop_closes += 1
		(_main.get("hud") as Node).hide_shop()

	# Attempt start stats: capture once the first floor of the attempt is live.
	if _attempt_start.is_empty() and gs.alive and gs.mode == GameMode.State.DUNGEON:
		_attempt_start = {
			"atk": gs.atk, "max_hp": gs.max_hp, "level": gs.level,
			"gold": gs.gold, "skills": _skill_snapshot(),
		}
		print("SOAK10: attempt %d starts — atk=%.1f max_hp=%.0f level=%d gold=%.0f skills=%s" % [
			_attempt, gs.atk, gs.max_hp, gs.level, gs.gold, _fmt_skills()])

	if gs.depth != _last_depth:
		_on_depth_change(gs)

	if not gs.alive and _was_alive:
		_was_alive = false
		_deaths += 1
		_last_progress = _virtual
		_on_death(gs)
	elif gs.alive and not _was_alive:
		_was_alive = true

	# Stall watchdog: 10 virtual minutes with no depth change or death.
	# (Was 6 min — deep floors legitimately take longer than that to clear,
	# so the watchdog false-tripped on healthy runs. James's call, Oct 11.)
	if _virtual - _last_progress > 600.0:
		_violate("STALL: no progress for 10 virtual min at depth %d (attempt %d, mode=%s)" % [
			gs.depth, _attempt, str(gs.mode)])
		_dump_wall(gs)
		_finish()
		return


func _on_depth_change(gs) -> void:
	var from_depth := _last_depth
	_last_depth = gs.depth
	_last_progress = _virtual
	_attempt_max_depth = maxi(_attempt_max_depth, gs.depth)
	if gs.depth == 11 and from_depth == 10 and not _floor10_reached:
		_floor10_reached = true
		# Prestige spot-check: the 10->11 descend must award a token.
		if Prestige.tokens >= 1:
			_prestige_token_ok = true
			print("SOAK10: FLOOR 10 CLEARED — prestige token awarded (tokens=%d). TARGET MET on attempt %d." % [
				Prestige.tokens, _attempt])
		else:
			_violate("10->11 descend did NOT award a prestige token (tokens=%d)" % Prestige.tokens)
		_finish()
		return
	print("SOAK10 t=%.0fs: attempt %d reached depth %d (atk=%.1f hp=%.0f/%.0f lvl=%d gold=%.0f)" % [
		_virtual, _attempt, gs.depth, gs.atk, gs.hp, gs.max_hp, gs.level, gs.gold])


func _on_death(gs) -> void:
	var run_gold: float = gs.run_gold
	var end_level: int = gs.level
	print("SOAK10 t=%.0fs: DEATH #%d — attempt %d ended at depth %d (max %d), lvl 1->%d, run gold=%.0f, lifetime gold=%.0f" % [
		_virtual, _deaths, _attempt, gs.depth, _attempt_max_depth, end_level, run_gold, gs.gold])
	_dump_wall(gs)
	# Heirloom picks: best weapon + armor by power (real death-screen flow).
	var best_w := {}
	var best_a := {}
	for item in gs.run_gear:
		var slot := str(item.get("slot", ""))
		if slot == "weapon" and IT.better(item, best_w):
			best_w = item
		elif slot == "armor" and IT.better(item, best_a):
			best_a = item
	# Death-screen shop: the priority heuristic (attack/vitality/luck skills,
	# then whetstone/blood_vial/lucky_coin charms from the rolled offerings).
	_death_shop(gs)
	# Guild-hall spot-check: try to buy the next stage with earned gold.
	_try_guild(gs)
	# Confirm "Delve Again" (real death flow), then press the town's Delve
	# button to start the next attempt — Phase 3 parks dead runs in town.
	var hud = _main.get("hud")
	hud.death_test_pick(best_w, best_a)
	hud.death_test_confirm()
	print("SOAK10: attempt %d summary — max_depth=%d start_atk=%.1f start_hp=%.0f start_lvl=%d -> end_lvl=%d run_gold=%.0f shop_spent=%.0f skills=%s" % [
		_attempt, _attempt_max_depth, float(_attempt_start.get("atk", 0.0)),
		float(_attempt_start.get("max_hp", 0.0)), int(_attempt_start.get("level", 1)),
		end_level, run_gold, _shop_spent, _fmt_skills()])
	_attempt += 1
	_attempt_max_depth = 1
	_attempt_start = {}
	_shop_spent = 0.0
	if _attempt > _max_attempts:
		print("SOAK10: attempt budget (%d) exhausted without reaching floor 10." % _max_attempts)
		_finish()
		return
	var ok: bool = _main.start_delve()
	if not ok:
		_violate("start_delve() refused after death #%d" % _deaths)
		_finish()
		return
	_last_depth = 1
	_last_progress = _virtual
	print("SOAK10: --- attempt %d begins (delve from town) ---" % _attempt)


var _shop_spent := 0.0


## Death-screen shop with James's priority heuristic: skills attack >
## vitality > luck (cheapest affordable first, repeat), then charms
## whetstone > blood_vial > lucky_coin from the rolled offerings.
func _death_shop(gs) -> void:
	# Roll the same 4 offerings the death screen shows (Luck adds more).
	var offerings: Array = ShopScript.roll_offerings(_offer_rng, gs.skill_level("luck"))
	# Skills first: round-robin over the priority list, cheapest affordable.
	var bought := true
	var guard := 0
	while bought and guard < 200:
		bought = false
		guard += 1
		var best := ""
		var best_price := 1.0e30
		for sid in SKILL_PRIORITY:
			var price: float = ShopScript.skill_price(sid, gs.skill_level(sid))
			if price <= gs.gold and price < best_price:
				best_price = price
				best = sid
		if best != "" and gs.buy_skill(best):
			_shop_spent += best_price
			bought = true
	# Charms: priority order, only from this death's offerings.
	for cid in CHARM_PRIORITY:
		var offered := false
		for o in offerings:
			if str(o["id"]) == cid:
				offered = true
				break
		if not offered:
			continue
		var price: float = ShopScript.item_price(cid, gs.charm_count(cid))
		if price <= gs.gold and gs.buy_charm(cid):
			_shop_spent += price
			print("SOAK10: bought charm %s for %.0f G" % [cid, price])


func _try_guild(gs) -> void:
	var next: int = gs.guild_next_stage()
	var info: Dictionary = GuildHallScript.can_purchase(next, gs.gold, gs.max_depth, gs.guild_stage)
	if bool(info.get("ok", false)):
		if gs.buy_guild_stage():
			print("SOAK10: GUILD — bought stage %d (%s). guild_stage=%d" % [
				next, str(GuildHallScript.stage(next).get("name", "")), gs.guild_stage])
			if next == 1:
				_guild_stage1_ok = true
	else:
		print("SOAK10: guild stage %d not purchasable yet: %s (gold=%.0f)" % [
			next, str(info.get("reason", "?")), gs.gold])


## Wall diagnostic: enemy stats on the killing floor vs player stats.
func _dump_wall(gs) -> void:
	var m = _main
	if m == null or not is_instance_valid(m):
		return
	var n := 0
	var atk_sum := 0.0
	var hp_sum := 0.0
	var names := {}
	for e in m.get("enemies"):
		if is_instance_valid(e) and not e.dead:
			n += 1
			atk_sum += float(e.get("atk"))
			hp_sum += float(e.get("max_hp"))
			names[str(e.get("display_name"))] = true
	if n > 0:
		print("SOAK10: WALL — depth %d: %d foes (%s) avg atk=%.1f avg hp=%.0f vs player atk=%.1f max_hp=%.0f def=%.1f lvl=%d" % [
			gs.depth, n, ", ".join(names.keys()), atk_sum / n, hp_sum / n,
			gs.atk, gs.max_hp, gs.def, gs.level])
	else:
		print("SOAK10: WALL — depth %d: no live foes; player atk=%.1f max_hp=%.0f def=%.1f lvl=%d hp=%.0f" % [
			gs.depth, gs.atk, gs.max_hp, gs.def, gs.level, gs.hp])


func _skill_snapshot() -> Dictionary:
	return {
		"attack": GameState.skill_level("attack"),
		"vitality": GameState.skill_level("vitality"),
		"luck": GameState.skill_level("luck"),
	}


func _fmt_skills() -> String:
	var s := _skill_snapshot()
	return "atk=%d vit=%d luck=%d" % [int(s["attack"]), int(s["vitality"]), int(s["luck"])]


func _violate(msg: String) -> void:
	_violations += 1
	printerr("SOAK10 VIOLATION: " + msg)


func _finish() -> void:
	if _finished:
		return
	_finished = true
	Engine.time_scale = 1.0
	var gs = GameState
	print("SOAK10: DONE virtual=%.0fs frames=%d" % [_virtual, _frames])
	print("SOAK10: RESULT floor10_reached=%s attempts_used=%d deaths=%d prestige_token=%s guild_stage1=%s violations=%d" % [
		str(_floor10_reached), mini(_attempt, _max_attempts), _deaths,
		str(_prestige_token_ok), str(_guild_stage1_ok), _violations])
	print("SOAK10: final stats atk=%.1f max_hp=%.0f def=%.1f level=%d gold=%.0f skills=%s charms=%s" % [
		gs.atk, gs.max_hp, gs.def, gs.level, gs.gold, _fmt_skills(), str(gs.charms)])
	if _floor10_reached and _violations == 0:
		print("SOAK10: PASS — floor 10 fell within %d attempt(s); no script errors." % _attempt)
	elif _violations == 0:
		print("SOAK10: TARGET NOT MET — floor 10 not reached in %d attempts." % _max_attempts)
	else:
		printerr("SOAK10: %d VIOLATIONS" % _violations)
	get_tree().quit(0 if _violations == 0 else 1)
