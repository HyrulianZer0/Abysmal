extends Node
## Save/load round-trip on a big deep floor (68x68 at depth 8), through the
## real boot path: run A saves mid-run, run B boots fresh and restores.
## Run: godot --headless --path . tests/depth_scale_roundtrip_scene.tscn
## Exits 0 on success, 1 on mismatch.

var _main: Node = null
var _phase := 0
var _frames := 0
var _snap := {}
var _failures := 0


func _check(cond: bool, name: String, detail: String = "") -> void:
	if cond:
		print("  PASS  %s" % name)
	else:
		_failures += 1
		printerr("  FAIL  %s  %s" % [name, detail])


func _ready() -> void:
	print("ROUNDTRIP: starting")
	if FileAccess.file_exists("user://savegame.dat"):
		DirAccess.remove_absolute("user://savegame.dat")
	_spawn_main()


func _spawn_main() -> void:
	var packed: PackedScene = load("res://scenes/main.tscn")
	_main = packed.instantiate()
	get_tree().root.add_child.call_deferred(_main)


func _process(_delta: float) -> void:
	_frames += 1
	if _phase == 0:
		# Wait until run A is in the tree with its first floor built.
		if _frames < 30 or not is_instance_valid(_main) \
				or not _main.is_inside_tree() or _main.get("player") == null:
			return
		# Jump to a big deep floor and let the idle brain play a little.
		GameState.depth = 8
		_main._new_depth()
		var w: int = int((_main.get("gen") as Dictionary)["width"])
		_check(w == 68, "deep floor is 68x68", "got %d" % w)
		_phase = 1
		_frames = 0
		return
	if _phase == 1:
		if _frames < 60:
			return
		_snapshot_and_save()
		# Kill run A; run B boots fresh and takes the real restore path.
		_main.queue_free()
		_main = null
		_phase = 2
		_frames = 0
		return
	if _phase == 2:
		if _frames < 10:
			return
		_spawn_main()
		_phase = 3
		_frames = 0
		return
	if _phase == 3:
		if not is_instance_valid(_main) or not _main.is_inside_tree() \
				or _main.get("player") == null:
			return
		# Freeze the world on the first valid frame: no combat/regen ticks
		# between restore and verify, so hp must match exactly.
		Engine.time_scale = 0.0
		_verify_restore()
		Engine.time_scale = 1.0
		_finish()
		return


func _snapshot_and_save() -> void:
	var gs = GameState
	var p = _main.get("player")
	_snap = {
		"depth": gs.depth,
		"pos": p.grid_pos,
		"hp": gs.hp,
		"gold": gs.gold,
		"width": int((_main.get("gen") as Dictionary)["width"]),
		"foes": (_main.get("enemies") as Array).size(),
		"explored_keys": (_main.get("explored") as Dictionary).keys(),
	}
	_main.save_game()
	_check(FileAccess.file_exists("user://savegame.dat"), "save file written")


func _verify_restore() -> void:
	var gs = GameState
	var p = _main.get("player")
	_check(gs.depth == int(_snap["depth"]), "depth restored")
	_check(p.grid_pos == _snap["pos"], "player pos restored",
		"got %s want %s" % [str(p.grid_pos), str(_snap["pos"])])
	_check(is_equal_approx(gs.hp, float(_snap["hp"])), "hp restored")
	_check(is_equal_approx(gs.gold, float(_snap["gold"])), "gold restored")
	_check(int((_main.get("gen") as Dictionary)["width"]) == int(_snap["width"]),
		"map size restored (68x68)")
	_check((_main.get("enemies") as Array).size() == int(_snap["foes"]),
		"enemy count restored",
		"got %d want %d" % [(_main.get("enemies") as Array).size(), int(_snap["foes"])])
	# Explored must be a superset: load re-runs the radius-4 reveal at the
	# restored position, which can catch up cells the saver hadn't revealed
	# yet (reveal lands in the step callback, one stride behind grid_pos).
	var rkeys := (_main.get("explored") as Dictionary).keys()
	var missing := 0
	for k in _snap["explored_keys"]:
		if not (rkeys as Array).has(k):
			missing += 1
	_check(missing == 0, "explored fog restored (superset)",
		"%d saved cells missing" % missing)


func _finish() -> void:
	if _failures == 0:
		print("ROUNDTRIP: ALL PASS")
	else:
		printerr("ROUNDTRIP: %d FAILURES" % _failures)
	get_tree().quit(_failures)
