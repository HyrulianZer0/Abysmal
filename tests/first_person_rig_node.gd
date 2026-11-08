extends Node
## First-person rig + turn-smoothing test.
## Covers: rig parented to the player camera, shadows off everywhere,
## gloved (never bare-skin) hand material, grip swap/apply, procedural
## swing firing its impact callback and completing, chest-open round trip,
## and the depth-proof yaw glide band (task 2).
##
## Run: godot --headless --path . tests/first_person_rig_scene.tscn
## Exits 0 on pass, 1 on any failure.

const PlayerScript := preload("res://scripts/player.gd")
const RigScript := preload("res://scripts/first_person_rig.gd")

var _failures := 0
var _player: Player = null
var _rig: RigScript = null


func _check(cond: bool, name: String, detail: String = "") -> void:
	if cond:
		print("  PASS  %s" % name)
	else:
		_failures += 1
		printerr("  FAIL  %s  %s" % [name, detail])


func _ready() -> void:
	Engine.time_scale = 4.0
	# Fresh boot: a stale save would restore mid-run state.
	if FileAccess.file_exists("user://savegame.dat"):
		DirAccess.remove_absolute("user://savegame.dat")
	_player = PlayerScript.new()
	get_tree().root.add_child.call_deferred(_player)
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	_rig = _player.fp_rig
	_test_rig_presence()
	_test_shadows_off()
	_test_gloved_hand()
	await _test_grip_swap()
	await _test_swing()
	await _test_chest_open()
	_test_yaw_band()
	_player.queue_free()
	Engine.time_scale = 1.0
	GameState.depth = 1
	GameState.speed_mult = 1.0
	if _failures == 0:
		print("FIRSTRIG: ALL PASS")
	else:
		printerr("FIRSTRIG: %d FAILURES" % _failures)
	get_tree().quit(_failures)


func _test_rig_presence() -> void:
	_check(_rig != null, "rig created on player")
	if _rig == null:
		return
	_check(_rig.get_parent() == _player.camera, "rig is a child of the player camera")
	_check(_rig.current_grip() == "blade", "default grip is blade")


func _rig_meshes() -> Array:
	var out: Array = []
	var stack: Array = [_rig]
	while not stack.is_empty():
		var n: Node = stack.pop_back()
		if n is MeshInstance3D:
			out.append(n)
		for c in n.get_children():
			stack.append(c)
	return out


func _test_shadows_off() -> void:
	if _rig == null:
		_check(false, "shadows off (no rig)")
		return
	var meshes := _rig_meshes()
	_check(not meshes.is_empty(), "rig has meshes to check", str(meshes.size()))
	var all_off := true
	for m in meshes:
		if (m as MeshInstance3D).cast_shadow != GeometryInstance3D.SHADOW_CASTING_SETTING_OFF:
			all_off = false
	_check(all_off, "every rig mesh has shadows OFF")


func _test_gloved_hand() -> void:
	# The hand material must read as dark worn leather — never bare skin.
	var mitt: Node = _rig.get_node_or_null("Sway/StrideDip/HandR/Mitt")
	_check(mitt != null, "right mitt exists")
	if mitt == null:
		return
	var palm := mitt.get_child(0) as MeshInstance3D
	var mat := palm.material_override as StandardMaterial3D
	_check(mat != null, "mitt has a material")
	if mat == null:
		return
	var c := mat.albedo_color
	# Dark leather: all channels low. Bare skin would sit ~ (0.85, 0.65, 0.55).
	_check(c.r < 0.4 and c.g < 0.4 and c.b < 0.4,
		"mitt is dark leather, not skin", str(c))


func _test_grip_swap() -> void:
	_rig.sync_grip("crusher")
	_check(_rig.current_grip() == "crusher", "sync_grip sets crusher")
	var pivot: Node3D = _rig.get_node("Sway/StrideDip/HandR/WeaponPivot")
	var crusher_rot: Vector3 = pivot.rotation
	_rig.sync_grip("piercer")
	_check(_rig.current_grip() == "piercer", "sync_grip sets piercer")
	_check(not (pivot.rotation as Vector3).is_equal_approx(crusher_rot),
		"grip swap changes weapon pivot rotation")
	_rig.set_grip("fists")
	_check(_rig.current_grip() == "fists", "set_grip sets fists")
	# The swap lands mid-tween (dip 0.22s); wait it out at 4x.
	await get_tree().create_timer(1.0).timeout
	_check(_weapon_part_count() == 0, "fists grip builds no weapon")
	_rig.sync_grip("blade")
	_check(_weapon_part_count() == 3, "blade grip builds sword (3 parts)")


## Parts inside the current WeaponMesh node (one wrapper per swap).
func _weapon_part_count() -> int:
	var wroot: Node3D = _rig.get_node("Sway/StrideDip/HandR/WeaponPivot/Weapon")
	if wroot.get_child_count() == 0:
		return -1
	return (wroot.get_child(0) as Node3D).get_child_count()


func _test_swing() -> void:
	var fired := [false]
	_rig.sync_grip("blade")
	_rig.play_swing("blade", func(): fired[0] = true)
	_check(_rig.is_swinging(), "swing starts")
	# 0.25s swing at 4x = ~0.06s real; wait generously.
	await get_tree().create_timer(1.0).timeout
	_check(fired[0], "impact callback fired on the downswing")
	_check(not _rig.is_swinging(), "swing completes back to idle")
	# Interrupting a swing must not eat its impact.
	var fired2 := [false]
	_rig.play_swing("blade", func(): fired2[0] = true)
	_rig.play_swing("blade", func(): pass)
	await get_tree().create_timer(1.0).timeout
	_check(fired2[0], "interrupted swing fires its impact immediately (no lost hits)")


func _test_chest_open() -> void:
	var hand_l: Node3D = _rig.get_node("Sway/StrideDip/HandL")
	_rig.play_chest_open()
	_check(hand_l.visible, "chest open shows the left hand")
	# ~1.05s anim at 4x = ~0.26s real; wait generously.
	await get_tree().create_timer(1.5).timeout
	_check(not hand_l.visible, "chest open hides the left hand after")
	_check(not _rig.is_swinging(), "rig back to idle after chest")


func _test_yaw_band() -> void:
	# Task 2: yaw glide must stay smooth regardless of depth.
	GameState.speed_mult = 1.0
	GameState.depth = 1
	var t1: float = _player.call("_yaw_time")
	_check(is_equal_approx(t1, 0.3), "depth 1 yaw = full 0.3s glide", str(t1))
	GameState.depth = 40  # depth_walk_mult caps at 2.0
	var t40: float = _player.call("_yaw_time")
	# Old 3x-cap formula gave 0.3/3 = 0.1 (whip); sqrt of the 2x cap gives
	# 0.3/sqrt(2) ≈ 0.212 — smooth, and a touch quicker than the surface.
	_check(t40 > 0.19 and t40 < 0.23, "depth 40 yaw stays smooth (~0.21s)", str(t40))
	_check(t40 < t1, "deeper still turns a touch quicker")
	# Dev cheat at 16x would whip to ~0.01s — clamp holds the floor.
	GameState.speed_mult = 16.0
	var tmin: float = _player.call("_yaw_time")
	_check(is_equal_approx(tmin, 0.12), "yaw never glides faster than 0.12s", str(tmin))
	GameState.speed_mult = 1.0
	GameState.depth = 1
