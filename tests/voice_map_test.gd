extends SceneTree
## Headless test for Wave 2 voice wiring (voice_map.gd + AudioManager voice API).
## Run: godot --headless --path . -s tests/voice_map_test.gd
## Exits 0 on success, 1 on any failure.
##
## Verifies: (1) all 28 staged monster types map to a vocal pool per context,
## (2) every wired clip exists on disk and is loadable, (3) NO flagged file
## is referenced anywhere, (4) one fallback reel exists per wired pool,
## (5) apex entries name pools only (no clips, Wave 4 data only),
## (6) the AudioManager voice API resolves, plays, and rejects unknowns.

var _failures := 0
var _ran := false

const EXPECTED_TYPES := ["slime", "bat", "skeleton", "rat", "spider", "snake",
	"wasp", "frog", "wolf", "goblin", "zombie", "ghost", "golem", "boar",
	"scorpion", "centipede", "skeleton_archer", "kobold", "imp", "pixie",
	"orc", "troll", "minotaur", "harpy", "oni", "kappa", "drake", "banshee"]


func _check(cond: bool, name: String, detail: String = "") -> void:
	if cond:
		print("  PASS  %s" % name)
	else:
		_failures += 1
		printerr("  FAIL  %s  %s" % [name, detail])


func _initialize() -> void:
	print("VOICE_MAP_TEST: starting")


func _process(_delta: float) -> bool:
	if _ran:
		return true
	_ran = true
	_run()
	return true


func _run() -> void:
	var am = root.get_node_or_null("AudioManager")
	_check(am != null, "autoload present")
	if am == null:
		quit(1)
		return
	if am._pool.is_empty():
		am._ready()
	var vm = load("res://scripts/voice_map.gd")

	# --- 1. coverage: exactly the 28 staged types -------------------------
	_check(vm.TYPE_VOICE.size() == 28, "28 types mapped", "got %d" % vm.TYPE_VOICE.size())
	var missing_types: Array = []
	for t in EXPECTED_TYPES:
		if not vm.TYPE_VOICE.has(t):
			missing_types.append(t)
	_check(missing_types.is_empty(), "all 28 staged types present", str(missing_types))
	var extra: Array = []
	for t in vm.TYPE_VOICE:
		if not (t in EXPECTED_TYPES):
			extra.append(t)
	_check(extra.is_empty(), "no unmapped extra types", str(extra))

	# --- 2/3. every wired clip exists, loads, and is not flagged -----------
	var flagged_paths: Array = []
	for f in vm.FLAGGED_FILES:
		flagged_paths.append(str(f["path"]))
	_check(flagged_paths.size() == 0, "flagged list empty (Nov 1: the one Layer 1 flag was confirmed and moved to undead)", "got %d" % flagged_paths.size())
	var bad_clips: Array = []
	var flagged_refs: Array = []
	var total_clips := 0
	for pool in vm.VOCAL_POOLS:
		var clips: Array = vm.VOCAL_POOLS[pool]
		_check(not clips.is_empty(), "pool non-empty: %s" % pool)
		for c in clips:
			total_clips += 1
			if c in flagged_paths:
				flagged_refs.append(c)
			if not FileAccess.file_exists(c):
				bad_clips.append(c)
			elif load(c) == null:
				bad_clips.append(c + " (load null)")
	_check(bad_clips.is_empty(), "all wired clips exist and load", str(bad_clips.slice(0, 5)))
	_check(flagged_refs.is_empty(), "no flagged file referenced", str(flagged_refs))
	_check(total_clips == 473, "473 wired clips", "got %d" % total_clips)
	print("  INFO  wired clips: %d across %d pools" % [total_clips, vm.VOCAL_POOLS.size()])

	# --- per-type entry sanity ---------------------------------------------
	var bad_entries: Array = []
	for t in vm.TYPE_VOICE:
		var e: Dictionary = vm.TYPE_VOICE[t]
		for ctx in ["idle", "attack", "death"]:
			if not vm.VOCAL_POOLS.has(str(e.get(ctx, ""))):
				bad_entries.append("%s:%s -> %s" % [t, ctx, str(e.get(ctx, ""))])
		if not (e.get("pitch", 0.0) >= 0.5 and e.get("pitch", 0.0) <= 1.6):
			bad_entries.append("%s pitch %s" % [t, str(e.get("pitch"))])
		if not (e.get("volume", 0.0) > 0.0 and e.get("volume", 0.0) <= 1.0):
			bad_entries.append("%s volume %s" % [t, str(e.get("volume"))])
	_check(bad_entries.is_empty(), "every type/context resolves to a real pool, sane pitch/volume", str(bad_entries))

	# --- 4. one reel per wired pool -----------------------------------------
	var missing_reels: Array = []
	for pool in vm.VOCAL_POOLS:
		var reel := "res://assets/resources-phase1/audio/reels/vocals-%s-reel.mp3" % pool
		if not FileAccess.file_exists(reel):
			missing_reels.append(reel)
	_check(missing_reels.is_empty(), "reel exists for every wired pool", str(missing_reels))

	# --- 5. apex: pools only, no clips ---------------------------------------
	_check(vm.APEX_VOCAL_POOLS.size() == 16, "16 apex bosses mapped (pools only)", "got %d" % vm.APEX_VOCAL_POOLS.size())
	var allowed := []
	for p in vm.VOCAL_POOLS:
		allowed.append(p)
	for p in vm.APEX_ONLY_POOLS:
		allowed.append(p)
	var bad_apex: Array = []
	for b in vm.APEX_VOCAL_POOLS:
		for p in vm.APEX_VOCAL_POOLS[b]:
			if "res://" in p or ".mp3" in p or ".ogg" in p or ".wav" in p:
				bad_apex.append("%s -> file path %s" % [b, p])
			elif not (p in allowed):
				bad_apex.append("%s -> unknown pool %s" % [b, p])
	_check(bad_apex.is_empty(), "apex entries name known pools only, never files", str(bad_apex))

	# --- 6. AudioManager voice API -------------------------------------------
	var unknown_ok: bool = (not am.has_monster_voice("nope_not_a_monster"))
	_check(unknown_ok, "unknown type has no voice")
	_check(am.resolve_monster_vocal("nope_not_a_monster") == "", "unknown type resolves empty")
	_check(am.resolve_monster_vocal("slime", "bogus_ctx") == "", "unknown context resolves empty")
	_check(not am.play_monster_vocal("nope_not_a_monster"), "unknown type play returns false")
	_check(not am.play_monster_vocal("slime", "bogus_ctx"), "unknown context play returns false")
	var resolve_bad: Array = []
	for t in EXPECTED_TYPES:
		for ctx in ["idle", "attack", "death"]:
			var path: String = am.resolve_monster_vocal(t, ctx)
			var pool_name := str(vm.TYPE_VOICE[t].get(ctx, ""))
			if path == "" or not (path in vm.VOCAL_POOLS[pool_name]):
				resolve_bad.append("%s/%s -> %s" % [t, ctx, path])
	_check(resolve_bad.is_empty(), "every type x context resolves into its pool", str(resolve_bad.slice(0, 5)))
	_check(am.play_monster_vocal("zombie", "attack"), "play zombie attack")
	_check(am.play_monster_vocal("banshee", "idle"), "play banshee idle (breath pool)")
	_check(am.play_monster_vocal("banshee", "death"), "play banshee death (scream pool)")
	_check(am.play_monster_vocal("drake", "idle"), "play drake idle (thin 2-clip pool)")
	var playing := 0
	for p in am._pool:
		if p.playing:
			playing += 1
	_check(playing >= 4, "voice calls actually playing", "playing=%d" % playing)
	var pitch_ok := true
	for p in am._pool:
		if p.playing and not (p.pitch_scale >= 0.2 and p.pitch_scale <= 3.0):
			pitch_ok = false
	_check(pitch_ok, "playing voice pitches in range")
	# Banshee context split: idle resolves to spirit, death to screams.
	_check("Breath_Scared" in am.resolve_monster_vocal("banshee", "idle"), "banshee idle = breath pool")
	_check("Scream_Male" in am.resolve_monster_vocal("banshee", "death"), "banshee death = scream pool")

	if _failures == 0:
		print("VOICE_MAP_TEST: ALL PASS")
	else:
		printerr("VOICE_MAP_TEST: %d FAILURES" % _failures)
	quit(_failures)
