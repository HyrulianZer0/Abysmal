extends Node
## Limp-fix validation: symmetric walk bob, gapless chained steps, no
## camera-Y pops, exactly-once stride callbacks.
## Run: godot --headless --path . tests/limp_fix_scene.tscn
const PlayerScript := preload("res://scripts/player.gd")
const EYE := 1.55
const BOB := 0.055

var _failures := 0
var _player: Node = null
var _done_count := 0  # member var: lambdas capture locals by value, members by ref


func _check(cond: bool, name: String, detail: String = "") -> void:
	if cond:
		print("  PASS  %s" % name)
	else:
		_failures += 1
		printerr("  FAIL  %s  %s" % [name, detail])


func _ready() -> void:
	_player = PlayerScript.new()
	get_tree().root.add_child.call_deferred(_player)
	_player.place_at(Vector2i(20, 20), 0)
	await get_tree().process_frame
	await get_tree().process_frame
	await _test_bob_symmetry()
	await _test_chained_no_gaps()
	await _test_no_camera_pops()
	_finish()


func _test_bob_symmetry() -> void:
	# One 1.0s stride: the dip bottom must land at ~0.5s (symmetric halves),
	# the dip must still exist (bob not removed), and y must return to eye.
	var stride := 1.0
	var samples: Array = []
	_player.move_step(Vector2i(1, 0), Callable(), stride)
	var t := 0.0
	while t < stride + 0.3:
		await get_tree().process_frame
		t += get_process_delta_time()
		samples.append([t, _player.camera.position.y])
	var t_min := -1.0
	var y_min := 999.0
	for s in samples:
		if s[1] < y_min:
			y_min = s[1]
			t_min = s[0]
	_check(absf(t_min - stride * 0.5) <= 0.08, "bob dip centered",
		"t_min=%.3f stride=%.2f" % [t_min, stride])
	_check(absf(y_min - (EYE - BOB)) <= 0.006, "bob dip depth kept",
		"y_min=%.4f" % y_min)
	var y_end: float = samples[samples.size() - 1][1]
	_check(absf(y_end - EYE) <= 0.004, "bob returns to eye height",
		"y_end=%.4f" % y_end)


func _test_chained_no_gaps() -> void:
	# Brain cadence: attempt a step every `stride` seconds of wall time.
	# Every attempt must be accepted (no 1-frame-late busy rejects) and
	# every stride callback must fire exactly once.
	var stride := 0.2
	var attempts := 0
	var accepted := 0
	_done_count = 0
	var acc := 0.0
	var dirs := [Vector2i(1, 0), Vector2i(0, 1), Vector2i(-1, 0), Vector2i(0, -1)]
	while accepted < 8:
		await get_tree().process_frame
		acc += get_process_delta_time()
		if acc >= stride:
			acc = 0.0
			attempts += 1
			var before: Vector2i = _player.grid_pos
			_player.move_step(dirs[accepted % 4], _on_stride_done, stride)
			if _player.grid_pos != before:
				accepted += 1
	_check(accepted == attempts, "chained steps: no gaps",
		"accepted=%d attempts=%d" % [accepted, attempts])
	# Let the last stride's callback land.
	var t := 0.0
	while _done_count < accepted and t < 2.0:
		await get_tree().process_frame
		t += get_process_delta_time()
	_check(_done_count == accepted, "stride callbacks exactly once",
		"done=%d accepted=%d" % [_done_count, accepted])


func _test_no_camera_pops() -> void:
	# A: chained steps — per-frame camera Y deltas stay small.
	var max_d := 0.0
	var prev_y: float = _player.camera.position.y
	_player.move_step(Vector2i(1, 0), Callable(), 0.3)
	for i in 6:
		await get_tree().process_frame
		var y: float = _player.camera.position.y
		max_d = maxf(max_d, absf(y - prev_y))
		prev_y = y
		_player.move_step(Vector2i(1, 0), Callable(), 0.3)
	_check(max_d < 0.05, "chained steps: no camera pops", "max_d=%.4f" % max_d)
	# B: teleport mid-dip must ease back, not snap. Immediately after
	# place_at the camera must still be mid-dip (old code snapped to eye).
	_player.move_step(Vector2i(1, 0), Callable(), 1.0)
	var t := 0.0
	while _player.camera.position.y > EYE - BOB * 0.5 and t < 1.0:
		await get_tree().process_frame
		t += get_process_delta_time()
	var dip_y: float = _player.camera.position.y
	_player.place_at(Vector2i(30, 30), 0)
	var y_now: float = _player.camera.position.y
	_check(y_now < EYE - 0.01, "teleport mid-dip: no snap",
		"y_now=%.4f dip_y=%.4f" % [y_now, dip_y])
	t = 0.0
	while t < 0.5:
		await get_tree().process_frame
		t += get_process_delta_time()
	_check(absf(_player.camera.position.y - EYE) <= 0.004, "teleport: camera relevels",
		"y=%.4f" % _player.camera.position.y)


func _on_stride_done() -> void:
	_done_count += 1


func _finish() -> void:
	if _failures == 0:
		print("LIMPFIX: ALL PASS")
	else:
		printerr("LIMPFIX: %d FAILURES" % _failures)
	get_tree().quit(1 if _failures > 0 else 0)
