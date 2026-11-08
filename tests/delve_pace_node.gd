extends Node
## Delve pace test: the depth walk multiplier is gentler (1x→2x), the
## Settings "Delve pace" knob (leisurely/normal/swift) scales presentation
## speed only, and — the load-bearing invariant — pace changes must NOT
## alter combat/economy outcomes. A seeded kill-loop at two paces must
## produce identical HP lost, gold, XP, and kills.
##
## Run: godot --headless --path . tests/delve_pace_scene.tscn
## Exits 0 on pass, 1 on any failure.

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
	if FileAccess.file_exists("user://savegame.dat"):
		DirAccess.remove_absolute("user://savegame.dat")
	_test_curve()
	_test_pace_map()
	await _test_pace_invariance()
	Settings.set_delve_pace("normal")
	GameState.depth = 1
	GameState.speed_mult = 1.0
	Engine.time_scale = 1.0
	if _failures == 0:
		print("DELVE PACE: ALL PASS")
	else:
		printerr("DELVE PACE: %d FAILURES" % _failures)
	get_tree().quit(_failures)


func _test_curve() -> void:
	# Gentler depth walk multiplier: 1x → 2x (was 1x → 3x).
	GameState.depth = 1
	_check(is_equal_approx(GameState.depth_walk_mult(), 1.0), "depth 1 walks at 1.0x")
	GameState.depth = 10
	_check(is_equal_approx(GameState.depth_walk_mult(), 1.36), "depth 10 walks at 1.36x",
		str(GameState.depth_walk_mult()))
	GameState.depth = 26
	_check(is_equal_approx(GameState.depth_walk_mult(), 2.0), "depth 26 hits the 2.0x cap")
	GameState.depth = 100
	_check(is_equal_approx(GameState.depth_walk_mult(), 2.0), "depth 100 stays at the 2.0x cap")
	GameState.depth = 1


func _test_pace_map() -> void:
	Settings.set_delve_pace("leisurely")
	_check(is_equal_approx(GameState.delve_pace_mult(), 0.7), "leisurely = 0.7x")
	Settings.set_delve_pace("normal")
	_check(is_equal_approx(GameState.delve_pace_mult(), 1.0), "normal = 1.0x")
	Settings.set_delve_pace("swift")
	_check(is_equal_approx(GameState.delve_pace_mult(), 1.3), "swift = 1.3x")
	Settings.set_delve_pace("bogus")
	_check(Settings.delve_pace == "normal", "bogus pace falls back to normal")
	Settings.set_delve_pace("normal")


## Seeded kill-loop at one pace setting. Returns the combat/economy
## outcome — HP lost, gold gained, XP gained, kills.
func _kill_loop(pace: String) -> Dictionary:
	Settings.set_delve_pace(pace)
	GameState.reset_run()
	GameState.max_hp = 999999.0
	GameState.hp = 999999.0
	# Hold the world's breath: the brain timer and enemy ticks stay parked
	# while the loop drives _player_attack directly (deterministic).
	_main.set("_shop_open", true)
	_main.rng.seed = 424242
	var foe = _main._spawn_enemy("slime", _main.player.grid_pos, false)
	foe.set_process(false)  # no frame-timing noise; direct retaliation still uses seeded rng
	var hp0 := GameState.hp
	var gold0 := GameState.run_gold
	var xp0 := GameState.xp
	var kills0 := GameState.run_kills
	var guard := 0
	# run_kills increments synchronously inside take_damage's died signal —
	# the one true kill flag (the foe node itself is freed by its death
	# tween, so never touch foe state after the killing blow).
	while GameState.run_kills == kills0 and guard < 40:
		if is_instance_valid(foe) and not foe.dead:
			_main._player_attack(foe)
		# Let the swing's deferred impact land (0.25s swing at 8x).
		for i in 12:
			await get_tree().process_frame
		guard += 1
	_check(GameState.run_kills > kills0, "pace %s: foe died in the loop" % pace)
	var out := {
		"hp_lost": hp0 - GameState.hp,
		"gold": GameState.run_gold - gold0,
		"xp": GameState.xp - xp0,
		"kills": GameState.run_kills - kills0,
	}
	if is_instance_valid(foe):
		foe.queue_free()
	_main.set("_shop_open", false)
	return out


func _test_pace_invariance() -> void:
	var packed: PackedScene = load("res://scenes/main.tscn")
	_main = packed.instantiate()
	get_tree().root.add_child.call_deferred(_main)
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	_main.set("debug_no_shop", true)
	GameState.idle_mode = true
	_main.start_delve()
	await get_tree().process_frame
	await get_tree().process_frame
	var slow := await _kill_loop("leisurely")
	var fast := await _kill_loop("swift")
	_check(slow["kills"] == fast["kills"], "kills identical across paces",
		"%s vs %s" % [str(slow["kills"]), str(fast["kills"])])
	_check(is_equal_approx(float(slow["hp_lost"]), float(fast["hp_lost"])),
		"HP lost identical across paces",
		"%s vs %s" % [str(slow["hp_lost"]), str(fast["hp_lost"])])
	_check(is_equal_approx(float(slow["gold"]), float(fast["gold"])),
		"gold gained identical across paces",
		"%s vs %s" % [str(slow["gold"]), str(fast["gold"])])
	_check(is_equal_approx(float(slow["xp"]), float(fast["xp"])),
		"XP gained identical across paces",
		"%s vs %s" % [str(slow["xp"]), str(fast["xp"])])
	_main.queue_free()
	_main = null
