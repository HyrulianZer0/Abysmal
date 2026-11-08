extends Node
## Speed-ramp stress beta: the dev-cheat player speed (GameState.speed_mult)
## ramps x2 -> x4 -> x8 -> x16, 30 real minutes per phase (2h total) at
## time_scale=1, so all the speed comes from the stat itself. Speed scales
## the idle brain's action rate AND the player's move animation — the real
## "player speed will eventually be in there" mechanic, exercised early.
##
## Hunts for the same inconsistencies + stalls as the deep delve, and records
## per-phase throughput (brain steps, kills) and frame-time stats (avg/p95/max).
##
## Run: godot --headless --path . tests/speed_ramp_scene.tscn
##      -- --phase_min=30 -- --phases=2,4,8,16
## Quick sanity: -- --phase_min=0.25 -- --phases=2,16
## Exits 0 on pass; non-zero on any violation.

const IT := preload("res://scripts/items.gd")

var _phases: Array = [2.0, 4.0, 8.0, 16.0]
var _phase_min := 30.0
var _phase_len := 1800.0
var _phase_idx := -1
var _phase_t := 0.0
var _main: Node = null
var _persist := false  # -- --persist: never leave the dungeon — field revive
                       # at the current depth on death instead of restarting
                       # at depth 1, so the run pushes deeper and deeper.

# Lifetime accumulators.
var _frames := 0
var _max_depth := 1
var _last_depth := 1
var _deaths := 0
var _was_alive := true
var _last_progress := 0.0
var _elapsed := 0.0
var _horde_floors := 0
var _violations := 0
var _violation_log := 0
var _gear_names := {}

# Per-phase accumulators (reset each phase).
var _p_steps := 0
var _p_kills := 0
var _p_deaths := 0
var _p_min_hp := 1.0
var _p_frames := PackedFloat32Array()


func _ready() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--phase_min="):
			var n := a.trim_prefix("--phase_min=")
			if n.is_valid_float() and float(n) > 0.0:
				_phase_min = float(n)
		elif a.begins_with("--phases="):
			var parts := a.trim_prefix("--phases=").split(",")
			var arr: Array = []
			for p in parts:
				if p.is_valid_float() and float(p) > 0.0:
					arr.append(float(p))
			if not arr.is_empty():
				_phases = arr
		elif a == "--persist" or a == "--persist=1":
			_persist = true
	_phase_len = _phase_min * 60.0
	Engine.time_scale = 1.0  # speed comes from speed_mult, not the clock
	var packed: PackedScene = load("res://scenes/main.tscn")
	_main = packed.instantiate()
	get_tree().root.add_child.call_deferred(_main)
	print("SPEEDRAMP: phases=%s x %.2f min each (time_scale=1)" % [str(_phases), _phase_min])
	_next_phase()


func _next_phase() -> void:
	# Report the phase that just ended (skip before the first).
	if _phase_idx >= 0:
		_report_phase()
	_phase_idx += 1
	if _phase_idx >= _phases.size():
		_finish()
		return
	_phase_t = 0.0
	_p_steps = GameState.brain_steps
	_p_kills = GameState.kills
	_p_deaths = _deaths
	_p_min_hp = 1.0
	_p_frames = PackedFloat32Array()
	GameState.speed_mult = _phases[_phase_idx]
	print("SPEEDRAMP: --- phase x%s started (%.2f min) ---" % [str(_phases[_phase_idx]), _phase_min])


func _process(delta: float) -> void:
	if _phase_idx < 0 or _phase_idx >= _phases.size():
		return
	_frames += 1
	_elapsed += delta
	_phase_t += delta
	_p_frames.append(delta * 1000.0)
	var gs = GameState

	if gs.depth != _last_depth:
		_last_depth = gs.depth
		_last_progress = _elapsed
		_max_depth = maxi(_max_depth, gs.depth)
		var gen: Dictionary = _main.get("gen") if _main != null else {}
		var horde := bool(gen.get("monster_floor", false))
		if horde:
			_horde_floors += 1
		print("SPEEDRAMP t=%.0fs [x%s]: depth=%d%s level=%d hp=%s/%s kills=%d" % [
			_elapsed, str(_phases[_phase_idx]), gs.depth,
			" [MONSTER FLOOR]" if horde else "",
			gs.level, _fmt(gs.hp), _fmt(gs.max_hp), gs.kills])

	if not gs.alive and _was_alive:
		_was_alive = false
		_deaths += 1
		_last_progress = _elapsed
		print("SPEEDRAMP t=%.0fs [x%s]: DEATH #%d at depth %d" % [
			_elapsed, str(_phases[_phase_idx]), _deaths, gs.depth])
		_handle_death_sort()
	elif gs.alive and not _was_alive:
		_was_alive = true
	elif gs.alive:
		_p_min_hp = minf(_p_min_hp, gs.hp / maxf(gs.max_hp, 1.0))

	_check_consistency(gs)

	for item in gs.run_gear:
		_gear_names[str(item["name"])] = true

	# Soft-lock: no depth change and no death for 6 minutes.
	if _elapsed - _last_progress > 360.0:
		_violate("STALL [x%s]: no progress for 6 min at depth %d" % [str(_phases[_phase_idx]), gs.depth])
		_finish()
		return

	if _phase_t >= _phase_len:
		_next_phase()


## Per-frame invariant scan. Anything off is an inconsistency worth a FAIL.
func _check_consistency(gs) -> void:
	var bad := ""
	if gs.hp != gs.hp or gs.max_hp != gs.max_hp or gs.gold != gs.gold:
		bad = "NaN stat"
	elif gs.hp < 0.0 or gs.hp > gs.max_hp + 0.01:
		bad = "hp out of bounds (%.1f/%.1f)" % [gs.hp, gs.max_hp]
	elif gs.gold < 0.0 or gs.run_gold < 0.0:
		bad = "negative gold"
	elif gs.level < 1 or gs.depth < 1:
		bad = "level/depth < 1"
	elif gs.xp < 0.0:
		bad = "negative xp"
	elif gs.health_potions < 0 or gs.mana_potions < 0:
		bad = "negative potions"
	elif gs.kills < 0 or gs.run_kills < 0:
		bad = "negative kills"
	if bad != "":
		_violate("INCONSISTENCY t=%.0fs [x%s] depth=%d: %s" % [
			_elapsed, str(_phases[_phase_idx]), gs.depth, bad])
	# Player must never stand inside a wall.
	if _main != null and is_instance_valid(_main) and gs.alive:
		var players := _main.find_children("", "Player", true, false)
		if not players.is_empty():
			var gp: Vector2i = players[0].grid_pos
			if int(_main.cell_at(gp)) == 0:
				_violate("INCONSISTENCY t=%.0fs [x%s]: player inside WALL at %s" % [
					_elapsed, str(_phases[_phase_idx]), str(gp)])


func _report_phase() -> void:
	var steps := GameState.brain_steps - _p_steps
	var kills := GameState.kills - _p_kills
	var deaths := _deaths - _p_deaths
	var avg := 0.0
	var mx := 0.0
	var p95 := 0.0
	if _p_frames.size() > 0:
		var sorted := _p_frames.duplicate()
		sorted.sort()
		for f in sorted:
			avg += f
		avg /= sorted.size()
		mx = sorted[sorted.size() - 1]
		p95 = sorted[int(sorted.size() * 0.95)]
	var sps := float(steps) / maxf(_phase_t, 0.01)
	print("SPEEDRAMP phase x%s DONE: %.0fs steps=%d (%.1f/s) kills=%d deaths=%d min_hp=%.2f frame avg=%.2fms p95=%.2fms max=%.2fms" % [
		str(_phases[_phase_idx]), _phase_t, steps, sps, kills, deaths,
		_p_min_hp, avg, p95, mx])


func _violate(msg: String) -> void:
	_violations += 1
	if _violation_log < 10:
		_violation_log += 1
		printerr("SPEEDRAMP " + msg)


func _fmt(v: float) -> String:
	if v >= 1000.0:
		return "%d" % int(v)
	return "%.0f" % v


## Same death-sort flow as the other betas: keep the best weapon + armor as
## heirlooms and delve again, verifying the picks carried over.
func _handle_death_sort() -> void:
	var gs = GameState
	if _persist:
		# Never leave the dungeon: field revive at the current depth, keeping
		# all gear/levels so the run pushes deeper and deeper. The hunger ramp
		# still applies per death (now capped), so deaths stay meaningful.
		gs.run_number += 1
		gs.hp = gs.max_hp
		gs.alive = true
		gs.stats_changed.emit()
		var hud = _main.get("hud")
		hud.hide_death()
		_main.clear_enemies_near(_main.player.grid_pos, 6)
		gs.add_log("Death #%d — the dungeon refuses to let go. Onward." % _deaths)
		return
	var best_w := {}
	var best_a := {}
	for item in gs.run_gear:
		var slot := str(item.get("slot", ""))
		if slot == "weapon" and IT.better(item, best_w):
			best_w = item
		elif slot == "armor" and IT.better(item, best_a):
			best_a = item
	var hud = _main.get("hud")
	hud.death_test_pick(best_w, best_a)
	hud.death_test_confirm()
	var eq_w: Dictionary = gs.equipment.get("weapon", {})
	var eq_a: Dictionary = gs.equipment.get("armor", {})
	if not best_w.is_empty() and not _dict_eq(eq_w, best_w):
		_violate("heirloom weapon not carried into next run")
	if not best_a.is_empty() and not _dict_eq(eq_a, best_a):
		_violate("heirloom armor not carried into next run")


func _dict_eq(a: Dictionary, b: Dictionary) -> bool:
	if a.size() != b.size():
		return false
	for k in a:
		if not b.has(k) or str(a[k]) != str(b[k]):
			return false
	return true


func _finish() -> void:
	GameState.speed_mult = 1.0
	print("SPEEDRAMP: DONE elapsed=%.0fs frames=%d" % [_elapsed, _frames])
	print("SPEEDRAMP: max_depth=%d deaths=%d horde_floors=%d kills=%d level=%d gold=%s gear_variety=%d" % [
		_max_depth, _deaths, _horde_floors, GameState.kills, GameState.level,
		_fmt(GameState.gold), _gear_names.size()])
	if _violations == 0:
		print("SPEEDRAMP: PASS — the engine held up through x%s" % str(_phases[_phases.size() - 1]))
	else:
		printerr("SPEEDRAMP: %d VIOLATIONS" % _violations)
	get_tree().quit(_violations)
