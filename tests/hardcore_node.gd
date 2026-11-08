extends Node
## Hardcore toggle test.
## - The flag defaults off and round-trips through display.dat.
## - hunger_step: +2%/run normally, +5%/run in hardcore; the +50% cap
##   never moves either way.
## - Death forfeits ALL carried gold only when hardcore is on; forgiving
##   behavior is unchanged when off.
## - The toggle lives in the 7-tap dev corner (never advertised), hidden
##   by default, and persists via the HUD wiring.
## Run: godot --headless --path . tests/hardcore_scene.tscn

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
	print("HARDCORE: starting")
	if FileAccess.file_exists("user://display.dat"):
		DirAccess.remove_absolute("user://display.dat")
	if FileAccess.file_exists("user://savegame.dat"):
		DirAccess.remove_absolute("user://savegame.dat")
	Settings.load_all()
	_phase = 0
	_frames = 0


func _process(_delta: float) -> void:
	_frames += 1
	if _phase == 0:
		_settings_tests()
		_ramp_tests()
		var packed: PackedScene = load("res://scenes/main.tscn")
		_main = packed.instantiate()
		get_tree().root.add_child.call_deferred(_main)
		_phase = 1
		_frames = 0
		return
	if _phase == 1:
		if _frames < 30 or not is_instance_valid(_main) or not _main.is_inside_tree():
			return
		_death_tests()
		_hud_tests()
		# Restore defaults for other suites.
		Settings.hardcore = false
		Settings.save_all()
		if FileAccess.file_exists("user://display.dat"):
			DirAccess.remove_absolute("user://display.dat")
		if FileAccess.file_exists("user://savegame.dat"):
			DirAccess.remove_absolute("user://savegame.dat")
		if _failures == 0:
			print("HARDCORE: ALL PASS")
		else:
			printerr("HARDCORE: %d FAILURES" % _failures)
		get_tree().quit(1 if _failures > 0 else 0)


func _settings_tests() -> void:
	_check(not Settings.hardcore, "hardcore defaults off")
	Settings.hardcore = true
	Settings.save_all()
	Settings.hardcore = false
	Settings.load_all()
	_check(Settings.hardcore, "hardcore round-trips through display.dat")
	Settings.hardcore = false
	Settings.save_all()


func _ramp_tests() -> void:
	var saved_run := GameState.run_number
	Settings.hardcore = false
	_check(absf(GameState.hunger_step() - 0.02) < 0.0001, "normal ramp +2%/run")
	GameState.run_number = 6
	_check(absf(GameState.hunger_mult() - 1.10) < 0.0001, "normal ramp: run 6 -> x1.10",
		str(GameState.hunger_mult()))
	Settings.hardcore = true
	_check(absf(GameState.hunger_step() - 0.05) < 0.0001, "hardcore ramp +5%/run")
	_check(absf(GameState.hunger_mult() - 1.25) < 0.0001, "hardcore ramp: run 6 -> x1.25",
		str(GameState.hunger_mult()))
	# The +50% cap never moves: hardcore hits it at run 11, normal at 26.
	GameState.run_number = 11
	_check(absf(GameState.hunger_mult() - 1.5) < 0.0001, "hardcore caps at +50%",
		str(GameState.hunger_mult()))
	Settings.hardcore = false
	GameState.run_number = 26
	_check(absf(GameState.hunger_mult() - 1.5) < 0.0001, "normal caps at +50%",
		str(GameState.hunger_mult()))
	GameState.run_number = 1
	_check(absf(GameState.hunger_mult() - 1.0) < 0.0001, "run 1 has no ramp")
	GameState.run_number = saved_run
	Settings.hardcore = false


func _death_tests() -> void:
	var hud = _main.get("hud")
	# Hardcore ON: death forfeits ALL carried gold.
	Settings.hardcore = true
	GameState.alive = true
	GameState.gold = 5000.0
	GameState.run_gold = 1234.0
	_main._on_player_death("test dummy")
	_check(GameState.gold == 0.0, "hardcore death forfeits carried gold", str(GameState.gold))
	_check(GameState.run_gold == 0.0, "hardcore death zeroes run gold", str(GameState.run_gold))
	_check(hud.get("_death_panel").visible, "death panel still opens in hardcore")
	hud.hide_death()
	# Hardcore OFF: forgiving behavior unchanged — gold survives death.
	Settings.hardcore = false
	GameState.alive = true
	GameState.gold = 5000.0
	GameState.run_gold = 1234.0
	_main._on_player_death("test dummy")
	_check(absf(GameState.gold - 5000.0) < 0.001, "normal death keeps carried gold",
		str(GameState.gold))
	_check(absf(GameState.run_gold - 1234.0) < 0.001, "normal death keeps run gold",
		str(GameState.run_gold))
	hud.hide_death()
	Settings.hardcore = false


func _hud_tests() -> void:
	var hud = _main.get("hud")
	_check(not hud.get("_cheat_row").visible, "cheat row hidden by default")
	_check(hud.get("_hardcore_btn") != null, "hardcore toggle exists in dev corner")
	_check(not hud.get("_hardcore_btn").button_pressed, "hardcore toggle defaults off")
	for i in 7:
		hud._register_title_tap()
	_check(hud.get("_cheat_row").visible, "7 taps reveal dev corner")
	# Flipping the toggle persists the flag (button_pressed emits toggled).
	hud.get("_hardcore_btn").button_pressed = true
	_check(Settings.hardcore, "toggle flips Settings.hardcore on")
	Settings.load_all()
	_check(Settings.hardcore, "toggled hardcore persists across load")
	hud.get("_hardcore_btn").button_pressed = false
	_check(not Settings.hardcore, "toggle flips Settings.hardcore off")
