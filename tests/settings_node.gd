extends Node
## Settings screen test.
## - Settings.load/save round-trips quality + cheat speed.
## - Quality apply toggles the viewport 3D scale.
## - HUD settings panel: sliders track AudioManager, cheat row hidden
##   until 7 title taps, speed selector sets GameState.speed_mult.
## Run: godot --headless --path . tests/settings_scene.tscn

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
	print("SETTINGS: starting")
	# Skip the floor-1 tutorial for this test (it pauses the tree).
	GameState.tutorial_done = true
	if FileAccess.file_exists("user://display.dat"):
		DirAccess.remove_absolute("user://display.dat")
	var packed: PackedScene = load("res://scenes/main.tscn")
	_main = packed.instantiate()
	get_tree().root.add_child.call_deferred(_main)


func _process(_delta: float) -> void:
	_frames += 1
	if _phase == 0:
		if _frames < 30 or not is_instance_valid(_main) or _main.get("hud") == null:
			return
		# Round-trip the settings file.
		Settings.quality = "low"
		Settings.cheat_speed = 4.0
		Settings.save_all()
		Settings.quality = "high"
		Settings.cheat_speed = 1.0
		Settings.load_all()
		_check(Settings.quality == "low", "quality round-trips")
		_check(Settings.cheat_speed == 4.0, "cheat speed round-trips")
		# Quality apply hits the viewport.
		Settings.apply_quality(get_viewport())
		_check(get_viewport().scaling_3d_scale < 1.0, "low quality lowers 3d scale")
		Settings.set_quality("high", get_viewport())
		_check(get_viewport().scaling_3d_scale == 1.0, "high quality restores scale")
		_check(Settings.quality == "high", "quality persisted via setter")
		# HUD panel wiring.
		var hud = _main.get("hud")
		_check(not hud.get("_settings_panel").visible, "panel hidden by default")
		_check(not hud.get("_cheat_row").visible, "cheat row hidden by default")
		_check(absf(hud.get("_music_slider").value - AudioManager.get_music_volume() * 100.0) < 0.01,
			"music slider tracks AudioManager")
		_check(absf(hud.get("_sfx_slider").value - AudioManager.get_sfx_volume() * 100.0) < 0.01,
			"sfx slider tracks AudioManager")
		# 7 taps reveal the dev corner; 6 do not.
		for i in 6:
			hud._register_title_tap()
		_check(not hud.get("_cheat_row").visible, "6 taps keep cheat row hidden")
		hud._register_title_tap()
		_check(hud.get("_cheat_row").visible, "7 taps reveal cheat row")
		hud._on_cheat_speed_selected(3)
		_check(GameState.speed_mult == 8.0, "cheat speed applies", str(GameState.speed_mult))
		if FileAccess.file_exists("user://display.dat"):
			DirAccess.remove_absolute("user://display.dat")
		# Restore defaults for other tests.
		Settings.quality = "high"
		Settings.cheat_speed = 1.0
		Settings.apply_quality(get_viewport())
		GameState.speed_mult = 1.0
		if _failures == 0:
			print("SETTINGS: ALL PASS")
		else:
			printerr("SETTINGS: %d FAILURES" % _failures)
		get_tree().quit(1 if _failures > 0 else 0)
