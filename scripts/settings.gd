class_name Settings
extends RefCounted
## Display + dev settings, persisted separately from audio volumes.
## Quality is minimal but real: high renders 3D at full resolution,
## low drops the 3D scale for weaker phones.
## cheat_speed is DEV-ONLY: reachable solely through the very-hidden
## settings easter egg (7 taps on the Settings title). Never advertised.
## hardcore is OPT-IN: death forfeits all carried gold and the per-death
## monster ramp becomes +5%/run instead of +2%. Same hidden corner.

const PATH := "user://display.dat"

static var quality := "high"  # "high" | "low"
static var cheat_speed := 1.0  # dev-only player speed multiplier
static var hardcore := false  # opt-in hardcore rules (hidden, default off)
static var dev_god_mode := false  # dev-only god mode (hidden, default off)
static var delve_pace := "normal"  # "leisurely" | "normal" | "swift"
## Delve pace: player-facing presentation speed. Scales the brain tick and
## the stride/yaw visuals — never damage, drops, prices, or any per-action
## number. This is a speed knob, not a balance lever.


static func pace_mult() -> float:
	match delve_pace:
		"leisurely":
			return 0.7
		"swift":
			return 1.3
	return 1.0


static func load_all() -> void:
	if not FileAccess.file_exists(PATH):
		return
	var f := FileAccess.open(PATH, FileAccess.READ)
	if f == null:
		return
	var d = str_to_var(f.get_as_text())
	f.close()
	if d is Dictionary:
		var q := str(d.get("quality", "high"))
		quality = q if q in ["high", "low"] else "high"
		cheat_speed = clampf(float(d.get("cheat_speed", 1.0)), 1.0, 16.0)
		hardcore = bool(d.get("hardcore", false))
		dev_god_mode = bool(d.get("dev_god_mode", false))
		var p := str(d.get("delve_pace", "normal"))
		delve_pace = p if p in ["leisurely", "normal", "swift"] else "normal"


static func save_all() -> void:
	var f := FileAccess.open(PATH, FileAccess.WRITE)
	if f == null:
		push_warning("Settings: could not write %s" % PATH)
		return
	f.store_string(var_to_str({
		"quality": quality,
		"cheat_speed": cheat_speed,
		"hardcore": hardcore,
		"dev_god_mode": dev_god_mode,
		"delve_pace": delve_pace,
	}))
	f.close()


static func apply_quality(viewport: Viewport) -> void:
	if viewport == null:
		return
	viewport.scaling_3d_scale = 1.0 if quality == "high" else 0.6


static func set_quality(q: String, viewport: Viewport) -> void:
	quality = q if q in ["high", "low"] else "high"
	apply_quality(viewport)
	save_all()


static func set_delve_pace(p: String) -> void:
	delve_pace = p if p in ["leisurely", "normal", "swift"] else "normal"
	save_all()
