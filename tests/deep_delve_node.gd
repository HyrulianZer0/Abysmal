extends Node
## Deep-delve endurance beta: "keep the dungeon warm." Idle at 8x for ~30
## virtual minutes with the natural 12% monster-floor chance. Hunts for
## inconsistencies every frame (stat bounds, NaN, soft-locks) and verifies
## the crawler keeps descending, deeper and deeper, run after run.
##
## Run: godot --headless --path . tests/deep_delve_scene.tscn
## Exits 0 on pass; prints FAIL lines and exits 1 on any inconsistency.

const IT := preload("res://scripts/items.gd")

var _frames := 0
var _virtual := 0.0
var _max_virtual := 1800.0  # 30 virtual minutes
var _main: Node = null
var _last_depth := 1
var _max_depth := 1
var _last_progress := 0.0
var _last_kills := 0
var _last_trace := 0.0
var _was_alive := true
var _deaths := 0
var _horde_floors := 0
var _min_hp_frac := 1.0
var _violations := 0
var _violation_log := 0
var _gear_names := {}
var _shop_closes := 0  # test-only: floor-shop auto-closes (the shop pauses
                       # the delve by design; the soak taps "Keep Delving")
## Overnight mode: actually USE the shop — buy skills (lockpicking first so
## picks get exercised) and charms, then keep delving. Enabled with --shop.
var _use_shop := false
var _shops_shopped := 0
var _gold_spent := 0.0


func _ready() -> void:
	# Long-soak overrides: -- --soak-virtual=7200 --soak-scale=2
	# (James's 1-hour x2 vigilance run).
	var scale := 8.0
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--soak-virtual="):
			var n := a.trim_prefix("--soak-virtual=")
			if n.is_valid_float():
				_max_virtual = float(n)
		if a.begins_with("--soak-scale="):
			var n2 := a.trim_prefix("--soak-scale=")
			if n2.is_valid_float():
				scale = float(n2)
		if a == "--shop":
			_use_shop = true
	Engine.time_scale = scale
	# Fresh boot: a stale town/hub save would load instead of the dungeon.
	if FileAccess.file_exists("user://savegame.dat"):
		DirAccess.remove_absolute("user://savegame.dat")
	var packed: PackedScene = load("res://scenes/main.tscn")
	_main = packed.instantiate()
	get_tree().root.add_child.call_deferred(_main)
	print("DEEPDELVE: %d virtual s, natural horde chance, time_scale=%s" % [int(_max_virtual), str(scale)])


func _process(delta: float) -> void:
	_frames += 1
	_virtual += delta
	var gs = GameState

	# Floor-clear shop pauses the delve by design; the soak taps through it
	# via the real HUD close path (emits shop_closed -> delve resumes).
	# Overnight mode (--shop) spends gold first: skills, then charms.
	if _main != null and bool(_main.get("_shop_open")):
		_shop_closes += 1
		if _use_shop:
			_auto_shop()
		(_main.get("hud") as Node).hide_shop()

	if gs.depth != _last_depth:
		_last_depth = gs.depth
		_last_progress = _virtual
		_max_depth = maxi(_max_depth, gs.depth)
		var gen: Dictionary = _main.get("gen")
		var horde := bool(gen.get("monster_floor", false))
		if horde:
			_horde_floors += 1
		print("DEEPDELVE t=%.0fs: depth=%d%s level=%d hp=%s/%s kills=%d gold=%s" % [
			_virtual, gs.depth, " [MONSTER FLOOR]" if horde else "",
			gs.level, _fmt(gs.hp), _fmt(gs.max_hp), gs.kills, _fmt(gs.gold)])

	if not gs.alive and _was_alive:
		_was_alive = false
		_deaths += 1
		_last_progress = _virtual
		print("DEEPDELVE t=%.0fs: DEATH #%d at depth %d" % [_virtual, _deaths, gs.depth])
		_handle_death_sort()
	elif gs.alive and not _was_alive:
		_was_alive = true
	elif gs.alive:
		_min_hp_frac = minf(_min_hp_frac, gs.hp / maxf(gs.max_hp, 1.0))

	# A kill is progress too: the watchdog's job is catching soft-locks,
	# and a crawler that keeps killing is not stuck. (Depth-12 stall,
	# Nov 8: 74 kills inside the window, zero depth/death — flagged
	# anyway, because only depth and death reset the timer.)
	if gs.kills != _last_kills:
		_last_kills = gs.kills
		_last_progress = _virtual

	_check_consistency(gs)

	for item in gs.run_gear:
		_gear_names[str(item["name"])] = true

	# Pre-stall trace: a minute without progress starts a 30s-interval
	# brain-state log, so the stall's mechanism shows before the watchdog.
	if _virtual - _last_progress > 60.0 and _virtual - _last_trace >= 30.0:
		_last_trace = _virtual
		_trace_brain(gs)

	# Soft-lock: no depth change and no death for 6 virtual minutes.
	if _virtual - _last_progress > 360.0:
		_violate("STALL: no progress for 6 virtual min at depth %d" % gs.depth)
		_dump_stall(gs)
		_finish()
		return

	if _virtual >= _max_virtual:
		_finish()


## Per-frame invariant scan. Anything off is an inconsistency worth a FAIL.
func _check_consistency(gs) -> void:
	var bad := ""
	if gs.hp != gs.hp or gs.max_hp != gs.max_hp or gs.gold != gs.gold:
		bad = "NaN stat"
	elif gs.hp < 0.0 or gs.hp > gs.max_hp + 0.01:
		bad = "hp out of bounds (%.1f/%.1f)" % [gs.hp, gs.max_hp]
	elif gs.gold < 0.0 or gs.run_gold < 0.0:
		bad = "negative gold"
	elif gs.level < 1 or gs.depth < 1:
		bad = "level/depth < 1"
	elif gs.xp < 0.0:
		bad = "negative xp"
	elif gs.health_potions < 0 or gs.mana_potions < 0:
		bad = "negative potions"
	elif gs.kills < 0 or gs.run_kills < 0:
		bad = "negative kills"
	if bad != "":
		_violate("INCONSISTENCY t=%.0fs depth=%d: %s" % [_virtual, gs.depth, bad])
	# Player must never stand inside a wall.
	if _main != null and is_instance_valid(_main) and gs.alive:
		var players := _main.find_children("", "Player", true, false)
		if not players.is_empty():
			var gp: Vector2i = players[0].grid_pos
			if int(_main.cell_at(gp)) == 0:
				_violate("INCONSISTENCY t=%.0fs: player inside WALL at %s" % [_virtual, str(gp)])


func _violate(msg: String) -> void:
	_violations += 1
	if _violation_log < 10:
		_violation_log += 1
		printerr("DEEPDELVE " + msg)


func _fmt(v: float) -> String:
	if v >= 1000.0:
		return "%d" % int(v)
	return "%.0f" % v


## Same death-sort flow as the autoplay beta: keep the best weapon + armor
## as heirlooms and delve again, verifying the picks carried over.
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
	var hud = _main.get("hud")
	hud.death_test_pick(best_w, best_a)
	hud.death_test_confirm()
	# Phase 3: the dead run ends in town — delve again so the soak continues.
	_main.start_delve()
	var eq_w: Dictionary = gs.equipment.get("weapon", {})
	var eq_a: Dictionary = gs.equipment.get("armor", {})
	if not best_w.is_empty() and not _dict_eq(eq_w, best_w):
		_violate("heirloom weapon not carried into next run")
	if not best_a.is_empty() and not _dict_eq(eq_a, best_a):
		_violate("heirloom armor not carried into next run")


func _dict_eq(a: Dictionary, b: Dictionary) -> bool:
	if a.size() != b.size():
		return false
	for k in a:
		if not b.has(k) or str(a[k]) != str(b[k]):
			return false
	return true


## Pre-stall trace: brain state while progress is stalled, so the mechanism
## is visible before the watchdog fires (oscillation vs frozen vs loop).
func _trace_brain(gs) -> void:
	var m = _main
	var pl = m.get("player") as Node
	var unseen := 0
	if m.has_method("_unseen_cells"):
		unseen = int((m.call("_unseen_cells") as Array).size())
	print("STALLTRACE t=%.0fs depth=%d pos=%s last=%s busy=%s room=%d unseen=%d root=%.1f traps=%d" % [
		_virtual, gs.depth, str(pl.grid_pos), str(m.get("debug_last_target")),
		str(bool(pl.get("busy"))), int(m.get("_brain_room")), unseen,
		float(m.get("_player_root_timer")), int((m.get("_floor_traps") as Array).size())])


## Stall diagnostic: what was the brain doing? (Only runs on a stall.)
func _dump_stall(gs) -> void:
	var m = _main
	var pl = m.get("player") as Node
	var ppos: Vector2i = pl.grid_pos
	var stw = pl.get("_step_tween")
	var stw_valid := false
	var stw_running := false
	if stw != null:
		stw_valid = (stw as Tween).is_valid()
		stw_running = (stw as Tween).is_running()
	print("STALLDUMP player=", ppos, " last_target=", m.get("debug_last_target"),
		" busy=", pl.busy, " shop_open=", m.get("_shop_open"),
		" alive=", gs.alive, " idle=", gs.idle_mode, " main_processing=", m.is_processing(),
		" tween_valid=", stw_valid, " tween_running=", stw_running)
	var stairs: Vector2i = (m.get("gen") as Dictionary)["stairs"]
	print("STALLDUMP stairs=", stairs, " stairs_room=", m.get("_stairs_room"),
		" room_hostiles=", m._hostiles_in_room(int(m.get("_stairs_room"))))
	var alive := 0
	var asleep := 0
	for e in (m.get("enemies") as Array):
		if is_instance_valid(e) and not e.dead:
			alive += 1
			if bool(e.asleep):
				asleep += 1
	print("STALLDUMP enemies alive=", alive, " asleep=", asleep)
	for e in (m.get("enemies") as Array):
		if is_instance_valid(e) and not e.dead:
			print("STALLDUMP foe pos=", e.grid_pos, " asleep=", bool(e.asleep))
	for cc in (m.get("chests") as Array):
		if not bool(cc["opened"]):
			print("STALLDUMP chest pos=", cc["pos"], " sealed=", bool(cc.get("sealed", false)))
	var states := {}
	for d in (m.get("doors") as Array):
		var s := str(d["state"])
		states[s] = int(states.get(s, 0)) + 1
		print("STALLDUMP door pos=", d["pos"], " state=", s)
	print("STALLDUMP door states=", states)
	_dump_stall_map(m)


## ASCII map of the stalled floor: #=wall .=floor S=stairs P=player
## E=foe D=closed/locked door d=open door C=sealed chest c=opened chest.
func _dump_stall_map(m: Node) -> void:
	var gen: Dictionary = m.get("gen")
	var w: int = int(gen["width"])
	var h: int = int(gen["height"])
	var grid: Array = gen["grid"]
	var marks := {}
	var ppos: Vector2i = (m.get("player") as Node).grid_pos
	marks[ppos] = "P"
	marks[(gen["stairs"] as Vector2i)] = "S"
	for e in (m.get("enemies") as Array):
		if is_instance_valid(e) and not e.dead:
			marks[(e as Node).get("grid_pos")] = "E"
	for d in (m.get("doors") as Array):
		marks[(d as Dictionary)["pos"]] = "D" if str((d as Dictionary)["state"]) != "open" else "d"
	for cc in (m.get("chests") as Array):
		var ccd := cc as Dictionary
		if not bool(ccd["opened"]):
			marks[ccd["pos"]] = "C" if bool(ccd.get("sealed", false)) else "c"
	print("STALLMAP %dx%d:" % [w, h])
	for y in h:
		var row := ""
		for x in w:
			var p := Vector2i(x, y)
			if marks.has(p):
				row += str(marks[p])
			elif int((grid[y] as Array)[x]) == 0:
				row += "#"
			else:
				row += "."
		print("STALLMAP " + row)


## Overnight shopper: spend the floor-clear shop's gold like a player would.
## Lockpicking to 3 first (so door/chest picks actually get exercised),
## then cheapest-available skill round-robin, then charms. Guarded loop.
func _auto_shop() -> void:
	var gs = GameState
	var ShopScript = load("res://scripts/shop.gd")
	_shops_shopped += 1
	var guard := 0
	var bought := true
	while bought and guard < 300:
		bought = false
		guard += 1
		if gs.skill_level("lockpicking") < 3:
			var lp_price: float = ShopScript.skill_price("lockpicking",
				gs.skill_level("lockpicking"))
			if lp_price <= gs.gold and gs.buy_skill("lockpicking"):
				_gold_spent += lp_price
				bought = true
				continue
		var best := ""
		var best_price := 1.0e30
		for s in ShopScript.SKILLS:
			if not bool(s.get("available", true)):
				continue
			var sid := str(s["id"])
			var price: float = ShopScript.skill_price(sid, gs.skill_level(sid))
			if price <= gs.gold and price < best_price:
				best_price = price
				best = sid
		if best != "" and gs.buy_skill(best):
			_gold_spent += best_price
			bought = true
			continue
		var best_it := ""
		var best_iprice := 1.0e30
		for it in ShopScript.ITEMS:
			var iid := str(it["id"])
			var iprice: float = ShopScript.item_price(iid, gs.charm_count(iid))
			if iprice <= gs.gold and iprice < best_iprice:
				best_iprice = iprice
				best_it = iid
		if best_it != "" and gs.buy_charm(best_it):
			_gold_spent += best_iprice
			bought = true


func _finish() -> void:
	Engine.time_scale = 1.0
	print("DEEPDELVE: DONE virtual=%.0fs frames=%d" % [_virtual, _frames])
	var _pl = _main.get("player") if _main != null else null
	var _backstops := 0
	if _pl != null:
		_backstops = int(_pl.get("debug_stride_backstops"))
	print("DEEPDELVE: max_depth=%d deaths=%d horde_floors=%d kills=%d level=%d gold=%s min_hp_frac=%.2f gear_variety=%d shop_closes=%d stride_backstops=%d" % [
		_max_depth, _deaths, _horde_floors, GameState.kills, GameState.level,
		_fmt(GameState.gold), _min_hp_frac, _gear_names.size(), _shop_closes, _backstops])
	if _main != null:
		print("DEEPDELVE: doors pushed=%d picked=%d bashed=%d | seals_broken=%d chests_opened=%d | sleepers_woken=%d patrol_spawns=%d" % [
			int(_main.get("debug_doors_pushed")), int(_main.get("debug_doors_picked")),
			int(_main.get("debug_doors_bashed")), int(_main.get("debug_seals_broken")),
			int(_main.get("debug_chests_opened")), int(_main.get("debug_sleepers_woken")),
			int(_main.get("debug_patrol_spawns"))])
		print("DEEPDELVE: room-sweep — shop_heals=%d retreat_descends=%d unfinished_left_at_descend=%d (foes=%d chests=%d locked=%d loot=%d)" % [
			int(_main.get("debug_shop_heals")), int(_main.get("debug_retreat_descends")),
			int(_main.get("debug_unfinished_at_descend")), int(_main.get("debug_unfinished_foes")),
			int(_main.get("debug_unfinished_chests")), int(_main.get("debug_unfinished_chests_locked")),
			int(_main.get("debug_unfinished_loot"))])
	if _use_shop:
		var lvls := []
		for sid in GameState.skills.keys():
			lvls.append("%s=%d" % [str(sid), int(GameState.skills[sid])])
		lvls.sort()
		print("DEEPDELVE: shops_shopped=%d gold_spent=%s skills={%s}" % [
			_shops_shopped, _fmt(_gold_spent), ", ".join(lvls)])
	if _violations == 0:
		print("DEEPDELVE: PASS — no inconsistencies, no stalls")
	else:
		printerr("DEEPDELVE: %d VIOLATIONS" % _violations)
	get_tree().quit(_violations)
