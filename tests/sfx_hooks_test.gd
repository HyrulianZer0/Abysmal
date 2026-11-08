extends SceneTree
## Headless test for gameplay event sound hooks (James-approved wiring pass).
## Run: godot --headless --path . -s tests/sfx_hooks_test.gd
## Exits 0 on success, 1 on any failure.
##
## Verifies: (1) every planned hook site exists in main.gd / hud.gd,
## (2) every key referenced is registered in AudioManager (no unknown-key
## warnings at runtime), (3) the _sfx throttle bounds rapid-fire playback,
## (4) the music director picks the right track per floor state.
## The runtime checks run against the real main scene (autoload identifiers
## only resolve in full scene context, not in -s preload compiles).

var _failures := 0
var _frames := 0
var _main: Node = null
var _did_run := false


func _check(cond: bool, name: String, detail: String = "") -> void:
	if cond:
		print("  PASS  %s" % name)
	else:
		_failures += 1
		printerr("  FAIL  %s  %s" % [name, detail])


func _initialize() -> void:
	print("SFX_HOOKS: starting")
	var packed: PackedScene = load("res://scenes/main.tscn")
	_main = packed.instantiate()
	root.add_child.call_deferred(_main)


func _process(_delta: float) -> bool:
	_frames += 1
	if _did_run:
		return true  # done -> quit
	if _frames >= 5:
		_did_run = true
		_run()
		return true  # done -> quit
	if _frames > 400:
		printerr("SFX_HOOKS: main scene never ready")
		quit(1)
		return true
	return false


func _src(path: String) -> String:
	var f := FileAccess.open(path, FileAccess.READ)
	var t := f.get_as_text()
	f.close()
	return t


func _run() -> void:
	var am = root.get_node_or_null("AudioManager")
	_check(am != null, "AudioManager autoload present")
	if am == null:
		quit(1)
		return
	var gs = root.get_node_or_null("GameState")

	var main_src := _src("res://scripts/main.gd")
	var hud_src := _src("res://scripts/hud.gd")

	# --- 1. hook sites present -------------------------------------------
	_check(main_src.contains("_sfx(\"hit_heavy\" if crit else \"hit\""), "player attack: crit->hit_heavy, else hit")
	_check(main_src.contains("_sfx(\"hit\", 80, 0.72)"), "enemy strike: soft hit")
	_check(main_src.count("_sfx(\"coin\", 150") == 2, "coin: kill gold + gear auto-sell", "count=%d" % main_src.count("_sfx(\"coin\", 150"))
	_check(main_src.contains("play_sfx(\"levelup\")"), "level-up stinger")
	_check(main_src.contains("play_sfx(\"seal_break\")"), "seal break")
	_check(main_src.contains("play_sfx(\"chest\")"), "chest creak on unlock")
	_check(main_src.contains("play_sfx(\"chest_open\")"), "chest latch on open")
	_check(main_src.count("play_sfx(\"door\")") == 3, "door: 3 open paths", "count=%d" % main_src.count("play_sfx(\"door\")"))
	_check(main_src.contains("_sfx(\"hit_heavy\", 200, 0.85)"), "door bash: heavy")
	_check(main_src.count("play_sfx(\"potion\")") == 2, "potion: key + HUD paths", "count=%d" % main_src.count("play_sfx(\"potion\")"))
	_check(main_src.contains("play_sfx(\"death\")"), "death stinger")
	_check(main_src.contains("AudioManager.stop_music()"), "music stops on death")
	_check(main_src.contains("play_music(\"theme_boss\")"), "music: boss floor")
	_check(main_src.contains("play_music(\"theme_deep\")"), "music: depth 5+")
	_check(main_src.contains("play_music(\"theme_dungeon\")"), "music: default theme")
	_check(hud_src.contains("func _click()"), "hud click helper")
	_check(hud_src.count("play_sfx(\"ui_confirm\")") >= 4, "hud: purchase/confirms", "count=%d" % hud_src.count("play_sfx(\"ui_confirm\")"))

	# --- 2. every referenced key is registered (no runtime warnings) -------
	var sfx_keys: Array = am.SFX_REGISTRY.keys()
	var mus_keys: Array = am.MUSIC_REGISTRY.keys()
	var key_re := RegEx.new()
	key_re.compile("(?:play_sfx|_sfx)\\(\"([a-z_]+)\"")
	for src in [main_src, hud_src]:
		for m in key_re.search_all(src):
			var k: String = m.get_string(1)
			_check(k in sfx_keys, "sfx key registered: %s" % k)
	var mus_re := RegEx.new()
	mus_re.compile("play_music\\(\"([a-z_]+)\"")
	for src in [main_src, hud_src]:
		for m in mus_re.search_all(src):
			var k: String = m.get_string(1)
			_check(k in mus_keys, "music key registered: %s" % k)

	# --- 3. throttle bounds rapid-fire playback ---------------------------
	for i in 100:
		_main._sfx("hit", 80)
	var playing := 0
	for p in am._pool:
		if p.playing:
			playing += 1
	_check(playing <= 8, "100 rapid hits: pool bounded", "playing=%d" % playing)
	_check(int(_main._sfx_last.get("hit", -1)) >= 0, "throttle timestamp recorded")
	# Suppression then release: backdate, play (new voice), immediate next suppressed.
	_main._sfx_last["hit"] = Time.get_ticks_msec() - 1000
	_main._sfx("hit", 80)
	var before := 0
	for p in am._pool:
		if p.playing:
			before += 1
	_main._sfx("hit", 80)  # within 80ms -> suppressed
	var after := 0
	for p in am._pool:
		if p.playing:
			after += 1
	_check(after == before, "throttle suppresses within interval", "before=%d after=%d" % [before, after])

	# --- 4. music director -------------------------------------------------
	# NOTE: play_music cross-fades when a track is already playing, so stop
	# without fade first to make each switch assertable in the same frame.
	var real_gen = _main.gen
	gs.idle_mode = false  # freeze the brain for deterministic checks
	gs.alive = true
	am.stop_music(false)
	gs.depth = 2
	_main.gen = {}
	_main._update_music()
	_check(am.is_music_playing(), "music starts on delve")
	_check("theme_dungeon" in str(am._music_player.stream.resource_path), "shallow floor -> theme_dungeon", str(am._music_player.stream.resource_path))
	am.stop_music(false)
	gs.depth = 6
	_main._update_music()
	_check("theme_deep" in str(am._music_player.stream.resource_path), "depth 6 -> theme_deep", str(am._music_player.stream.resource_path))
	am.stop_music(false)
	_main.gen = {"monster_floor": true}
	_main._update_music()
	_check("theme_boss" in str(am._music_player.stream.resource_path), "horde floor -> theme_boss", str(am._music_player.stream.resource_path))
	_main.gen = real_gen
	gs.idle_mode = true

	if _failures == 0:
		print("SFX_HOOKS: ALL PASS")
	else:
		printerr("SFX_HOOKS: %d FAILURES" % _failures)
	quit(_failures)
