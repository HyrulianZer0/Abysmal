extends Node
## Horde stress beta: EVERY floor is a forced monster floor. Runs idle at
## 8x for ~12 virtual minutes and measures whether the game can handle the
## "oh no" floor: frame time (avg/p95/max), peak enemy count, deaths, and
## how close the player gets to dying (survivability signal).
##
## Run: godot --headless --path . tests/horde_stress_scene.tscn
## Exits 0 on pass; prints FAIL and exits 1 on stall or engine-error signs.

var _frames := 0
var _virtual := 0.0
var _max_virtual := 720.0  # 12 virtual minutes
var _main: Node = null
var _frame_us := PackedFloat32Array()
var _last_tick := 0
var _peak_enemies := 0
var _horde_floors := 0
var _horde_clears := 0
var _deaths := 0
var _min_hp_frac := 1.0
var _last_depth := 1
var _last_progress := 0.0
var _was_alive := true
var _last_target := ""
var _failures := 0


func _ready() -> void:
	Engine.time_scale = 8.0
	# Fresh boot: a stale town/hub save would load instead of the dungeon.
	if FileAccess.file_exists("user://savegame.dat"):
		DirAccess.remove_absolute("user://savegame.dat")
	var packed: PackedScene = load("res://scenes/main.tscn")
	var main = packed.instantiate()
	main.set("debug_force_monster_floor", true)
	_main = main
	get_tree().root.add_child.call_deferred(main)
	_last_tick = Time.get_ticks_usec()
	print("HORDE: forced monster floors, time_scale=8, budget=12 virtual min")


func _process(delta: float) -> void:
	_frames += 1
	_virtual += delta
	# Frame-time sample (headless proxy for perf under horde load).
	var now := Time.get_ticks_usec()
	_frame_us.append(float(now - _last_tick))
	_last_tick = now

	var gs = GameState

	# Floor-clear shop pauses the delve by design; the soak taps through it
	# via the real HUD close path.
	if _main != null and bool(_main.get("_shop_open")):
		(_main.get("hud") as Node).hide_shop()
	if gs.depth != _last_depth:
		_last_depth = gs.depth
		_last_progress = _virtual
		if _main != null and is_instance_valid(_main):
			var gen: Dictionary = _main.get("gen")
			if bool(gen.get("monster_floor", false)):
				_horde_floors += 1
				print("HORDE floor #%d at depth %d (%d enemies)" % [
					_horde_floors, gs.depth, (_main.get("enemies") as Array).size()])
		else:
			_horde_floors += 1

	if not gs.alive and _was_alive:
		_was_alive = false
		_deaths += 1
		_last_progress = _virtual
		print("HORDE frame %d: DEATH #%d on horde floor depth %d (kills=%d)" % [
			_frames, _deaths, gs.depth, gs.kills])
		_restart_naked()
	elif gs.alive and not _was_alive:
		_was_alive = true
	elif gs.alive:
		_min_hp_frac = minf(_min_hp_frac, gs.hp / maxf(gs.max_hp, 1.0))

	if _main != null and is_instance_valid(_main):
		var living := 0
		for e in (_main.get("enemies") as Array):
			if is_instance_valid(e) and not e.dead:
				living += 1
		_peak_enemies = maxi(_peak_enemies, living)
		# A cleared horde: the brain targets stairs only when the floor
		# is picked clean — count the transition, not the frames.
		var target := str(_main.get("debug_last_target"))
		if target == "stairs" and _last_target != "stairs":
			_horde_clears += 1
		_last_target = target

	# Stall check: no depth change and no death for 6 virtual minutes.
	if _virtual - _last_progress > 360.0:
		_failures += 1
		printerr("HORDE FAIL: stall — no progress for 6 virtual min at depth %d" % gs.depth)
		_finish()
		return

	if _virtual >= _max_virtual:
		_finish()


## Quick respawn without heirloom picks (the heirloom path is covered by
## the autoplay beta; here we just want the next horde floor fast).
func _restart_naked() -> void:
	var hud = _main.get("hud")
	hud.death_test_pick({}, {})
	hud.death_test_confirm()
	# Phase 3: the dead run ends in town — delve again for the next horde.
	_main.start_delve()


func _finish() -> void:
	Engine.time_scale = 1.0
	var sorted := _frame_us.duplicate()
	sorted.sort()
	var avg := 0.0
	for s in _frame_us:
		avg += s
	avg /= maxf(float(_frame_us.size()), 1.0)
	var p95 := sorted[int(float(sorted.size()) * 0.95)] if not sorted.is_empty() else 0.0
	var mx := sorted[sorted.size() - 1] if not sorted.is_empty() else 0.0
	print("HORDE: DONE virtual=%.0fs frames=%d" % [_virtual, _frames])
	print("HORDE: frame ms avg=%.2f p95=%.2f max=%.2f (headless proxy)" % [
		avg / 1000.0, p95 / 1000.0, mx / 1000.0])
	print("HORDE: peak_enemies=%d horde_floors=%d clears=%d deaths=%d kills=%d min_hp_frac=%.2f" % [
		_peak_enemies, _horde_floors, _horde_clears, _deaths, GameState.kills, _min_hp_frac])
	if _deaths > 0 and _horde_clears == 0:
		_failures += 1
		printerr("HORDE FAIL: died %d times without clearing a single horde floor" % _deaths)
	if _failures == 0:
		print("HORDE: PASS")
	else:
		printerr("HORDE: %d FAILURES" % _failures)
	get_tree().quit(_failures)
