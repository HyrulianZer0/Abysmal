extends Node
## AudioManager — global sound hub (autoload singleton).
##
## - 8-voice SFX pool on the "SFX" bus: overlapping sounds never cut each other off.
## - Dedicated music player on the "Music" bus: seamless looping + fade in/out.
## - Independent linear 0.0–1.0 volumes per bus, persisted to user://settings.dat
##   (same var_to_str dict idiom as the main savegame.dat).
##
## Gameplay code only calls play_sfx() / play_music() / stop_music() and the
## volume setters. No gameplay event hooks live here — that's a separate task.
##
## PLATFORM NOTE (James): this must stay fully platform-agnostic — Windows, Mac,
## Android, iOS, consoles. Standard AudioStreamPlayer + AudioServer buses only;
## no OS checks, no driver selection, no platform-specific code paths. All
## sources are OGG, which Godot decodes on every platform. Godot's audio server
## outputs to the system speakers by default everywhere — nothing extra needed.
##
## All sound files are Kenney CC0 packs staged under assets/audio/kenney/.
## Music is the curated Alkakrab dungeon set under assets/audio/music/
## (see MUSIC_CREDITS.md there); kenney jingles remain for UI stingers only.

const SETTINGS_PATH := "user://settings.dat"
const SFX_POOL_SIZE := 8
const SFX_BUS := "SFX"
const MUSIC_BUS := "Music"
const FADE_TIME := 0.6
const MIN_DB := -80.0

## key -> res:// path. Swap files freely; keys are the stable API.
const SFX_REGISTRY := {
	"hit": "res://assets/audio/kenney/rpg-audio/knifeSlice.ogg",          # melee hit (slice)
	"hit_heavy": "res://assets/audio/kenney/impact-sounds/impactPlate_heavy_000.ogg",  # heavy/clang hit
	"coin": "res://assets/audio/kenney/rpg-audio/handleCoins.ogg",        # coin pickup
	"chest": "res://assets/audio/kenney/rpg-audio/creak1.ogg",            # chest lid creak
	"chest_open": "res://assets/audio/kenney/interface-sounds/open_001.ogg",  # chest latch
	"door": "res://assets/audio/kenney/rpg-audio/doorOpen_1.ogg",          # door open
	"ui_click": "res://assets/audio/kenney/interface-sounds/click_001.ogg",  # UI tap
	"ui_confirm": "res://assets/audio/kenney/interface-sounds/confirmation_001.ogg",  # purchase/confirm
	"potion": "res://assets/audio/kenney/rpg-audio/metalPot1.ogg",        # potion glug
	"seal_break": "res://assets/audio/kenney/impact-sounds/impactGlass_medium_000.ogg",  # ward/seal shatter
	"levelup": "res://assets/audio/kenney/music-jingles/jingles_HIT00.ogg",  # bright stinger
	"death": "res://assets/audio/kenney/music-jingles/jingles_NES00.ogg",    # somber stinger
}

## Music registry — curated Alkakrab dungeon set (assets/audio/music/).
## "theme" is the default dungeon theme (kept as a stable alias).
const MUSIC_REGISTRY := {
	"theme": "res://assets/audio/music/theme_dungeon.ogg",            # default: dungeon exploration
	"theme_dungeon": "res://assets/audio/music/theme_dungeon.ogg",    # Hidden Springs (Ambient) — main exploration
	"theme_dungeon_alt": "res://assets/audio/music/theme_dungeon_alt.ogg",  # Whispering Pines (Ambient) — exploration variant
	"theme_calm": "res://assets/audio/music/theme_calm.ogg",          # Moonlight (Ambient, Intense) — calm/safe moments
	"theme_deep": "res://assets/audio/music/theme_deep.ogg",          # Hollow Vale (Half Intense) — darker/deeper floors
	"theme_tense": "res://assets/audio/music/theme_tense.ogg",        # Beyond Mist (Intense, Ambient) — tension
	"theme_tense_alt": "res://assets/audio/music/theme_tense_alt.ogg",  # Silent Reach (Half Intense) — tension variant
	"theme_boss": "res://assets/audio/music/theme_boss.ogg",          # Beyond Mist (Intense Part) — boss
	"theme_boss_alt": "res://assets/audio/music/theme_boss_alt.ogg",  # Pale Waters (Intense Part) — boss variant
}

var _sfx_volume := 0.8
var _music_volume := 0.7
var _sfx_bus_idx := 0
var _music_bus_idx := 0
var _pool: Array[AudioStreamPlayer] = []
var _steal_idx := 0
var _sfx_cache := {}
var _music_cache := {}
var _music_player: AudioStreamPlayer
var _music_db := MIN_DB
var _music_tween: Tween


func _ready() -> void:
	if not _pool.is_empty():
		return  # already initialized (e.g. test-driven _ready before tree start)
	_sfx_bus_idx = _ensure_bus(SFX_BUS)
	_music_bus_idx = _ensure_bus(MUSIC_BUS)
	for i in SFX_POOL_SIZE:
		var p := AudioStreamPlayer.new()
		p.bus = SFX_BUS
		add_child(p)
		_pool.append(p)
	_music_player = AudioStreamPlayer.new()
	_music_player.bus = MUSIC_BUS
	add_child(_music_player)
	_load_settings()
	_apply_volumes()


## --- public API -----------------------------------------------------------

## Play a registered SFX. Never cuts off other voices: uses a free pool voice,
## or round-robin steals the oldest when all 8 are busy.
func play_sfx(key: String, pitch := 1.0) -> void:
	var stream: AudioStream = _sfx_stream(key)
	if stream == null:
		return
	var p := _free_voice()
	p.stream = stream
	p.pitch_scale = pitch
	p.volume_db = 0.0  # voice calls set per-call volume; never leak it into SFX.
	p.play()


## --- monster voices (Wave 2 voice wiring) ---------------------------------
## Data lives in scripts/voice_map.gd (family pools only — no per-monster
## vocals exist). Enemy-side triggers are NOT added here; the integration
## step calls play_monster_vocal() from enemy.gd. Context modifiers:
## attack is slightly higher/louder, death is lower; idle is neutral.
## resolve_monster_vocal() returns the pool's first clip (deterministic,
## for tests/integration checks); play_monster_vocal() picks a random clip
## from the same pool so repeated vocals vary.
const _VoiceMap = preload("res://scripts/voice_map.gd")
const _VOICE_CONTEXT_MOD := {
	"idle": {"pitch": 1.0, "volume": 1.0},
	"attack": {"pitch": 1.05, "volume": 1.1},
	"death": {"pitch": 0.85, "volume": 1.0},
}
var _voice_cache := {}


func has_monster_voice(type_id: String) -> bool:
	return _VoiceMap.TYPE_VOICE.has(type_id)


func resolve_monster_vocal(type_id: String, context := "idle") -> String:
	if not _VoiceMap.TYPE_VOICE.has(type_id):
		return ""
	if not _VOICE_CONTEXT_MOD.has(context):
		return ""
	var entry: Dictionary = _VoiceMap.TYPE_VOICE[type_id]
	var pool_name: String = str(entry.get(context, ""))
	if not _VoiceMap.VOCAL_POOLS.has(pool_name):
		return ""
	var clips: Array = _VoiceMap.VOCAL_POOLS[pool_name]
	if clips.is_empty():
		return ""
	return str(clips[0])


func play_monster_vocal(type_id: String, context := "idle", volume_scale := 1.0, pitch_shift := 0.0) -> bool:
	if not _VoiceMap.TYPE_VOICE.has(type_id):
		push_warning("AudioManager: unknown monster voice type '%s'" % type_id)
		return false
	if not _VOICE_CONTEXT_MOD.has(context):
		push_warning("AudioManager: unknown voice context '%s'" % context)
		return false
	var entry: Dictionary = _VoiceMap.TYPE_VOICE[type_id]
	var pool_name: String = str(entry.get(context, ""))
	if not _VoiceMap.VOCAL_POOLS.has(pool_name):
		return false
	var clips: Array = _VoiceMap.VOCAL_POOLS[pool_name]
	if clips.is_empty():
		return false
	var path: String = str(clips[randi() % clips.size()])
	var stream: AudioStream = _voice_stream(path)
	if stream == null:
		return false
	var mod: Dictionary = _VOICE_CONTEXT_MOD[context]
	var pitch := clampf(float(entry.get("pitch", 1.0)) * float(mod["pitch"]) + pitch_shift + randf_range(-0.08, 0.08), 0.2, 3.0)
	var volume := clampf(float(entry.get("volume", 1.0)) * float(mod["volume"]) * volume_scale, 0.0, 1.0)
	var p := _free_voice()
	p.stream = stream
	p.pitch_scale = pitch
	p.volume_db = _to_db(volume)
	p.play()
	return true


func _voice_stream(path: String) -> AudioStream:
	if not _voice_cache.has(path):
		_voice_cache[path] = load(path)
	return _voice_cache[path]


## Play a registered music track. Same track re-requested is a no-op; changing
## tracks fades out, swaps, fades in. Tracks loop seamlessly.
func play_music(key: String, fade_in := true) -> void:
	var stream: AudioStream = _music_stream(key)
	if stream == null:
		return
	if _music_player.playing and _music_player.stream == stream:
		return
	_kill_music_tween()
	if _music_player.playing:
		_music_tween = create_tween()
		_music_tween.tween_property(_music_player, "volume_db", MIN_DB, FADE_TIME * 0.5)
		_music_tween.tween_callback(_begin_music.bind(stream, fade_in))
	else:
		_begin_music(stream, fade_in)


func stop_music(fade_out := true) -> void:
	_kill_music_tween()
	if not _music_player.playing:
		return
	if fade_out:
		_music_tween = create_tween()
		_music_tween.tween_property(_music_player, "volume_db", MIN_DB, FADE_TIME * 0.5)
		_music_tween.tween_callback(_music_player.stop)
	else:
		_music_player.stop()


func set_sfx_volume(v: float) -> void:
	_sfx_volume = clampf(v, 0.0, 1.0)
	AudioServer.set_bus_volume_db(_sfx_bus_idx, _to_db(_sfx_volume))
	_save_settings()


func set_music_volume(v: float) -> void:
	_music_volume = clampf(v, 0.0, 1.0)
	_music_db = _to_db(_music_volume)
	AudioServer.set_bus_volume_db(_music_bus_idx, _music_db)
	if _music_player.playing and _music_tween == null:
		_music_player.volume_db = _music_db
	_save_settings()


func get_sfx_volume() -> float:
	return _sfx_volume


func get_music_volume() -> float:
	return _music_volume


func is_music_playing() -> bool:
	return _music_player.playing


## --- internals ------------------------------------------------------------

func _ensure_bus(bus_name: String) -> int:
	for i in AudioServer.bus_count:
		if AudioServer.get_bus_name(i) == bus_name:
			return i
	var idx := AudioServer.bus_count
	AudioServer.add_bus(idx)
	AudioServer.set_bus_name(idx, bus_name)
	AudioServer.set_bus_send(idx, "Master")
	return idx


func _to_db(linear: float) -> float:
	if linear <= 0.001:
		return MIN_DB
	return clampf(linear_to_db(linear), MIN_DB, 6.0)


func _free_voice() -> AudioStreamPlayer:
	for p in _pool:
		if not p.playing:
			return p
	# All busy: steal round-robin instead of cutting the newest.
	var p := _pool[_steal_idx % SFX_POOL_SIZE]
	_steal_idx += 1
	return p


func _sfx_stream(key: String) -> AudioStream:
	if not SFX_REGISTRY.has(key):
		push_warning("AudioManager: unknown sfx key '%s'" % key)
		return null
	if not _sfx_cache.has(key):
		_sfx_cache[key] = load(SFX_REGISTRY[key])
	return _sfx_cache[key]


func _music_stream(key: String) -> AudioStream:
	if not MUSIC_REGISTRY.has(key):
		push_warning("AudioManager: unknown music key '%s'" % key)
		return null
	if not _music_cache.has(key):
		var s: AudioStream = load(MUSIC_REGISTRY[key])
		if s != null and s is AudioStreamOggVorbis:
			(s as AudioStreamOggVorbis).loop = true
		_music_cache[key] = s
	return _music_cache[key]


func _begin_music(stream: AudioStream, fade_in: bool) -> void:
	_music_player.stream = stream
	_music_player.volume_db = MIN_DB if fade_in else _music_db
	_music_player.play()
	if fade_in:
		_kill_music_tween()
		_music_tween = create_tween()
		_music_tween.tween_property(_music_player, "volume_db", _music_db, FADE_TIME)


func _kill_music_tween() -> void:
	if _music_tween != null and _music_tween.is_valid():
		_music_tween.kill()
	_music_tween = null


func _apply_volumes() -> void:
	AudioServer.set_bus_volume_db(_sfx_bus_idx, _to_db(_sfx_volume))
	_music_db = _to_db(_music_volume)
	AudioServer.set_bus_volume_db(_music_bus_idx, _music_db)


func _save_settings() -> void:
	var d := {"sfx_volume": _sfx_volume, "music_volume": _music_volume}
	var f := FileAccess.open(SETTINGS_PATH, FileAccess.WRITE)
	if f == null:
		push_warning("AudioManager: could not write %s" % SETTINGS_PATH)
		return
	f.store_string(var_to_str(d))
	f.close()


func _load_settings() -> void:
	if not FileAccess.file_exists(SETTINGS_PATH):
		return
	var f := FileAccess.open(SETTINGS_PATH, FileAccess.READ)
	if f == null:
		return
	var d = str_to_var(f.get_as_text())
	f.close()
	if d is Dictionary:
		_sfx_volume = clampf(float(d.get("sfx_volume", _sfx_volume)), 0.0, 1.0)
		_music_volume = clampf(float(d.get("music_volume", _music_volume)), 0.0, 1.0)
