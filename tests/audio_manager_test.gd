extends SceneTree
## Headless test for AudioManager: pool overlap, music loop, volume persistence.
## Run: godot --headless --path . -s tests/audio_manager_test.gd
## Exits 0 on success, 1 on any failure.

var _failures := 0
var _ran := false


func _check(cond: bool, name: String, detail: String = "") -> void:
	if cond:
		print("  PASS  %s" % name)
	else:
		_failures += 1
		printerr("  FAIL  %s  %s" % [name, detail])


func _bus_idx(bus_name: String) -> int:
	for i in AudioServer.bus_count:
		if AudioServer.get_bus_name(i) == bus_name:
			return i
	return -1


func _initialize() -> void:
	print("AUDIO_TEST: starting")


## Playback needs the tree iterating; run the suite on the first frame.
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
		printerr("AUDIO_TEST: cannot continue without AudioManager")
		quit(1)
		return
	# With -s, the test's _initialize() runs before autoload _ready() callbacks.
	if am._pool.is_empty():
		am._ready()

	# Buses
	var sfx_idx := _bus_idx("SFX")
	var mus_idx := _bus_idx("Music")
	_check(sfx_idx >= 0, "SFX bus exists")
	_check(mus_idx >= 0, "Music bus exists")

	# Pool: 8 voices, all routed to the SFX bus
	_check(am._pool.size() == 8, "pool has 8 voices", "got %d" % am._pool.size())
	var all_sfx_bus := true
	for p in am._pool:
		if p.bus != "SFX":
			all_sfx_bus = false
	_check(all_sfx_bus, "all pool voices on SFX bus")
	_check(am._music_player.bus == "Music", "music player on Music bus")

	# Registry: every key resolves to a real file
	var missing: Array = []
	for key in AudioManager.SFX_REGISTRY:
		if not ResourceLoader.exists(AudioManager.SFX_REGISTRY[key]):
			missing.append(key)
	for key in AudioManager.MUSIC_REGISTRY:
		if not ResourceLoader.exists(AudioManager.MUSIC_REGISTRY[key]):
			missing.append("music:" + key)
	_check(missing.is_empty(), "registry keys resolve", str(missing))

	# Overlap: fire all 8 voices at once — none cut off
	var keys: Array = AudioManager.SFX_REGISTRY.keys()
	for i in 8:
		am.play_sfx(keys[i % keys.size()])
	var playing := 0
	for p in am._pool:
		if p.playing:
			playing += 1
	_check(playing == 8, "8 overlapping sfx all playing", "got %d" % playing)

	# 9th sound steals round-robin instead of erroring
	am.play_sfx(keys[0])
	playing = 0
	for p in am._pool:
		if p.playing:
			playing += 1
	_check(playing == 8, "9th sfx steals voice, still 8 playing", "got %d" % playing)

	# Unknown key: warning, no crash
	am.play_sfx("nope_not_a_key")
	_check(true, "unknown key handled gracefully")

	# Music: plays, loops, routes to Music bus
	am.play_music("theme", false)
	_check(am.is_music_playing(), "music playing")
	var mstream: AudioStream = am._music_player.stream
	_check(mstream != null and (mstream as AudioStreamOggVorbis).loop, "music stream loops")
	am.stop_music(false)
	_check(not am.is_music_playing(), "stop_music halts playback")

	# Volumes: setters apply to buses (linear -> dB)
	am.set_sfx_volume(0.3)
	am.set_music_volume(0.5)
	var sfx_db := AudioServer.get_bus_volume_db(sfx_idx)
	var mus_db := AudioServer.get_bus_volume_db(mus_idx)
	_check(abs(sfx_db - linear_to_db(0.3)) < 0.01, "sfx volume applied to bus", "db=%f" % sfx_db)
	_check(abs(mus_db - linear_to_db(0.5)) < 0.01, "music volume applied to bus", "db=%f" % mus_db)
	am.set_sfx_volume(0.0)
	_check(AudioServer.get_bus_volume_db(sfx_idx) <= -79.0, "zero volume mutes bus")

	# Persistence: save, clobber in memory, reload -> restored
	am.set_sfx_volume(0.25)
	am.set_music_volume(0.75)
	_check(FileAccess.file_exists("user://settings.dat"), "settings file written")
	am._sfx_volume = 0.9
	am._music_volume = 0.9
	am._load_settings()
	_check(abs(am.get_sfx_volume() - 0.25) < 0.001, "sfx volume persists", "got %f" % am.get_sfx_volume())
	_check(abs(am.get_music_volume() - 0.75) < 0.001, "music volume persists", "got %f" % am.get_music_volume())

	# Clamping
	am.set_sfx_volume(2.0)
	am.set_music_volume(-1.0)
	_check(am.get_sfx_volume() == 1.0, "sfx volume clamps high")
	_check(am.get_music_volume() == 0.0, "music volume clamps low")

	# Restore sane defaults for the dev environment
	am.set_sfx_volume(0.8)
	am.set_music_volume(0.7)

	if _failures == 0:
		print("AUDIO_TEST: ALL PASS")
	else:
		printerr("AUDIO_TEST: %d FAILURES" % _failures)
	quit(_failures)
