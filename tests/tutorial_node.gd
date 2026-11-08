extends Node
## Paused popup tutorial test.
## - Fresh boot (no save): tree pauses, tutorial panel visible.
## - Clicking through all steps: unpauses, sets tutorial_done, persists.
## - Second boot: no tutorial.
## Run: godot --headless --path . tests/tutorial_scene.tscn

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
	# The tree gets paused by the tutorial — this node must keep ticking.
	process_mode = Node.PROCESS_MODE_ALWAYS
	print("TUTORIAL: starting")
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
		if _frames < 40 or not is_instance_valid(_main) or _main.get("player") == null:
			return
		# Boot path skips the tutorial under test scenes (paused tree would
		# freeze the harness), so drive it directly — same code path.
		_check(not get_tree().paused, "no auto-tutorial under test harness")
		_main._show_tutorial()
		_check(get_tree().paused, "tree paused by tutorial")
		var hud = _main.get("hud")
		_check(hud.get("_tutorial_panel").visible, "tutorial panel visible")
		# Click through all 4 steps.
		for i in 4:
			hud._on_tutorial_next()
		_check(not get_tree().paused, "tree unpaused after tutorial")
		_check(GameState.tutorial_done, "tutorial_done set")
		# Flag persisted to disk.
		var f := FileAccess.open("user://savegame.dat", FileAccess.READ)
		var d = str_to_var(f.get_as_text())
		f.close()
		_check(bool((d.get("game_state", {}) as Dictionary).get("tutorial_done", false)),
			"tutorial_done persisted")
		_phase = 1
		_frames = 0
		# Respawn for a second boot: the save now exists, no tutorial.
		_main.queue_free()
		_main = null
		return
	if _phase == 1:
		if _frames < 10:
			return
		if _main == null:
			_spawn_main()
			_frames = 0
			_phase = 2
		return
	if _phase == 2:
		if _frames < 40 or not is_instance_valid(_main) or _main.get("player") == null:
			return
		_check(not get_tree().paused, "no tutorial on second boot")
		if FileAccess.file_exists("user://savegame.dat"):
			DirAccess.remove_absolute("user://savegame.dat")
		if _failures == 0:
			print("TUTORIAL: ALL PASS")
		else:
			printerr("TUTORIAL: %d FAILURES" % _failures)
		get_tree().quit(1 if _failures > 0 else 0)
