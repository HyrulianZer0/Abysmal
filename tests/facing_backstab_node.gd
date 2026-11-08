extends Node
## Enemy facing + backstab test.
## - Spawned enemies face the player; moving updates facing to travel dir.
## - Backstab rule: atk_dir == enemy.facing (strike from the blind spot),
##   or the target is asleep.
## - Facing round-trips through save/load.
## Run: godot --headless --path . tests/facing_backstab_scene.tscn

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
	print("FACEBACK: starting")
	if FileAccess.file_exists("user://savegame.dat"):
		DirAccess.remove_absolute("user://savegame.dat")
	var packed: PackedScene = load("res://scenes/main.tscn")
	_main = packed.instantiate()
	get_tree().root.add_child.call_deferred(_main)


func _backstab(atk_dir: Vector2i, foe) -> bool:
	# Mirror of the rule in main._player_attack.
	return bool(foe.asleep) \
		or (foe.facing != Vector2i.ZERO and atk_dir == foe.facing)


func _process(_delta: float) -> void:
	_frames += 1
	if _phase == 0:
		if _frames < 30 or not is_instance_valid(_main) or _main.get("player") == null:
			return
		var player = _main.get("player")
		var pp: Vector2i = player.grid_pos
		# Spawn a foe east of the player: it should face west (toward player).
		var foe = _main._spawn_enemy("slime", pp + Vector2i(2, 0), false)
		_check(foe.facing == Vector2i(-1, 0), "spawn faces player", str(foe.facing))
		# Backstab geometry: player west of foe, foe facing west = head-on, no bonus.
		var atk_dir: Vector2i = foe.grid_pos - pp  # (2,0)... unit: (1,0)
		atk_dir = Vector2i(signi(atk_dir.x), signi(atk_dir.y))
		_check(not _backstab(atk_dir, foe), "head-on is not backstab")
		# Turn the foe around (facing east, away): same attack is now a backstab.
		foe.facing = Vector2i(1, 0)
		_check(_backstab(atk_dir, foe), "attack from blind spot is backstab")
		# Sleepers are always backstabbable (sneaking up).
		foe.facing = Vector2i(-1, 0)
		foe.asleep = true
		_check(_backstab(atk_dir, foe), "sleeper is backstab")
		_check(float(_main.BACKSTAB_MULT) == 1.5, "backstab mult is 1.5")
		_phase = 1
		_frames = 0
		return
	if _phase == 1:
		if _frames < 5:
			return
		# Facing round-trips through save/load.
		_main.save_game()
		var foes: Array = _main.get("enemies")
		var f0 = null
		for e in foes:
			if is_instance_valid(e):
				f0 = e
				break
		if f0 != null:
			f0.facing = Vector2i(0, -1)
			_main.save_game()
			_main.load_game()
			var foes2: Array = _main.get("enemies")
			var found := false
			for e2 in foes2:
				if is_instance_valid(e2) and e2.facing == Vector2i(0, -1):
					found = true
			_check(found, "facing survives save/load")
		else:
			_check(false, "facing survives save/load", "no foes")
		if FileAccess.file_exists("user://savegame.dat"):
			DirAccess.remove_absolute("user://savegame.dat")
		if _failures == 0:
			print("FACEBACK: ALL PASS")
		else:
			printerr("FACEBACK: %d FAILURES" % _failures)
		get_tree().quit(1 if _failures > 0 else 0)
