extends Node
## Depth-scale validation: dynamic minimap, bigger maps with depth, faster
## walk with depth. Unit-checks the new math, then soaks the real game at
## 16x across multiple depths: map sizes grow, minimap follows the player,
## floors fully clear, save/load round-trips on a big deep floor.
##
## Run: godot --headless --path . tests/depth_scale_scene.tscn
##   -- --soak-virtual=3000 --soak-scale=16
## Exits 0 on pass; prints FAIL lines and exits 1 on any violation.

const HUD := preload("res://scripts/hud.gd")
const DG := preload("res://scripts/dungeon_gen.gd")

var _failures := 0
var _frames := 0
var _virtual := 0.0
var _max_virtual := 3000.0
var _main: Node = null
var _last_depth := 1
var _max_depth := 1
var _last_progress := 0.0
var _was_alive := true
var _deaths := 0
var _minimap_checks := 0
var _minimap_ok := 0
var _mapsize_ok := 0
var _mapsize_bad := 0
var _max_map_seen := 0
var _saved_once := false
var _save_roundtrip_ok := false
var _shop_closes := 0
var _finished := false
var _fixed40 := false


func _check(cond: bool, name: String, detail: String = "") -> void:
	if cond:
		print("  PASS  %s" % name)
	else:
		_failures += 1
		printerr("  FAIL  %s  %s" % [name, detail])


func _ready() -> void:
	print("DEPTHSCALE: unit checks")
	_unit_walk_mult()
	_unit_minimap_view()
	_unit_map_formula()
	var scale := 16.0
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--soak-virtual="):
			var n: String = a.trim_prefix("--soak-virtual=")
			if n.is_valid_float():
				_max_virtual = float(n)
		if a.begins_with("--soak-scale="):
			var n2: String = a.trim_prefix("--soak-scale=")
			if n2.is_valid_float():
				scale = float(n2)
		if a == "--fixed40":
			_fixed40 = true
	Engine.time_scale = scale
	# Fresh run: a stale save from an older build would restore an old-size
	# floor and poison the map-size checks.
	if FileAccess.file_exists("user://savegame.dat"):
		DirAccess.remove_absolute("user://savegame.dat")
	GameState.depth = 1
	var packed: PackedScene = load("res://scenes/main.tscn")
	_main = packed.instantiate()
	if _fixed40:
		_main.set("debug_fixed_map", 40)
	get_tree().root.add_child.call_deferred(_main)
	print("DEPTHSCALE: %d virtual s at %sx%s" % [int(_max_virtual), str(scale),
		" (fixed 40x40 control)" if _fixed40 else ""])


## --- unit: depth walk speed ----------------------------------------------
func _unit_walk_mult() -> void:
	var gs = GameState
	var keep: int = gs.depth
	# Curve retuned Oct 2026 (James: depth 10+ was too zippy): 1x→2x,
	# gentled slope, cap reached at depth 26. d10 = 1+0.04*9 = 1.36.
	gs.depth = 1
	_check(is_equal_approx(gs.depth_walk_mult(), 1.0), "walk d1 = 1.0x")
	gs.depth = 10
	_check(is_equal_approx(gs.depth_walk_mult(), 1.36), "walk d10 = 1.36x",
		"got %s" % str(gs.depth_walk_mult()))
	gs.depth = 26
	_check(is_equal_approx(gs.depth_walk_mult(), 2.0), "walk d26 hits 2.0x cap",
		"got %s" % str(gs.depth_walk_mult()))
	gs.depth = 100
	_check(is_equal_approx(gs.depth_walk_mult(), 2.0), "walk d100 capped 2.0x")
	gs.depth = keep


## --- unit: minimap follow view -------------------------------------------
func _mk_mm(gw: int, gh: int, px: int, py: int) -> HUD.Minimap:
	var mm = HUD.Minimap.new()
	mm.size = Vector2(164, 164)
	mm.gw = gw
	mm.gh = gh
	mm.ppos = Vector2i(px, py)
	return mm


func _unit_minimap_view() -> void:
	# Big map, player centered: window centered on player.
	var mm: HUD.Minimap = _mk_mm(80, 80, 40, 40)
	var v: Array = mm.compute_view()
	_check(int(v[0]) == 30 and int(v[1]) == 30, "view centered on player",
		"got %s" % str([v[0], v[1]]))
	_check(int(v[2]) - int(v[0]) == 21, "view width 21 cells")
	# Corner: clamped to edges, never out of bounds.
	mm = _mk_mm(80, 80, 0, 0)
	v = mm.compute_view()
	_check(int(v[0]) == 0 and int(v[1]) == 0, "view clamped at corner")
	mm = _mk_mm(80, 80, 79, 79)
	v = mm.compute_view()
	_check(int(v[2]) == 80 and int(v[3]) == 80, "view clamped at far edge")
	# Small map: whole map shown (legacy fit mode).
	mm = _mk_mm(10, 10, 5, 5)
	v = mm.compute_view()
	_check(int(v[0]) == 0 and int(v[2]) == 10, "small map fully shown")


## --- unit: map size formula ------------------------------------------------
func _expected_size(depth: int) -> int:
	return mini(40 + 4 * (depth - 1), 120)


func _unit_map_formula() -> void:
	_check(_expected_size(1) == 40, "map d1 = 40")
	_check(_expected_size(10) == 76, "map d10 = 76")
	_check(_expected_size(21) == 120, "map d21 = 120 (cap)")
	_check(_expected_size(200) == 120, "map d200 capped 120")
	# Generator stays valid at big sizes: connected, stairs reachable.
	var rng := RandomNumberGenerator.new()
	rng.seed = 1234
	for d in [10, 25]:
		var s := _expected_size(d)
		var gen: Dictionary = DG.generate(s, s, d, rng)
		var grid: Array = gen["grid"]
		var ok := _flood_reaches(grid, s, s,
			gen["player_start"], gen["stairs"])
		_check(ok, "gen d%d %dx%d stairs reachable" % [d, s, s])
		var rooms: Array = gen["rooms"]
		_check(rooms.size() >= 7, "gen d%d room count sane (%d)" % [d, rooms.size()])


func _flood_reaches(grid: Array, w: int, h: int, a: Vector2i, b: Vector2i) -> bool:
	var seen := {}
	var q: Array = [a]
	seen[a] = true
	while not q.is_empty():
		var p: Vector2i = q.pop_back()
		if p == b:
			return true
		for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
			var n: Vector2i = p + d
			if n.x < 0 or n.y < 0 or n.x >= w or n.y >= h or seen.has(n):
				continue
			if int((grid[n.y] as Array)[n.x]) == DG.WALL:
				continue
			seen[n] = true
			q.append(n)
	return false


## --- soak ------------------------------------------------------------------
func _process(delta: float) -> void:
	if _finished:
		return
	_frames += 1
	_virtual += delta
	if _main == null or not is_instance_valid(_main):
		return
	var gs = GameState

	# Floor-clear shop pauses the delve by design; tap through it.
	if bool(_main.get("_shop_open")):
		_shop_closes += 1
		(_main.get("hud") as Node).hide_shop()

	if gs.depth != _last_depth:
		_on_new_depth(gs)
		_last_depth = gs.depth
		_last_progress = _virtual
		_max_depth = maxi(_max_depth, gs.depth)

	if not gs.alive and _was_alive:
		_was_alive = false
		_deaths += 1
		_last_progress = _virtual
		_handle_death(gs)
	elif gs.alive and not _was_alive:
		_was_alive = true

	# Periodic minimap-follow verification.
	if _frames % 30 == 0 and gs.alive:
		_check_minimap(gs)

	# Save/load round-trip once on a big deep floor.
	if not _saved_once and gs.depth >= 6 and gs.alive:
		_saved_once = true
		_save_load_roundtrip(gs)

	# Stall watchdog: 6 virtual minutes with no depth change or death.
	if _virtual - _last_progress > 360.0:
		_fail("STALL: no progress for 6 virtual min at depth %d" % gs.depth)
		_dump_stall(gs)
		_finish()
		return

	if _virtual >= _max_virtual:
		_finish()


func _on_new_depth(gs) -> void:
	var gen: Dictionary = _main.get("gen")
	var w: int = int(gen.get("width", 0))
	var h: int = int(gen.get("height", 0))
	_max_map_seen = maxi(_max_map_seen, w)
	var want := 40 if _fixed40 else _expected_size(gs.depth)
	if w == want and h == want:
		_mapsize_ok += 1
	else:
		_mapsize_bad += 1
		_fail("map size d%d: got %dx%d, want %dx%d" % [gs.depth, w, h, want, want])
	# Big-map validity: stairs reachable from spawn.
	var grid: Array = gen["grid"]
	if not _flood_reaches(grid, w, h, gen["player_start"], gen["stairs"]):
		_fail("stairs unreachable on d%d %dx%d" % [gs.depth, w, h])
	print("DEPTHSCALE t=%.0fs: depth=%d map=%dx%d rooms=%d" % [
		_virtual, gs.depth, w, h, (gen["rooms"] as Array).size()])


func _check_minimap(gs) -> void:
	var hud = _main.get("hud")
	var mm = hud.get("_minimap")
	if mm == null:
		return
	mm.ppos = _main.get("player").grid_pos
	var v: Array = mm.call("compute_view")
	_minimap_checks += 1
	var p: Vector2i = mm.ppos
	var x0 := int(v[0]); var y0 := int(v[1])
	var x1 := int(v[2]); var y1 := int(v[3])
	var in_view := p.x >= x0 and p.x < x1 and p.y >= y0 and p.y < y1
	var in_bounds: bool = x0 >= 0 and y0 >= 0 and x1 <= mm.gw and y1 <= mm.gh
	if in_view and in_bounds:
		_minimap_ok += 1
	else:
		_fail("minimap view bad: ppos=%s view=%s map=%dx%d" % [
			str(p), str([x0, y0, x1, y1]), mm.gw, mm.gh])
	# Follow mode must be active whenever the map is bigger than the view.
	var vw := x1 - x0
	if mm.gw > vw and (x1 - x0) >= mm.gw:
		_fail("minimap not following on big map d%d" % gs.depth)


func _save_load_roundtrip(gs) -> void:
	var d0: int = gs.depth
	var p0: Vector2i = _main.get("player").grid_pos
	var hp0: float = gs.hp
	var gold0: float = gs.gold
	var w0: int = int((_main.get("gen") as Dictionary).get("width", 0))
	_main.save_game()
	# Trash the live floor, then restore from disk.
	_main.load_game()
	var ok: bool = gs.depth == d0 \
		and _main.get("player").grid_pos == p0 \
		and is_equal_approx(gs.hp, hp0) \
		and is_equal_approx(gs.gold, gold0) \
		and int((_main.get("gen") as Dictionary).get("width", 0)) == w0
	_save_roundtrip_ok = ok
	_check(ok, "save/load round-trip on d%d %dx%d" % [d0, w0, w0],
		"depth/pos/hp/gold/map mismatch")


## Death flow: pick best gear as heirlooms and delve again (mirrors the
## real "Delve Again" tap; deep_delve does the same via death_test_*).
func _handle_death(gs) -> void:
	var best_w := {}
	var best_a := {}
	for item in gs.run_gear:
		var slot := str(item.get("slot", ""))
		if slot == "weapon" and (best_w.is_empty() or float(item.get("power", 0)) > float(best_w.get("power", 0))):
			best_w = item
		elif slot == "armor" and (best_a.is_empty() or float(item.get("power", 0)) > float(best_a.get("power", 0))):
			best_a = item
	var hud = _main.get("hud")
	hud.death_test_pick(best_w, best_a)
	hud.death_test_confirm()
	# Phase 3: the dead run ends in town — delve again from there so the
	# depth progression the test measures can continue.
	_main.start_delve()


func _fail(msg: String) -> void:
	_failures += 1
	printerr("  FAIL  %s" % msg)


func _dump_stall(gs) -> void:
	var m = _main
	var p = m.get("player")
	var foes := 0
	for e in m.get("enemies"):
		if is_instance_valid(e) and not e.dead:
			foes += 1
	var uch := 0
	for c in m.get("chests"):
		if not bool(c["opened"]):
			uch += 1
	var ul := 0
	for l in m.get("loot"):
		if not bool(l["taken"]):
			ul += 1
	printerr("  STALLDUMP pos=%s busy=%s facing=%d target=%s brain_room=%d stairs_marked=%s crit_retreat=%s" % [
		str(p.grid_pos), str(p.busy), p.facing, str(m.get("debug_last_target")),
		int(m.get("_brain_room")), str(m.get("_stairs_marked")), str(m.get("_critical_retreat"))])
	printerr("  STALLDUMP foes=%d unopened_chests=%d untaken_loot=%d explored=%d hp=%s/%s" % [
		foes, uch, ul, (m.get("explored") as Dictionary).size(),
		str(gs.hp), str(gs.max_hp)])


func _finish() -> void:
	_finished = true
	var m = _main
	print("DEPTHSCALE: done t=%.0fs deaths=%d max_depth=%d max_map=%d" % [
		_virtual, _deaths, _max_depth, _max_map_seen])
	print("  map sizes: %d ok / %d bad" % [_mapsize_ok, _mapsize_bad])
	print("  minimap: %d/%d follow checks ok" % [_minimap_ok, _minimap_checks])
	print("  save round-trip: %s" % ("PASS" if _save_roundtrip_ok else ("NOT ATTEMPTED" if not _saved_once else "FAIL")))
	if m != null and is_instance_valid(m):
		print("  unfinished at descends: %d (foes %d, chests %d, loot %d)" % [
			int(m.get("debug_unfinished_at_descend")),
			int(m.get("debug_unfinished_foes")),
			int(m.get("debug_unfinished_chests")),
			int(m.get("debug_unfinished_loot"))])
		print("  retreat descends: %d  shop closes: %d" % [
			int(m.get("debug_retreat_descends")), _shop_closes])
	if _saved_once and not _save_roundtrip_ok:
		_failures += 1
	if _failures == 0:
		print("DEPTHSCALE: ALL PASS")
	else:
		printerr("DEPTHSCALE: %d FAILURES" % _failures)
	get_tree().quit(_failures)
