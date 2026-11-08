extends Node
## Save versioning + migration test.
## - A hand-crafted v1 save (pre-facing, pre-tutorial-flag) must load and migrate.
## - Saves with version 0 / 99 must be rejected.
## - A fresh v2 save round-trips.
## Run: godot --headless --path . tests/save_migrate_scene.tscn

var _failures := 0
var _main: Node = null
var _phase := 0
var _frames := 0


func _check(cond: bool, name: String, detail: String = "") -> void:
	if cond:
		print("  PASS  %s" % name)
	else:
		_failures += 1
		printerr("  FAIL  %s  %s" % [name, detail])


func _ready() -> void:
	print("SAVEMIGRATE: starting")
	if FileAccess.file_exists("user://savegame.dat"):
		DirAccess.remove_absolute("user://savegame.dat")
	var packed: PackedScene = load("res://scenes/main.tscn")
	_main = packed.instantiate()
	get_tree().root.add_child.call_deferred(_main)


func _write_save(d: Dictionary) -> void:
	var f := FileAccess.open("user://savegame.dat", FileAccess.WRITE)
	f.store_string(var_to_str(d))
	f.close()


func _process(_delta: float) -> void:
	_frames += 1
	if _phase == 0:
		if _frames < 20 or not is_instance_valid(_main) or not _main.is_inside_tree():
			return
		# Craft a v1 save: meta only, hub mode so no floor rebuild is needed.
		_write_save({
			"version": 1,
			"game_state": {"gold": 12345.0, "depth": 5, "alive": true,
				"mode": 1, "run_number": 7},
			"prestige": {},
		})
		var ok: bool = _main.load_game()
		_check(ok, "v1 save loads (migrated, not rejected)")
		_check(int(GameState.gold) == 12345, "v1 gold restored", str(GameState.gold))
		_check(GameState.depth == 5, "v1 depth restored", str(GameState.depth))
		_check(GameState.run_number == 7, "v1 run_number restored")
		# Newer keys absent from v1 must default without errors (prestige blob).
		_check(Prestige != null, "prestige autoload intact post-migration")
		_phase = 1
		_frames = 0
		return
	if _phase == 1:
		if _frames < 5:
			return
		# Reject garbage versions.
		_write_save({"version": 0, "game_state": {}})
		_check(not _main.load_game(), "version 0 rejected")
		_write_save({"version": 99, "game_state": {}})
		_check(not _main.load_game(), "version 99 rejected")
		_phase = 2
		_frames = 0
		return
	if _phase == 2:
		if _frames < 5:
			return
		# Fresh v2 save round-trips through the real save path.
		GameState.gold = 777.0
		_main.save_game()
		GameState.gold = 0.0
		var ok2: bool = _main.load_game()
		_check(ok2, "v2 save reloads")
		_check(int(GameState.gold) == 777, "v2 gold round-trips", str(GameState.gold))
		if FileAccess.file_exists("user://savegame.dat"):
			DirAccess.remove_absolute("user://savegame.dat")
		if _failures == 0:
			print("SAVEMIGRATE: ALL PASS")
		else:
			printerr("SAVEMIGRATE: %d FAILURES" % _failures)
		get_tree().quit(1 if _failures > 0 else 0)
