extends Node
## Offline earnings test (James's Oct 10 revision: FULL speed, NO cap).
## - Pure formula math, incl. the design paper's worked example.
## - No cap: multi-day absence pays in full.
## - Backward clock (negative delta) -> zero, never negative.
## - Fresh tracker -> small safe defaults, no crash.
## - Rolling 30-min medians measured from recorded live play.
## - Save/load round-trip: a crafted v3 save with an old timestamp credits
##   the expected gold and raises the "While You Were Away" return screen;
##   a future timestamp (backward clock) credits zero and shows nothing.
## - v2 -> v3 migration stamps last_seen=now (no phantom backpay).
## Run: godot --headless --path . tests/offline_earnings_scene.tscn

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


func _read_save() -> Dictionary:
	var f := FileAccess.open("user://savegame.dat", FileAccess.READ)
	var d = str_to_var(f.get_as_text())
	f.close()
	return d


func _write_save(d: Dictionary) -> void:
	var f := FileAccess.open("user://savegame.dat", FileAccess.WRITE)
	f.store_string(var_to_str(d))
	f.close()


func _ready() -> void:
	print("OFFLINE: starting")
	# Pure-math phase needs no main scene.
	_phase = 0
	_frames = 0


func _process(_delta: float) -> void:
	_frames += 1
	if _phase == 0:
		_unit_tests()
		# Boot main for the integration phases.
		if FileAccess.file_exists("user://savegame.dat"):
			DirAccess.remove_absolute("user://savegame.dat")
		var packed: PackedScene = load("res://scenes/main.tscn")
		_main = packed.instantiate()
		get_tree().root.add_child.call_deferred(_main)
		_phase = 1
		_frames = 0
		return
	if _phase == 1:
		if _frames < 30 or not is_instance_valid(_main) or not _main.is_inside_tree():
			return
		_integration_tests()
		_phase = 2
		_frames = 0
		return
	if _phase == 2:
		if _frames < 5:
			return
		_migration_tests()
		if FileAccess.file_exists("user://savegame.dat"):
			DirAccess.remove_absolute("user://savegame.dat")
		if _failures == 0:
			print("OFFLINE: ALL PASS")
		else:
			printerr("OFFLINE: %d FAILURES" % _failures)
		get_tree().quit(1 if _failures > 0 else 0)


func _unit_tests() -> void:
	# The design paper's worked example (kill channel): 500 min x 6/min x
	# 14 gold x 1.36 Luck mult = 57,120.
	var w := OfflineEarnings.compute_earnings(500.0, 6.0, 14.0, 1.36)
	_check(absf(w - 57120.0) < 0.01, "formula matches worked example", str(w))
	# No cap: 3 days away pays in full (a 12h cap would pay 60,480).
	var big := OfflineEarnings.compute_earnings(4320.0, 6.0, 14.0, 1.0)
	_check(absf(big - 362880.0) < 0.01 and big > 100000.0, "no cap on long absence", str(big))
	# Backward clock -> zero, never negative.
	_check(OfflineEarnings.compute_earnings(-30.0, 6.0, 14.0, 1.0) == 0.0,
		"negative time credits zero")
	_check(OfflineEarnings.compute_earnings(0.0, 6.0, 14.0, 1.0) == 0.0,
		"zero time credits zero")
	# Fresh tracker -> small safe defaults, no crash.
	var fresh := OfflineEarnings.new()
	var t := OfflineEarnings.now_sec()
	var s := fresh.snapshot(t)
	_check(float(s["kills_per_min"]) == OfflineEarnings.DEFAULT_KILLS_PER_MIN,
		"fresh kills/min default", str(s["kills_per_min"]))
	_check(float(s["gold_per_kill"]) == OfflineEarnings.DEFAULT_GOLD_PER_KILL,
		"fresh gold/kill default", str(s["gold_per_kill"]))
	_check(not bool(s["measured"]), "fresh snapshot flagged unmeasured")
	# Rolling medians: 60 kills + 600 gold over the last 10 minutes.
	var sim := OfflineEarnings.new()
	for i in 60:
		var et := t - 600.0 + float(i) * 10.0
		sim.record_kill(et)
		sim.record_gold(10.0, et)
	_check(absf(sim.kills_per_min(t) - 6.0) < 0.01, "measured kills/min median", str(sim.kills_per_min(t)))
	_check(absf(sim.gold_per_kill(t) - 10.0) < 0.01, "measured gold/kill median", str(sim.gold_per_kill(t)))
	# Window pruning: a kill an hour ago is outside the 30-min window.
	var old := OfflineEarnings.new()
	old.record_kill(t - 3600.0)
	old.record_gold(999.0, t - 3600.0)
	_check(not old.has_data(t), "hour-old events pruned from window")
	_check(old.kills_per_min(t) == OfflineEarnings.DEFAULT_KILLS_PER_MIN,
		"pruned tracker falls back to default")


func _integration_tests() -> void:
	var hud = _main.get("hud")
	# Live delve is up (fresh boot, no save): stamp known medians via the
	# real save path, then rewrite the timestamp to 2h ago.
	GameState.offline.clear()
	var t := OfflineEarnings.now_sec()
	for i in 60:
		var et := t - 600.0 + float(i) * 10.0
		GameState.offline.record_kill(et)
		GameState.offline.record_gold(10.0, et)
	GameState.gold = 1000.0
	_main.save_game()
	var d := _read_save()
	_check(int(d.get("version", 0)) == 3, "save stamped v3")
	_check(int(d.get("last_seen_unix", 0)) > 0, "save carries wall-clock stamp")
	_check((d.get("delve_snapshot", {}) as Dictionary).has("kills_per_min"),
		"save carries delve snapshot")
	var now_unix := int(Time.get_unix_time_from_system())
	d["last_seen_unix"] = now_unix - 7200  # 2h away
	d["delve_snapshot"] = {"kills_per_min": 6.0, "gold_per_kill": 10.0, "measured": true}
	_write_save(d)
	GameState.gold = 1000.0
	var mult := GameState.gold_mult()
	var ok: bool = _main.load_game()
	var expected := 1000.0 + 120.0 * 6.0 * 10.0 * mult
	_check(ok, "offline save reloads")
	_check(absf(GameState.gold - expected) < 0.5, "2h offline gold credited at full speed",
		"got %f want %f" % [GameState.gold, expected])
	var rep: Dictionary = _main.get("pending_offline_report")
	_check(not rep.is_empty(), "pending report filled")
	_check(int(rep.get("seconds", 0)) >= 7190, "report carries time away", str(rep.get("seconds", 0)))
	_check(hud.get("_offline_panel").visible, "return screen shown after 2h away")
	_check(int(rep.get("depth", 0)) == GameState.depth, "depth held while away")
	hud.hide_offline_report()
	_check(not hud.get("_offline_panel").visible, "return screen dismisses")
	# Backward clock: timestamp in the future -> zero credit, no report.
	d = _read_save()
	d["last_seen_unix"] = int(Time.get_unix_time_from_system()) + 3600
	_write_save(d)
	GameState.gold = 1000.0
	_main.load_game()
	_check(absf(GameState.gold - 1000.0) < 0.001, "backward clock credits zero",
		str(GameState.gold))
	_check((_main.get("pending_offline_report") as Dictionary).is_empty(),
		"no report on backward clock")
	_check(not hud.get("_offline_panel").visible, "no return screen on backward clock")
	# Short absence (< 60s): session noise — no credit, no report screen.
	# (The design paper proposed silent credit here, but that breaks the
	# save/load round-trip invariant the suite enforces.)
	d = _read_save()
	d["last_seen_unix"] = int(Time.get_unix_time_from_system()) - 30
	d["delve_snapshot"] = {"kills_per_min": 6.0, "gold_per_kill": 10.0, "measured": true}
	_write_save(d)
	GameState.gold = 1000.0
	_main.load_game()
	_check(absf(GameState.gold - 1000.0) < 0.001, "30s absence credits nothing",
		"got %f" % GameState.gold)
	_check((_main.get("pending_offline_report") as Dictionary).is_empty(),
		"no report under 60s")
	_check(not hud.get("_offline_panel").visible, "no report screen under 60s")


func _migration_tests() -> void:
	# v2 -> v3 migration stamps last_seen=now: no phantom backpay.
	var before := int(Time.get_unix_time_from_system())
	var d: Dictionary = _main._migrate_save({"version": 2, "game_state": {}}, 2)
	_check(int(d.get("version", 0)) == 3, "migration lands on v3")
	var stamped := int(d.get("last_seen_unix", 0))
	_check(stamped >= before and stamped <= int(Time.get_unix_time_from_system()) + 1,
		"migration stamps last_seen=now", str(stamped))
	# A migrated v2 save loads through the real path without phantom gold.
	_write_save({
		"version": 2,
		"game_state": {"gold": 500.0, "depth": 3, "alive": true,
			"mode": 1, "run_number": 2},
		"prestige": {},
	})
	var ok: bool = _main.load_game()
	_check(ok, "migrated v2 save loads")
	_check(absf(GameState.gold - 500.0) < 0.001, "no phantom earnings on migrated load",
		str(GameState.gold))
