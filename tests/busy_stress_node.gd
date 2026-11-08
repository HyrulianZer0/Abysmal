extends Node
const PlayerScript := preload("res://scripts/player.gd")
var _failures := 0
var _player: Node = null
var _steps := 0
var _done := false
var _scale := 16.0

func _ready() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--s="):
			_scale = float(a.trim_prefix("--s="))
	Engine.time_scale = _scale
	_player = PlayerScript.new()
	get_tree().root.add_child.call_deferred(_player)
	_player.place_at(Vector2i(20, 20), 0)
	await get_tree().process_frame
	await get_tree().process_frame
	_issue_step()

func _issue_step() -> void:
	if _done:
		return
	if _steps >= 50:
		_finish()
		return
	if _player.busy:
		await get_tree().process_frame
		_issue_step()
		return
	_steps += 1
	var dir: Vector2i = [Vector2i(1, 0), Vector2i(0, 1), Vector2i(-1, 0), Vector2i(0, -1)][_steps % 4]
	_player.move_step(dir)
	var t := 0.0
	while _player.busy and t < 2.0:
		await get_tree().process_frame
		t += get_process_delta_time()
	if _player.busy:
		_failures += 1
		printerr("  FAIL busy stuck after step %d at scale %s" % [_steps, str(_scale)])
		_finish()
		return
	_issue_step()

func _finish() -> void:
	_done = true
	Engine.time_scale = 1.0
	if _failures == 0:
		print("BUSYSTRESS scale=%s: ALL PASS (%d steps)" % [str(_scale), _steps])
	else:
		printerr("BUSYSTRESS scale=%s: %d FAILURES" % [str(_scale), _failures])
	get_tree().quit(1 if _failures > 0 else 0)
