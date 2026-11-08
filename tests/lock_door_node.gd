extends Node
## Lock/door/seal/sleeper test (2026-09-26): chest wards + padlocks,
## Lockpicking, doors (closed/locked/open), bash consequences, sleepers,
## and the warded stairs.
##
## Run: godot --headless --path . tests/lock_door_scene.tscn
## Exits 0 on pass, 1 on any failure.

const DungeonGenScript := preload("res://scripts/dungeon_gen.gd")

var _failures := 0
var _main: Node = null


func _check(cond: bool, name: String, detail: String = "") -> void:
	if cond:
		print("  PASS  %s" % name)
	else:
		_failures += 1
		printerr("  FAIL  %s  %s" % [name, detail])


func _ready() -> void:
	Engine.time_scale = 8.0
	# Fresh boot: a stale save (e.g. a long suite's autosave) would restore
	# mid-run state instead of the fresh run this test drives.
	if FileAccess.file_exists("user://savegame.dat"):
		DirAccess.remove_absolute("user://savegame.dat")
	_test_gen()
	var packed: PackedScene = load("res://scenes/main.tscn")
	_main = packed.instantiate()
	get_tree().root.add_child.call_deferred(_main)
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	_main.set("debug_no_shop", true)
	GameState.idle_mode = false
	GameState.skills["lockpicking"] = 0
	GameState.skills["stealth"] = 0
	await _test_seal_and_padlock()
	await _test_doors()
	await _test_stairs_ward()
	await _test_sleepers()
	await _test_sealed_chest_blocks_bfs()
	await _test_stairs_ward_blocks_bfs()
	await _test_chests_spawn_in_rooms()
	Engine.time_scale = 1.0
	if _failures == 0:
		print("LOCKDOOR: ALL PASS")
	else:
		printerr("LOCKDOOR: %d FAILURES" % _failures)
	get_tree().quit(_failures)


func _test_gen() -> void:
	var seen_doors := 0
	var seen_locked_doors := 0
	var seen_locked_chests := 0
	var seen_sleepers := 0
	var fields_ok := true
	var all_sealed := true
	for seed in [11, 22, 33, 44, 55]:
		var rng := RandomNumberGenerator.new()
		rng.seed = seed
		var g: Dictionary = DungeonGenScript.generate(40, 40, 3, rng)
		for d in (g["doors"] as Array):
			seen_doors += 1
			if str(d["state"]) == "locked":
				seen_locked_doors += 1
			for k in ["tumblers", "bash_hp", "tier", "axis", "state", "pos"]:
				if not d.has(k):
					fields_ok = false
		for c in (g["chests"] as Array):
			for k in ["sealed", "lock_tier", "tumblers", "room_idx", "opened", "pos"]:
				if not c.has(k):
					fields_ok = false
			if not bool(c["sealed"]):
				all_sealed = false
			if int(c["lock_tier"]) > 0:
				seen_locked_chests += 1
		for e in (g["enemies"] as Array):
			if not e.has("asleep"):
				fields_ok = false
			if bool(e["asleep"]):
				seen_sleepers += 1
	_check(fields_ok, "gen field shapes (doors/chests/enemies)")
	_check(all_sealed, "chests spawn sealed")
	_check(seen_doors > 0, "doors generate", "saw %d" % seen_doors)
	_check(seen_locked_doors > 0, "locked doors generate", "saw %d" % seen_locked_doors)
	_check(seen_locked_chests > 0, "padlocked chests generate", "saw %d" % seen_locked_chests)
	_check(seen_sleepers > 0, "sleepers generate", "saw %d" % seen_sleepers)


## Wait until the player's step tween finishes (mirrors the game's own
## busy guard in _try_step).
func _wait_not_busy() -> void:
	var guard := 0
	while bool(_main.get("player").busy) and guard < 240:
		await get_tree().process_frame
		guard += 1
	_check(not bool(_main.get("player").busy), "player tween settled")


## Open neighbor cell of `pos` (floor, unoccupied), or (-999,-999).
func _open_neighbor(pos: Vector2i) -> Vector2i:
	for d in [Vector2i(0, -1), Vector2i(1, 0), Vector2i(0, 1), Vector2i(-1, 0)]:
		var c: Vector2i = pos + d
		if _main.cell_at(c) == DungeonGenScript.WALL:
			continue
		if _main.enemy_at(c) != null:
			continue
		if not _main.door_at(c).is_empty():
			continue
		if not _main.chest_at(c).is_empty():
			continue
		return c
	return Vector2i(-999, -999)


func _test_seal_and_padlock() -> void:
	var chests: Array = _main.get("chests")
	_check(not chests.is_empty(), "floor has chests")
	# Prefer a chest whose room holds hostiles, so clearing it is meaningful.
	# (Rooms that start empty get their seals broken at floor start.)
	var ch := {}
	for c in chests:
		if bool(c["sealed"]) and _main._hostiles_in_room(int(c["room_idx"])) > 0:
			ch = c
			break
	if ch.is_empty():
		ch = chests[0]
		ch["sealed"] = true
		_main.get("view").update_chest(ch)
		# Plant a hostile in its room so there is something to clear.
		var ri0: int = int(ch["room_idx"])
		var room0: Rect2i = (_main.get("floor_rooms") as Array)[ri0]
		var planted := false
		for e in (_main.get("enemies") as Array):
			if is_instance_valid(e) and not e.dead and not planted:
				for yy in range(room0.position.y, room0.position.y + room0.size.y):
					for xx in range(room0.position.x, room0.position.x + room0.size.x):
						var cell := Vector2i(xx, yy)
						if _main.cell_at(cell) != DungeonGenScript.WALL \
								and _main.enemy_at(cell) == null \
								and _main.chest_at(cell).is_empty() \
								and _main.door_at(cell).is_empty() \
								and cell != (_main.get("gen") as Dictionary)["stairs"]:
							e.grid_pos = cell
							e.position = _main.get("view").world_pos(cell)
							planted = true
							break
					if planted:
						break
		_check(planted, "planted a hostile in the chest's room")
	_check(not ch.is_empty(), "have a sealed chest to test")
	var adj := _open_neighbor(ch["pos"])
	_check(adj != Vector2i(-999, -999), "chest has open neighbor")
	_main.get("player").place_at(adj)
	await get_tree().process_frame
	_main._bump_chest(ch)
	_check(not bool(ch["opened"]), "sealed chest refuses to open")
	_check(bool(ch["sealed"]), "seal still up before room clear")
	# Kill the whole room -> the ward breaks via the died signal.
	var ri: int = int(ch["room_idx"])
	for e in (_main.get("enemies") as Array).duplicate():
		if is_instance_valid(e) and not e.dead and _main._room_of(e.grid_pos) == ri:
			e.take_damage(1000000.0)
	await get_tree().process_frame
	await get_tree().process_frame
	_check(not bool(ch["sealed"]), "seal breaks when room cleared")
	# Padlock: force tier 2, no skill -> 6 bumps to open.
	ch["lock_tier"] = 2
	ch["tumblers"] = 6
	_main.get("view").update_chest(ch)
	for i in 6:
		_main._bump_chest(ch)
	_check(int(ch["tumblers"]) == 0, "tumblers click down per bump")
	_check(bool(ch["opened"]), "padlock opens after tumblers done")
	# Lockpicking >= tier: instant.
	if chests.size() > 1:
		var ch2: Dictionary = chests[1]
		ch2["sealed"] = false
		ch2["lock_tier"] = 1
		ch2["tumblers"] = 3
		GameState.skills["lockpicking"] = 1
		_main._bump_chest(ch2)
		_check(bool(ch2["opened"]), "lockpicking >= tier opens instantly")
		GameState.skills["lockpicking"] = 0


func _test_doors() -> void:
	var doors: Array = _main.get("doors")
	_check(not doors.is_empty(), "floor has doors")
	# Closed door: bump opens it and steps through.
	var closed := {}
	for d in doors:
		if str(d["state"]) == "closed":
			closed = d
			break
	if closed.is_empty():
		closed = doors[0]
		closed["state"] = "closed"
		_main.get("view").update_door(closed)
	var adj := _open_neighbor(closed["pos"])
	_main.get("player").place_at(adj)
	await get_tree().process_frame
	var dir: Vector2i = (closed["pos"] as Vector2i) - adj
	var stepped: bool = _main._bump_door(closed, dir)
	_check(str(closed["state"]) == "open", "closed door opens on bump")
	_check(stepped, "bump reports step-through")
	await _wait_not_busy()
	_check(_main.get("player").grid_pos == (closed["pos"] as Vector2i),
		"player stepped through the door")
	# Locked door, no skill: bash until it splinters.
	var locked := {}
	for d in doors:
		if str(d["state"]) == "locked":
			locked = d
			break
	if locked.is_empty():
		locked = doors[0]
		locked["state"] = "locked"
		locked["tier"] = 2
		locked["tumblers"] = 6
		locked["bash_hp"] = 4
		_main.get("view").update_door(locked)
	GameState.skills["lockpicking"] = 0
	adj = _open_neighbor(locked["pos"])
	_main.get("player").place_at(adj)
	await get_tree().process_frame
	dir = (locked["pos"] as Vector2i) - adj
	var hp0: int = int(locked["bash_hp"])
	_main._bump_door(locked, dir)
	_check(int(locked["bash_hp"]) == hp0 - 1, "bash damages the door")
	var guard := 0
	while str(locked["state"]) != "open" and guard < 25:
		_main._bump_door(locked, dir)
		guard += 1
		await get_tree().process_frame
	_check(str(locked["state"]) == "open", "bash eventually splinters the door")
	await _wait_not_busy()
	_check((_main.get("enemies") as Array).size() <= 80,
		"bash spawns respect the enemy cap")
	# Bash consequence, direct: spawns 1-3 monsters.
	var before: int = (_main.get("enemies") as Array).size()
	_main._bash_spawn(locked["pos"])
	var after: int = (_main.get("enemies") as Array).size()
	_check(after >= before and after <= 80 and after <= before + 3,
		"bash spawn adds 1-3 monsters (capped)", "%d -> %d" % [before, after])
	# Locked door + skill >= tier: silent pick.
	locked["state"] = "locked"
	locked["tier"] = 1
	locked["tumblers"] = 3
	locked["bash_hp"] = 3
	_main.get("view").update_door(locked)
	GameState.skills["lockpicking"] = 1
	adj = _open_neighbor(locked["pos"])
	_main.get("player").place_at(adj)
	await get_tree().process_frame
	dir = (locked["pos"] as Vector2i) - adj
	_main._bump_door(locked, dir)
	_check(str(locked["state"]) == "open", "lockpicking >= tier picks silently")
	await _wait_not_busy()
	GameState.skills["lockpicking"] = 0


func _test_stairs_ward() -> void:
	var stairs: Vector2i = (_main.get("gen") as Dictionary)["stairs"]
	var ri: int = _main._room_of(stairs)
	_check(ri >= 0, "stairs have a room")
	# Clear the stairs room, then plant one hostile: the ward must hold.
	for e in (_main.get("enemies") as Array).duplicate():
		if is_instance_valid(e) and not e.dead and _main._room_of(e.grid_pos) == ri:
			e.take_damage(1000000.0)
	await get_tree().process_frame
	var foe = null
	for e in (_main.get("enemies") as Array):
		if is_instance_valid(e) and not e.dead:
			foe = e
			break
	_check(foe != null, "a living foe exists for the ward test")
	var spot: Vector2i = _main._random_open_cell_near(stairs, 5)
	_check(spot != Vector2i(-999, -999), "found a cell for the warden")
	# Make sure the planted cell is inside the stairs room.
	if _main._room_of(spot) != ri:
		spot = stairs
	foe.grid_pos = spot
	foe.position = _main.get("view").world_pos(spot)
	var adj := _open_neighbor(stairs)
	_main.get("player").place_at(adj)
	await _wait_not_busy()
	var dir: Vector2i = stairs - adj
	var depth0: int = GameState.depth
	_main._try_step(dir)
	_check(GameState.depth == depth0, "warded stairs refuse while hostiles remain")
	# Clear the whole stairs room (a wanderer may have strolled in).
	for e in (_main.get("enemies") as Array).duplicate():
		if is_instance_valid(e) and not e.dead and _main._room_of(e.grid_pos) == ri:
			e.take_damage(1000000.0)
	await get_tree().process_frame
	await get_tree().process_frame
	_main.get("player").place_at(adj)
	await _wait_not_busy()
	_main._try_step(dir)
	for i in 10:
		await get_tree().process_frame
	_check(GameState.depth == depth0 + 1, "cleared stairs descend")


func _test_sleepers() -> void:
	var foe = null
	for e in (_main.get("enemies") as Array):
		if is_instance_valid(e) and not e.dead:
			foe = e
			break
	_check(foe != null, "a foe exists for the sleeper test")
	# Proximity wakes with Stealth 0.
	foe.asleep = true
	var adj := _open_neighbor(foe.grid_pos)
	_main.get("player").place_at(adj)
	await get_tree().process_frame
	_main._disturb_sleepers()
	_check(not foe.asleep, "proximity wakes a sleeper (stealth 0)")
	# Alert wakes in radius.
	foe.asleep = true
	var woke: int = _main._alert_nearby(foe.grid_pos, 3)
	_check(woke >= 1 and not foe.asleep, "bash alert wakes sleepers in radius")
	# The free first hit: no retaliation in idle mode.
	GameState.idle_mode = true
	GameState.hp = GameState.max_hp
	var full: float = GameState.hp
	foe.asleep = true
	foe.hp = foe.max_hp
	# Silence every foe's independent _process tick (cooldowns start at 0),
	# and park the brain timer: this check is about the attack's *direct*
	# retaliation, which still fires through _enemy_strike when the rules
	# say so. (A brain bump-attack during the wait would retaliate through
	# the direct path and muddy the check.)
	for e in (_main.get("enemies") as Array):
		if is_instance_valid(e):
			e.attack_cooldown = 999.0
			e.wander_cooldown = 999.0
	_main.set("_idle_timer", -100000.0)
	var ehp0: float = foe.hp
	_main._player_attack(foe)
	_check(not foe.asleep, "attack wakes the sleeper")
	# Damage lands on the swing's downswing (procedural FP rig) — let it land.
	for i in 10:
		await get_tree().process_frame
	_check(foe.hp < ehp0, "attack damages the sleeper")
	_check(GameState.hp == full, "sleeper grants a free first hit (no retaliation)")
	GameState.idle_mode = false


## Regression: a sealed chest between the player and a target must not loop
## the brain — BFS treats sealed chests as solid (bumping a ward is a no-op,
## so pathing through one parks the crawler on one cell forever).
func _test_sealed_chest_blocks_bfs() -> void:
	var gen: Dictionary = _main.get("gen")
	var w: int = gen["width"]
	var h: int = gen["height"]
	var stairs: Vector2i = gen["stairs"]
	var a := Vector2i(-999, -999)
	var b := Vector2i.ZERO
	var c := Vector2i.ZERO
	for y in range(1, h - 2):
		for x in range(1, w - 2):
			var c0 := Vector2i(x, y)
			var c1 := Vector2i(x + 1, y)
			var c2 := Vector2i(x + 2, y)
			var clear := true
			for cc in [c0, c1, c2]:
				if _main.cell_at(cc) != DungeonGenScript.FLOOR:
					clear = false
				if _main.enemy_at(cc) != null:
					clear = false
				if not _main.chest_at(cc).is_empty():
					clear = false
				if not _main.door_at(cc).is_empty():
					clear = false
				if cc == stairs:
					clear = false
			if clear:
				a = c0
				b = c1
				c = c2
				break
		if a.x != -999:
			break
	_check(a.x != -999, "found a 3-cell floor run for the BFS test")
	if a.x == -999:
		return
	_main.get("player").place_at(a)
	await get_tree().process_frame
	# Park a sealed chest on the middle cell, then ask BFS for the far cell.
	var ch: Dictionary = (_main.get("chests") as Array)[0]
	ch["pos"] = b
	ch["sealed"] = true
	ch["opened"] = false
	_main.get("view").update_chest(ch)
	var step: Vector2i = _main._bfs_first_step([c] as Array[Vector2i])
	_check(a + step != b, "BFS never steps into a sealed chest", "step=%s" % step)
	# And the unsealed kind stays pathable (bump-opens on the way through).
	ch["sealed"] = false
	_main.get("view").update_chest(ch)
	var step2: Vector2i = _main._bfs_first_step([c] as Array[Vector2i])
	_check(step2 == Vector2i(1, 0) or a + step2 != b,
		"unsealed chests stay pathable", "step=%s" % step2)


## Regression: while the stairs room holds hostiles, BFS must not route
## through the stairs cell — the ward refuses the step, so pathing through it
## loops the brain on one cell forever (second deep-delve stall found by the
## soak: last hostile beyond warded stairs).
func _test_stairs_ward_blocks_bfs() -> void:
	var stairs: Vector2i = (_main.get("gen") as Dictionary)["stairs"]
	var stairs_room: int = int(_main.get("_stairs_room"))
	var foe = null
	for e in (_main.get("enemies") as Array):
		if is_instance_valid(e) and not e.dead:
			foe = e
			break
	_check(foe != null, "a living foe exists for the ward test")
	if foe == null:
		return
	# Park the foe inside the stairs room so the ward is active.
	var placed := false
	for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
		var cc: Vector2i = stairs + d
		if _main.cell_at(cc) == DungeonGenScript.FLOOR \
				and _main._room_of(cc) == stairs_room:
			foe.grid_pos = cc
			placed = true
			break
	_check(placed, "foe parked inside the stairs room")
	_check(_main._hostiles_in_room(stairs_room) > 0, "exit ward is active")
	# Player two cells east of the stairs, target two cells west: the straight
	# line runs through the stairs cell.
	var ppos := stairs + Vector2i(2, 0)
	var tpos := stairs + Vector2i(-2, 0)
	if _main.cell_at(ppos) != DungeonGenScript.FLOOR \
			or _main.cell_at(tpos) != DungeonGenScript.FLOOR:
		return  # geometry doesn't fit on this floor; skip
	_main.get("player").place_at(ppos)
	await get_tree().process_frame
	var step: Vector2i = _main._bfs_first_step([tpos] as Array[Vector2i])
	_check(ppos + step != stairs, "BFS does not route through warded stairs",
		"step=%s" % step)
	# Sanity: with the room clear the stairs are walkable again.
	for e in (_main.get("enemies") as Array):
		if is_instance_valid(e) and not e.dead \
				and _main._room_of(e.grid_pos) == stairs_room:
			e.take_damage(999999.0)
	await get_tree().process_frame
	_check(_main._hostiles_in_room(stairs_room) == 0, "stairs room clear")
	var step2: Vector2i = _main._bfs_first_step([stairs] as Array[Vector2i])
	_check(step2 != Vector2i.ZERO, "clear stairs are pathable again",
		"step=%s" % step2)


## Regression: chests must spawn inside rooms, never in corridors. A sealed
## chest is solid until its room clears (and corridor seals never break), so
## one dropped in a 1-wide corridor could wall off the map permanently —
## for the brain AND a real player.
func _test_chests_spawn_in_rooms() -> void:
	var bad := 0
	var total := 0
	for s in [11, 22, 33, 44, 55]:
		var r := RandomNumberGenerator.new()
		r.seed = s
		var g: Dictionary = DungeonGenScript.generate(40, 40, 3, r)
		for ch in (g["chests"] as Array):
			total += 1
			if int(ch["room_idx"]) < 0:
				bad += 1
	_check(bad == 0, "all chests spawn inside rooms", "%d/%d in corridors" % [bad, total])
