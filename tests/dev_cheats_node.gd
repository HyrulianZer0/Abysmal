extends Node
## Dev-corner cheats test (hidden Settings easter-egg tools).
## - DEV speed UI caps at 8x, but 16x still works when set from code,
##   and a saved 16x clamps the UI selection to 8x gracefully.
## - DEV god mode: persisted, default off; while on, enemy damage never
##   reduces player HP (GameState.damage_player is the single choke
##   point); while off, damage lands normally.
## - "Next floor: monster floor" button: arms a one-shot GameState flag;
##   the next generated floor is a horde floor and the flag clears.
##   The flag is in no save/settings payload (never persists).
## Run: godot --headless --path . tests/dev_cheats_scene.tscn

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
	print("DEV_CHEATS: starting")
	# Skip the floor-1 tutorial for this test (it pauses the tree).
	GameState.tutorial_done = true
	# Manual control: the idle brain must not descend or fight mid-checks.
	GameState.idle_mode = false
	if FileAccess.file_exists("user://display.dat"):
		DirAccess.remove_absolute("user://display.dat")
	if FileAccess.file_exists("user://savegame.dat"):
		DirAccess.remove_absolute("user://savegame.dat")
	# Pre-seed a saved 16x BEFORE boot: the HUD must clamp its selection
	# to 8x while the value itself still applies programmatically.
	Settings.cheat_speed = 16.0
	Settings.dev_god_mode = false
	var packed: PackedScene = load("res://scenes/main.tscn")
	_main = packed.instantiate()
	get_tree().root.add_child.call_deferred(_main)


func _process(_delta: float) -> void:
	_frames += 1
	if _phase != 0:
		return
	if _frames < 30 or not is_instance_valid(_main) or _main.get("hud") == null:
		return
	_phase = 1
	var hud = _main.get("hud")
	_speed_tests(hud)
	_god_mode_tests(hud)
	_monster_floor_tests(hud)
	_cleanup()
	if _failures == 0:
		print("DEV_CHEATS: ALL PASS")
	else:
		printerr("DEV_CHEATS: %d FAILURES" % _failures)
	get_tree().quit(1 if _failures > 0 else 0)


func _speed_tests(hud: Node) -> void:
	var btn: OptionButton = hud.get("_cheat_speed_btn")
	_check(btn.item_count == 4, "speed UI offers exactly 4 options", str(btn.item_count))
	var labels: Array[String] = []
	for i in btn.item_count:
		labels.append(btn.get_item_text(i))
	_check(labels == ["1x", "2x", "4x", "8x"], "speed UI caps at 8x (no 16x)", str(labels))
	# Boot applied the pre-seeded 16x programmatically...
	_check(GameState.speed_mult == 16.0, "16x applies when set from code", str(GameState.speed_mult))
	# ...while the UI selection clamped gracefully to 8x (index 3).
	_check(btn.selected == 3, "saved 16x clamps UI selection to 8x", str(btn.selected))
	_check(Settings.cheat_speed == 16.0, "stored cheat_speed left at 16 by the clamp",
		str(Settings.cheat_speed))
	# Picking from the menu can no longer reach 16x.
	hud._on_cheat_speed_selected(3)
	_check(Settings.cheat_speed == 8.0 and GameState.speed_mult == 8.0,
		"top UI option is 8x", str(GameState.speed_mult))
	hud._on_cheat_speed_selected(0)
	_check(GameState.speed_mult == 1.0, "UI 1x applies", str(GameState.speed_mult))
	# 16x round-trips through the settings file (load clamp ceiling is 16).
	Settings.cheat_speed = 16.0
	Settings.save_all()
	Settings.cheat_speed = 1.0
	Settings.load_all()
	_check(Settings.cheat_speed == 16.0, "cheat_speed 16 round-trips via display.dat",
		str(Settings.cheat_speed))


func _god_mode_tests(hud: Node) -> void:
	# Defaults + persistence.
	_check(Settings.dev_god_mode == false, "god mode defaults off")
	Settings.dev_god_mode = true
	Settings.save_all()
	Settings.dev_god_mode = false
	Settings.load_all()
	_check(Settings.dev_god_mode == true, "god mode persists via display.dat")
	# The dev-corner toggle tracks the flag.
	hud._on_settings_pressed()
	_check((hud.get("_god_mode_btn") as CheckButton).button_pressed,
		"god mode toggle shows ON in dev corner")
	hud.get("_settings_panel").visible = false
	# ON: a lethal hit changes nothing — direct choke point...
	_check(GameState.alive and GameState.hp > 0.0, "player alive for god-mode checks")
	var hp_on: float = GameState.hp
	var died: bool = GameState.damage_player(99999.0)
	_check(not died and GameState.hp == hp_on and GameState.alive,
		"god mode: lethal damage_player() leaves HP untouched",
		"hp %s -> %s" % [hp_on, GameState.hp])
	# ...and through the real enemy-strike path.
	var foes: Array = _main.get("enemies")
	if foes.size() > 0:
		_main._enemy_strike(foes[0])
		_check(GameState.hp == hp_on, "god mode: enemy strike leaves HP untouched",
			"hp %s -> %s" % [hp_on, GameState.hp])
	else:
		_check(false, "god mode: enemy strike check needs a live foe", "no enemies")
	# OFF: damage lands again, exactly (fresh build: no dodge, no reduction).
	Settings.dev_god_mode = false
	var hp_off: float = GameState.hp
	var died2: bool = GameState.damage_player(10.0)
	_check(not died2 and absf(GameState.hp - (hp_off - 10.0)) < 0.01,
		"god mode OFF: damage lands", "hp %s -> %s" % [hp_off, GameState.hp])
	# Toggling via the HUD handler persists the flag.
	hud._on_god_mode_toggled(true)
	_check(Settings.dev_god_mode == true, "HUD toggle turns god mode on")
	hud._on_god_mode_toggled(false)
	_check(Settings.dev_god_mode == false, "HUD toggle turns god mode off")


func _monster_floor_tests(hud: Node) -> void:
	_check(GameState.depth == 1, "test floor is depth 1", str(GameState.depth))
	_check(not GameState.dev_force_next_monster_floor, "monster-floor flag starts clear")
	_check(not hud.get("_cheat_row2").visible, "dev row 2 hidden by default")
	for i in 7:
		hud._register_title_tap()
	_check(hud.get("_cheat_row2").visible, "7 taps reveal dev row 2")
	# Arm via the real button handler.
	hud._on_dev_monster_floor_pressed()
	_check(GameState.dev_force_next_monster_floor, "button arms the one-shot flag")
	_check((_main.get("hud").get("_monster_floor_btn") as Button).text.contains("ARMED"),
		"button shows ARMED while flag set")
	# Next generated floor: horde, even at depth 1 (below the natural
	# min depth), with the horde headcount to prove the machinery ran.
	_main._new_depth()
	var gen: Dictionary = _main.get("gen")
	_check(bool(gen.get("monster_floor", false)), "next floor generates as monster floor")
	_check(not GameState.dev_force_next_monster_floor, "flag consumed at generation")
	var horde_count: int = (gen["enemies"] as Array).size()
	_check(horde_count >= 20, "horde headcount (x3 machinery)", str(horde_count))
	# The floor after that is back to normal at depth 1 (natural monster
	# floors are impossible below depth 2, so this is deterministic).
	_main._new_depth()
	var gen2: Dictionary = _main.get("gen")
	_check(not bool(gen2.get("monster_floor", false)), "following floor is normal again")
	_check((gen2["enemies"] as Array).size() <= 8, "normal headcount restored",
		str((gen2["enemies"] as Array).size()))
	# The flag lives in no persisted payload.
	_check(not GameState.to_dict().has("dev_force_next_monster_floor"),
		"flag absent from GameState save dict")


func _cleanup() -> void:
	Settings.dev_god_mode = false
	Settings.cheat_speed = 1.0
	Settings.hardcore = false
	Settings.save_all()
	GameState.speed_mult = 1.0
	GameState.dev_force_next_monster_floor = false
	if FileAccess.file_exists("user://display.dat"):
		DirAccess.remove_absolute("user://display.dat")
	if FileAccess.file_exists("user://savegame.dat"):
		DirAccess.remove_absolute("user://savegame.dat")
