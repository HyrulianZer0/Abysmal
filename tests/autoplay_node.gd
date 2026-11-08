extends Node
## Headless autoplay beta: run main scene with idle mode ON for ~3 virtual
## minutes (time_scale 4x). Verifies loot/chests/equip/potions, the minimap
## fog, and the idle-brain priority order (monsters -> loot -> stairs LAST).
var _frames := 0
var _max_frames := 10800  # 180 virtual seconds
var _last_depth := -1
var _deaths := 0
var _last_hp := -1.0
var _kills_seen := false
var _equip_seen := false
var _chest_seen := false
var _potion_seen := false
var _order_violations := 0
var _main: Node = null
var _facings := {}
var _facing_reported := false
var _last_target := ""
var _was_alive := true
var _heirloom_cycles := 0
var _gear_names := {}
const IT := preload("res://scripts/items.gd")


func _ready() -> void:
	Engine.time_scale = 4.0
	var packed: PackedScene = load("res://scenes/main.tscn")
	var main = packed.instantiate()
	_main = main
	get_tree().root.add_child.call_deferred(main)
	print("AUTOPLAY: scene started, idle_mode=", GameState.idle_mode, " time_scale=4")


func _process(_delta: float) -> void:
	_frames += 1
	var gs = GameState
	# Floor-clear shop pauses the delve by design; the soak taps through it
	# via the real HUD close path.
	if _main != null and bool(_main.get("_shop_open")):
		(_main.get("hud") as Node).hide_shop()
	if gs.depth != _last_depth:
		print("AUTOPLAY frame ", _frames, ": depth=", gs.depth, " level=", gs.level,
			" hp=", snapped(gs.hp, 1.0), "/", snapped(gs.max_hp, 1.0),
			" kills=", gs.kills, " loot=", gs.loot_collected,
			" chests=", gs.chests_opened, " equipped=", gs.gear_equipped,
			" potions_drunk=", gs.potions_drunk)
		_last_depth = gs.depth
	if gs.hp <= 0.0 and _last_hp > 0.0:
		_deaths += 1
		print("AUTOPLAY frame ", _frames, ": DEATH #", _deaths, " at depth ", gs.depth, " level ", gs.level)
	_last_hp = gs.hp
	# Death-sort cycle: the death screen lists this run's gear; pick the
	# best weapon + armor, "Delve Again", and verify the picks carried
	# into the next run as heirlooms.
	if not gs.alive and _was_alive:
		_was_alive = false
		_handle_death_sort()
	elif gs.alive and not _was_alive:
		_was_alive = true
	# Track loot variety across the whole beta.
	for item in gs.run_gear:
		_gear_names[str(item["name"])] = true
	if gs.kills > 0 and not _kills_seen:
		_kills_seen = true
		print("AUTOPLAY frame ", _frames, ": first kill confirmed")
	if gs.gear_equipped > 0 and not _equip_seen:
		_equip_seen = true
		var w: Dictionary = gs.equipment.get("weapon", {})
		var a: Dictionary = gs.equipment.get("armor", {})
		print("AUTOPLAY frame ", _frames, ": gear equipped — weapon=", w.get("name", "—"),
			" armor=", a.get("name", "—"))
	if gs.chests_opened > 0 and not _chest_seen:
		_chest_seen = true
		print("AUTOPLAY frame ", _frames, ": first chest opened")
	if gs.potions_drunk > 0 and not _potion_seen:
		_potion_seen = true
		print("AUTOPLAY frame ", _frames, ": auto-potion drank at low HP")

	if _main != null and is_instance_valid(_main):
		# Camera check: the player must actually turn while idle-delving.
		var players := _main.find_children("", "Player", true, false)
		if not players.is_empty():
			_facings[int(players[0].facing)] = true
			if _facings.size() > 1 and not _facing_reported:
				_facing_reported = true
				print("AUTOPLAY frame ", _frames, ": player turned — camera follows (facings=", _facings.keys(), ")")
		# Order check: when the brain picks stairs, nothing else may remain.
		var target := str(_main.get("debug_last_target"))
		if target == "stairs" and _last_target != "stairs":
			var remaining := _remaining_work()
			if remaining > 0:
				_order_violations += 1
				printerr("AUTOPLAY ORDER VIOLATION at frame ", _frames,
					": stairs targeted with ", remaining, " monsters/chests/loot left")
		_last_target = target

	if _frames >= _max_frames:
		var explored_count := 0
		if _main != null and is_instance_valid(_main):
			explored_count = (_main.get("explored") as Dictionary).size()
		print("AUTOPLAY: DONE frames=", _frames, " depth=", gs.depth, " level=", gs.level,
			" deaths=", _deaths, " kills=", gs.kills, " gold=", snapped(gs.gold, 0.0),
			" hp=", snapped(gs.hp, 1.0), " facings_seen=", _facings.keys())
		print("AUTOPLAY: loot_collected=", gs.loot_collected, " chests_opened=", gs.chests_opened,
			" gear_equipped=", gs.gear_equipped, " potions_drunk=", gs.potions_drunk,
			" hp_potions=", gs.health_potions, " mp_potions=", gs.mana_potions,
			" explored_cells=", explored_count, " order_violations=", _order_violations,
			" heirloom_cycles=", _heirloom_cycles, " gear_variety=", _gear_names.keys())
		Engine.time_scale = 1.0
		get_tree().quit()


## Simulate the player on the death screen: sort the run's haul, take the
## best weapon + armor as heirlooms, delve again, and verify the picks
## are equipped in the new run.
func _handle_death_sort() -> void:
	var gs = GameState
	var best_w := {}
	var best_a := {}
	for item in gs.run_gear:
		var slot := str(item.get("slot", ""))
		if slot == "weapon" and IT.better(item, best_w):
			best_w = item
		elif slot == "armor" and IT.better(item, best_a):
			best_a = item
	print("AUTOPLAY frame ", _frames, ": death-sort — run_gear=", gs.run_gear.size(),
		" picked weapon=", best_w.get("name", "—"), " armor=", best_a.get("name", "—"))
	var hud = _main.get("hud")
	hud.death_test_pick(best_w, best_a)
	hud.death_test_confirm()  # -> GameState.set_heirlooms + restart
	# request_restart runs synchronously: the new run must wear the picks.
	var eq_w: Dictionary = gs.equipment.get("weapon", {})
	var eq_a: Dictionary = gs.equipment.get("armor", {})
	var ok := true
	if not best_w.is_empty() and not _dict_eq(eq_w, best_w):
		ok = false
		printerr("AUTOPLAY frame ", _frames, ": HEIRLOOM FAIL — weapon not carried")
	if not best_a.is_empty() and not _dict_eq(eq_a, best_a):
		ok = false
		printerr("AUTOPLAY frame ", _frames, ": HEIRLOOM FAIL — armor not carried")
	if ok:
		_heirloom_cycles += 1
		print("AUTOPLAY frame ", _frames, ": heirloom check PASS — picks carried into run #", gs.run_number)


func _dict_eq(a: Dictionary, b: Dictionary) -> bool:
	if a.size() != b.size():
		return false
	for k in a:
		if not b.has(k) or str(a[k]) != str(b[k]):
			return false
	return true


## Count of unfinished business the brain can see: living monsters plus
## unopened chests / uncollected loot in explored cells.
func _remaining_work() -> int:
	var n := 0
	var enemies: Array = _main.get("enemies")
	for e in enemies:
		if is_instance_valid(e) and not e.dead:
			n += 1
	var explored: Dictionary = _main.get("explored")
	for c in _main.get("chests"):
		if not bool(c["opened"]) and explored.has(c["pos"]):
			n += 1
	for l in _main.get("loot"):
		if not bool(l["taken"]) and explored.has(l["pos"]):
			n += 1
	return n
