extends Node
## Phase 3 validation: town/overworld state-machine scaffolding.
## Boots the real main scene headless and drives every transition:
##   dungeon -> town -> dungeon (via the death-screen restart path),
##   town -> overworld -> town (via the UI buttons),
## illegal moves rejected, save/load round-trips from each state,
## boot routing honors the saved mode, dungeon flow intact throughout.
## Run: godot --headless --path . tests/town_overworld_scene.tscn -- --seed=12345
## Exits 0 on success, 1 on any failure.

var _main: Node = null
var _phase := 0
var _frames := 0
var _failures := 0
var _run0 := 0
var _snap := {}


func _check(cond: bool, name: String, detail: String = "") -> void:
	if cond:
		print("  PASS  %s" % name)
	else:
		_failures += 1
		printerr("  FAIL  %s  %s" % [name, detail])


func _ready() -> void:
	print("TOWN_OVERWORLD: starting")
	if FileAccess.file_exists("user://savegame.dat"):
		DirAccess.remove_absolute("user://savegame.dat")
	_spawn_main()


func _spawn_main() -> void:
	var packed: PackedScene = load("res://scenes/main.tscn")
	_main = packed.instantiate()
	get_tree().root.add_child.call_deferred(_main)


func _process(_delta: float) -> void:
	_frames += 1
	match _phase:
		0:
			_phase_boot()
		1:
			_phase_town()
		2:
			_phase_delve()
		3:
			_phase_overworld()
		4:
			_phase_back_to_town()
		5:
			_phase_reboot()
		6:
			_phase_delve_after_boot()


# --- phase 0: fresh boot lands in the dungeon; force death -> restart ------

func _phase_boot() -> void:
	if _frames < 30 or not is_instance_valid(_main) \
			or not _main.is_inside_tree() or _main.get("player") == null:
		return
	print("== boot: fresh -> dungeon (default path) ==")
	_check(GameState.mode == GameMode.State.DUNGEON, "boot mode is DUNGEON")
	_check(_main.get("town_view") == null, "no town view at boot")
	_check(_main.get("overworld_view") == null, "no overworld view at boot")
	_check(GameState.alive, "player alive at boot")
	_check((_main.get("enemies") as Array).size() > 0, "dungeon floor generated")
	_check((_main.get("view") as Node).visible, "dungeon view visible")
	# Freeze the world: manual mode + no input = deterministic test bed.
	GameState.idle_mode = false
	_check_transition_matrix()
	# Illegal move: dungeon -> overworld directly must be rejected.
	_check(not GameState.set_mode(GameMode.State.OVERWORLD),
		"dungeon -> overworld rejected")
	_check(GameState.mode == GameMode.State.DUNGEON, "mode unchanged after illegal move")
	_run0 = GameState.run_number
	# The real death path: lethal damage, then the game's own handler.
	GameState.damage_player(1.0e9)
	_main._on_player_death("Test Slime")
	_check(not GameState.alive, "player dead after lethal damage")
	_main.request_restart()
	_phase = 1
	_frames = 0


func _check_transition_matrix() -> void:
	print("== GameMode transition matrix ==")
	var D := GameMode.State.DUNGEON
	var T := GameMode.State.TOWN
	var O := GameMode.State.OVERWORLD
	_check(GameMode.can_transition(D, D), "D->D ok")
	_check(GameMode.can_transition(D, T), "D->T ok (run end)")
	_check(not GameMode.can_transition(D, O), "D->O illegal")
	_check(GameMode.can_transition(T, T), "T->T ok")
	_check(GameMode.can_transition(T, D), "T->D ok (delve)")
	_check(GameMode.can_transition(T, O), "T->O ok (travel)")
	_check(GameMode.can_transition(O, O), "O->O ok")
	_check(GameMode.can_transition(O, T), "O->T ok (return)")
	_check(not GameMode.can_transition(O, D), "O->D illegal")
	_check(GameMode.state_name(D) == "DUNGEON", "state_name DUNGEON")
	_check(GameMode.state_name(T) == "TOWN", "state_name TOWN")
	_check(GameMode.state_name(O) == "OVERWORLD", "state_name OVERWORLD")
	_check(OverworldView.OVERWORLD_MAP_SIZE == 0,
		"overworld map size explicitly undecided (0)")


# --- phase 1: death -> restart lands in town --------------------------------

func _phase_town() -> void:
	if _frames < 5:
		return
	print("== dungeon -> town (death-screen restart) ==")
	_check(GameState.mode == GameMode.State.TOWN, "mode is TOWN after restart")
	_check(GameState.run_number == _run0 + 1, "run counter ticked over")
	_check(GameState.alive, "fresh run is alive in town")
	_check(is_instance_valid(_main.get("town_view")), "town view built")
	var tv = _main.get("town_view")
	_check(tv.delve_button != null and tv.overworld_button != null,
		"town UI buttons exist")
	_check(str(tv.info_label.text).contains("Run #%d" % GameState.run_number),
		"town info label shows run number")
	_check(not (_main.get("view") as Node).visible, "dungeon view parked (hidden)")
	_check(not (_main.get("hud") as Node).visible, "hud parked (hidden)")
	_check((_main.get("enemies") as Array).is_empty(), "dead run's foes cleared")
	_check(get_viewport().get_camera_3d() == tv.get("_camera"),
		"town camera is current")
	# Hub save written on entry: mode + meta, no floor keys.
	_check(FileAccess.file_exists("user://savegame.dat"), "hub save written on town entry")
	# Drive the UI itself: press Delve like a player would.
	tv.delve_button.pressed.emit()
	_phase = 2
	_frames = 0


# --- phase 2: town -> dungeon via the Delve button --------------------------

func _phase_delve() -> void:
	if _frames < 5:
		return
	print("== town -> dungeon (delve button) ==")
	_check(GameState.mode == GameMode.State.DUNGEON, "mode back to DUNGEON")
	_check(_main.get("town_view") == null, "town view freed")
	_check((_main.get("enemies") as Array).size() > 0, "fresh floor generated on delve")
	_check((_main.get("view") as Node).visible, "dungeon view visible again")
	_check(get_viewport().get_camera_3d() == (_main.get("player") as Node).camera,
		"player camera current again")
	GameState.idle_mode = false
	_save_load_roundtrip_dungeon()
	# Smoke branch: with _smoke on, restart must auto-delve straight
	# through town (enter_town -> start_delve) instead of parking there.
	_main.set("_smoke", true)
	GameState.damage_player(1.0e9)
	_main._on_player_death("Test Slime 2")
	_main.request_restart()
	_check(GameState.mode == GameMode.State.DUNGEON, "smoke auto-delve returns to DUNGEON")
	_check((_main.get("enemies") as Array).size() > 0, "smoke auto-delve generated a floor")
	_check(_main.get("town_view") == null, "smoke auto-delve left no town view")
	_main.set("_smoke", false)
	GameState.idle_mode = false
	# Third death, real path again — town must be re-enterable.
	GameState.damage_player(1.0e9)
	_main._on_player_death("Test Slime 3")
	_main.request_restart()
	_phase = 3
	_frames = 0


func _save_load_roundtrip_dungeon() -> void:
	print("== save/load round-trip from DUNGEON ==")
	var p = _main.get("player")
	_snap = {
		"depth": GameState.depth, "pos": p.grid_pos,
		"hp": GameState.hp, "gold": GameState.gold,
		"foes": (_main.get("enemies") as Array).size(),
	}
	_main.save_game()
	# Tamper, then load must restore.
	GameState.depth = 99
	GameState.hp = 1.0
	GameState.gold = 0.0
	_check(_main.load_game(), "load_game returns true in dungeon")
	_check(GameState.mode == GameMode.State.DUNGEON, "mode still DUNGEON after load")
	_check(GameState.depth == int(_snap["depth"]), "depth restored")
	_check(p.grid_pos == _snap["pos"], "player pos restored")
	_check(is_equal_approx(GameState.hp, float(_snap["hp"])), "hp restored")
	_check(is_equal_approx(GameState.gold, float(_snap["gold"])), "gold restored")
	_check((_main.get("enemies") as Array).size() == int(_snap["foes"]),
		"enemy count restored")


# --- phase 3: town -> overworld stub via the Travel button ------------------

func _phase_overworld() -> void:
	if _frames < 5:
		return
	print("== town -> overworld (travel button) ==")
	_check(GameState.mode == GameMode.State.TOWN, "back in TOWN after 3rd death")
	var tv = _main.get("town_view")
	tv.overworld_button.pressed.emit()
	_check(GameState.mode == GameMode.State.OVERWORLD, "mode is OVERWORLD")
	_check(_main.get("town_view") == null, "town view freed on travel")
	_check(is_instance_valid(_main.get("overworld_view")), "overworld stub built")
	var ov = _main.get("overworld_view")
	_check(ov.return_button != null, "overworld return button exists")
	_check(not GameMode.can_transition(
		GameMode.State.OVERWORLD, GameMode.State.DUNGEON),
		"overworld -> dungeon illegal (must route via town)")
	_save_load_roundtrip_hub(GameMode.State.OVERWORLD)
	# Drive the UI back: Return to town.
	ov.return_button.pressed.emit()
	_phase = 4
	_frames = 0


func _save_load_roundtrip_hub(expect_mode: int) -> void:
	var label := GameMode.state_name(expect_mode)
	print("== save/load round-trip from %s ==" % label)
	GameState.gold = 1234.5
	var run := GameState.run_number
	_main.save_game()
	# Tamper, then load must restore mode + meta (no floor involved).
	GameState.gold = 0.0
	GameState.run_number = 777
	GameState.mode = GameMode.State.DUNGEON  # direct poke: from_dict must fix
	_check(_main.load_game(), "load_game returns true in %s" % label)
	_check(GameState.mode == expect_mode, "mode restored to %s" % label)
	_check(is_equal_approx(GameState.gold, 1234.5), "gold restored in %s" % label)
	_check(GameState.run_number == run, "run_number restored in %s" % label)


# --- phase 4: overworld -> town; boot-routing test --------------------------

func _phase_back_to_town() -> void:
	if _frames < 5:
		return
	print("== overworld -> town (return button) ==")
	_check(GameState.mode == GameMode.State.TOWN, "mode back to TOWN")
	_check(_main.get("overworld_view") == null, "overworld stub freed")
	_check(is_instance_valid(_main.get("town_view")), "town view rebuilt")
	# Illegal move from town: garbage state id rejected, mode kept.
	_check(not GameState.set_mode(999), "set_mode(999) rejected")
	_check(GameState.mode == GameMode.State.TOWN, "mode unchanged after garbage move")
	_save_load_roundtrip_hub(GameMode.State.TOWN)
	# Boot routing: save in town, kill the scene, boot fresh — the hub
	# save must land back in town, not the dungeon.
	_main.save_game()
	_main.queue_free()
	_main = null
	_phase = 5
	_frames = 0


# --- phase 5: reboot honors the hub save ------------------------------------

func _phase_reboot() -> void:
	if _frames == 10:
		_spawn_main()
		return
	if _frames < 40 or not is_instance_valid(_main) \
			or not _main.is_inside_tree() or _main.get("player") == null:
		return
	print("== boot routing: hub save -> town ==")
	_check(GameState.mode == GameMode.State.TOWN, "boot honored TOWN save")
	_check(is_instance_valid(_main.get("town_view")), "town view built at boot")
	_check(GameState.alive, "alive after hub boot")
	_check((_main.get("enemies") as Array).is_empty(), "no stale foes after hub boot")
	_check(not (_main.get("view") as Node).visible, "dungeon parked after hub boot")
	var tv = _main.get("town_view")
	tv.delve_button.pressed.emit()
	_phase = 6
	_frames = 0


# --- phase 6: delve works after a hub boot ----------------------------------

func _phase_delve_after_boot() -> void:
	if _frames < 5:
		return
	print("== delve after hub boot ==")
	_check(GameState.mode == GameMode.State.DUNGEON, "delve works after hub boot")
	_check((_main.get("enemies") as Array).size() > 0, "floor generated after hub boot")
	_check(get_viewport().get_camera_3d() == (_main.get("player") as Node).camera,
		"player camera current after hub boot")
	_finish()


func _finish() -> void:
	# Leave no save behind: hub saves would pollute other suites that
	# assume a fresh/dungeon boot (e.g. death_sort).
	if FileAccess.file_exists("user://savegame.dat"):
		DirAccess.remove_absolute("user://savegame.dat")
	if _failures == 0:
		print("TOWN_OVERWORLD: ALL PASS")
	else:
		printerr("TOWN_OVERWORLD: %d FAILURES" % _failures)
	get_tree().quit(1 if _failures > 0 else 0)
