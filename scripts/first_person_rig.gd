class_name FirstPersonRig
extends Node3D
## First-person hand/weapon rig, child of the player camera.
##
## One gloved hand (dark leather mitt built from primitives — NEVER bare
## skin, never a character body) + a weapon pivot with per-type primitive
## weapons. A second mitt appears only for the chest-opening reach.
##
## Swings are procedural tweens — no animation files, no storage cost.
## play_swing() takes an on-impact callback so combat SFX/damage land on
## the downswing. Grip presets tween-swap on equip via set_grip().
## Shadows are OFF for the whole rig: camera-space meshes must not cast.
## Paper: design-notes/first-person-presentation-2026-10.md §1.

const POSE_IDLE := 0
const POSE_SWING := 1
const POSE_CHEST := 2
const POSE_EQUIP := 3

const SWING_TIME := 0.25
const SWING_TIME_HEAVY := 0.35

## Grip presets: hand anchor transform + weapon pivot base rotation.
## Weapons are built pointing +Y from the pivot; wpn_rot angles them
## forward and inward (~20°) so they read naturally in-frame.
const GRIPS := {
	"blade": {
		"hand_pos": Vector3(0.30, -0.26, -0.55),
		"hand_rot": Vector3(0.12, -0.22, 0.08),
		"wpn_rot": Vector3(-0.45, 0.0, 0.35),
	},
	"crusher": {
		"hand_pos": Vector3(0.28, -0.30, -0.50),
		"hand_rot": Vector3(0.10, -0.20, 0.05),
		"wpn_rot": Vector3(-0.15, 0.0, 0.15),
	},
	"piercer": {
		"hand_pos": Vector3(0.26, -0.24, -0.60),
		"hand_rot": Vector3(0.05, -0.15, 0.0),
		"wpn_rot": Vector3(-1.25, 0.0, 0.10),
	},
	"fists": {
		"hand_pos": Vector3(0.28, -0.24, -0.48),
		"hand_rot": Vector3(0.10, -0.20, 0.05),
		"wpn_rot": Vector3(0.0, 0.0, 0.0),
	},
}

## Swing arcs (offsets from the grip's wpn_rot): windup rises up-right,
## the cut sweeps down-left across the center of the frame.
const WINDUP_OFFSET := Vector3(-0.28, 0.0, -0.30)
const CUT_OFFSET := Vector3(0.55, 0.0, 0.75)

var _pose := POSE_IDLE
var _grip_type := "blade"
var _breath_t := 0.0

var _sway: Node3D
var _stride_dip: Node3D
var _hand_r: Node3D
var _hand_l: Node3D
var _hand_l_parked := Vector3(-0.28, -0.34, -0.45)
var _weapon_pivot: Node3D
var _weapon_root: Node3D

var _mat_leather: StandardMaterial3D
var _mat_steel: StandardMaterial3D
var _mat_iron: StandardMaterial3D
var _mat_wood: StandardMaterial3D

var _swing_tween: Tween
var _equip_tween: Tween
var _chest_tween: Tween
var _dip_tween: Tween
var _pending_impact := Callable()


func _ready() -> void:
	_make_materials()
	_sway = Node3D.new()
	_sway.name = "Sway"
	add_child(_sway)
	_stride_dip = Node3D.new()
	_stride_dip.name = "StrideDip"
	_sway.add_child(_stride_dip)
	_hand_r = Node3D.new()
	_hand_r.name = "HandR"
	_stride_dip.add_child(_hand_r)
	_hand_r.add_child(_build_mitt())
	_weapon_pivot = Node3D.new()
	_weapon_pivot.name = "WeaponPivot"
	# Grip point: just above the palm, where the fingers would wrap.
	_weapon_pivot.position = Vector3(0.0, 0.05, -0.06)
	_hand_r.add_child(_weapon_pivot)
	_weapon_root = Node3D.new()
	_weapon_root.name = "Weapon"
	_weapon_pivot.add_child(_weapon_root)
	_hand_l = Node3D.new()
	_hand_l.name = "HandL"
	_hand_l.position = _hand_l_parked
	_hand_l.rotation = Vector3(0.10, 0.20, -0.05)
	_hand_l.add_child(_build_mitt())
	_hand_l.visible = false
	_stride_dip.add_child(_hand_l)
	sync_grip("blade")


func _make_materials() -> void:
	_mat_leather = StandardMaterial3D.new()
	_mat_leather.albedo_color = Color(0.23, 0.16, 0.11)  # dark worn leather
	_mat_leather.roughness = 0.95
	_mat_steel = StandardMaterial3D.new()
	_mat_steel.albedo_color = Color(0.72, 0.74, 0.80)
	_mat_steel.metallic = 0.65
	_mat_steel.roughness = 0.35
	_mat_iron = StandardMaterial3D.new()
	_mat_iron.albedo_color = Color(0.32, 0.32, 0.36)
	_mat_iron.metallic = 0.5
	_mat_iron.roughness = 0.6
	_mat_wood = StandardMaterial3D.new()
	_mat_wood.albedo_color = Color(0.35, 0.24, 0.14)
	_mat_wood.roughness = 0.9


## Box part with shadows disabled (rig-wide rule).
func _part_box(size: Vector3, pos: Vector3, mat: Material, rot := Vector3.ZERO) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = size
	mi.mesh = bm
	mi.material_override = mat
	mi.position = pos
	mi.rotation = rot
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	return mi


func _part_cyl(radius: float, height: float, pos: Vector3, mat: Material) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var cm := CylinderMesh.new()
	cm.top_radius = radius
	cm.bottom_radius = radius
	cm.height = height
	mi.mesh = cm
	mi.material_override = mat
	mi.position = pos
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	return mi


## Gloved mitt: palm block + finger block + angled thumb. Reads as a
## work glove in the frame corner — never bare skin, never a body.
func _build_mitt() -> Node3D:
	var mitt := Node3D.new()
	mitt.name = "Mitt"
	mitt.add_child(_part_box(Vector3(0.10, 0.055, 0.15), Vector3.ZERO, _mat_leather))
	mitt.add_child(_part_box(Vector3(0.095, 0.05, 0.07), Vector3(0, 0.005, -0.09), _mat_leather))
	mitt.add_child(_part_box(Vector3(0.035, 0.045, 0.085), Vector3(0.058, 0.008, -0.03), _mat_leather,
		Vector3(0.0, -0.45, 0.25)))
	return mitt


## Primitive weapons per grip type. Phone-scale silhouettes — a sword reads
## as a sword from three boxes at 0.5m. (Quaternius CC0 Medieval Weapons
## pack is the future upgrade path if we ever want real meshes.)
func _build_weapon(wtype: String) -> Node3D:
	var root := Node3D.new()
	root.name = "WeaponMesh"
	match wtype:
		"blade":
			# Sword: long blade up from the pivot, guard, grip below.
			root.add_child(_part_box(Vector3(0.05, 0.55, 0.014), Vector3(0, 0.33, 0), _mat_steel))
			root.add_child(_part_box(Vector3(0.16, 0.035, 0.05), Vector3(0, 0.04, 0), _mat_iron))
			root.add_child(_part_cyl(0.02, 0.13, Vector3(0, -0.045, 0), _mat_wood))
		"crusher":
			# Mace: haft with a heavy head.
			root.add_child(_part_cyl(0.018, 0.50, Vector3(0, 0.22, 0), _mat_wood))
			root.add_child(_part_box(Vector3(0.10, 0.10, 0.10), Vector3(0, 0.50, 0), _mat_iron))
		"piercer":
			# Spear: long shaft, steel tip.
			root.add_child(_part_cyl(0.014, 0.75, Vector3(0, 0.32, 0), _mat_wood))
			root.add_child(_part_box(Vector3(0.05, 0.14, 0.02), Vector3(0, 0.74, 0), _mat_steel))
		"fists":
			pass  # gloved fists need no weapon
	return root


func _apply_grip(wtype: String) -> void:
	var g: Dictionary = GRIPS.get(wtype, GRIPS["blade"])
	_hand_r.position = g["hand_pos"]
	_hand_r.rotation = g["hand_rot"]
	_weapon_pivot.rotation = g["wpn_rot"]


func _swap_weapon_mesh(wtype: String) -> void:
	# Immediate free (not queue_free): rapid swaps must not stack up
	# pending-deletion meshes, and callers may inspect the count at once.
	for c in _weapon_root.get_children():
		_weapon_root.remove_child(c)
		c.free()
	_weapon_root.add_child(_build_weapon(wtype))


## Instant grip set (run start, tests): no animation.
func sync_grip(wtype: String) -> void:
	_kill_equip()
	_grip_type = wtype
	_swap_weapon_mesh(wtype)
	_apply_grip(wtype)
	_pose = POSE_IDLE


## Animated equip swap: 0.5s dip-out / swap / rise-in with the new grip.
func set_grip(wtype: String) -> void:
	_kill_swing()
	_kill_equip()
	_pose = POSE_EQUIP
	_grip_type = wtype
	var g: Dictionary = GRIPS.get(wtype, GRIPS["blade"])
	_equip_tween = create_tween()
	_equip_tween.tween_property(_hand_r, "position:y", _hand_r.position.y - 0.22, 0.22) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	_equip_tween.tween_callback(_swap_weapon_mesh.bind(wtype))
	_equip_tween.tween_callback(_apply_grip.bind(wtype))
	_equip_tween.tween_property(_hand_r, "position", g["hand_pos"], 0.28) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_equip_tween.tween_callback(_end_pose.bind(POSE_EQUIP))


## Procedural swing. on_impact fires exactly as the cut begins (the
## downswing) — combat wires SFX/damage/popup through it so the hit lands
## with the blade, not before it.
func play_swing(wtype: String, on_impact: Callable = Callable()) -> void:
	# Never lose an impact: a swing interrupted by the next attack fires its
	# hit immediately instead of dropping it.
	_fire_impact()
	_kill_swing()
	_kill_equip()
	_pose = POSE_SWING
	var heavy := wtype == "crusher"
	var dur := SWING_TIME_HEAVY if heavy else SWING_TIME
	var g: Dictionary = GRIPS.get(wtype, GRIPS["blade"])
	var base_w: Vector3 = g["wpn_rot"]
	var base_h: Vector3 = g["hand_rot"]
	_pending_impact = on_impact
	_swing_tween = create_tween()
	# Windup: tip rises up-right; the hand leads at half amplitude.
	_swing_tween.tween_property(_weapon_pivot, "rotation", base_w + WINDUP_OFFSET, dur * 0.4) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_swing_tween.parallel().tween_property(_hand_r, "rotation", base_h + WINDUP_OFFSET * 0.5, dur * 0.4) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	# The cut begins: fire the impact, then sweep down-left across center.
	if on_impact.is_valid():
		_swing_tween.tween_callback(_fire_impact)
	var cut_scale := 1.25 if heavy else 1.0
	_swing_tween.tween_property(_weapon_pivot, "rotation", base_w + CUT_OFFSET * cut_scale, dur * 0.6) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	_swing_tween.parallel().tween_property(_hand_r, "rotation", base_h + CUT_OFFSET * 0.5 * cut_scale, dur * 0.6) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	if heavy:
		# Heavier arc + a small rig roll for weight. Never touch the camera —
		# the walk-bob owns camera.position.y.
		_swing_tween.parallel().tween_property(self, "rotation:z", 0.05, dur * 0.3) \
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		_swing_tween.parallel().tween_property(self, "rotation:z", 0.0, dur * 0.3)
	# Settle back into the grip pose.
	_swing_tween.tween_property(_weapon_pivot, "rotation", base_w, 0.12) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_swing_tween.parallel().tween_property(_hand_r, "rotation", base_h, 0.12) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_swing_tween.tween_callback(_end_pose.bind(POSE_SWING))


## Chest opening: both hands reach forward, the weapon slides to a holstered
## pose bottom-left, then everything returns. Works for idle-brain and
## manual — the hands are the player's window into what just happened.
func play_chest_open() -> void:
	_kill_swing()
	_kill_equip()
	_kill_chest()
	_pose = POSE_CHEST
	_hand_l.visible = true
	var g: Dictionary = GRIPS.get(_grip_type, GRIPS["blade"])
	var reach_r: Vector3 = (g["hand_pos"] as Vector3) + Vector3(-0.10, 0.10, -0.28)
	var reach_l := Vector3(0.02, -0.12, -0.75)
	_chest_tween = create_tween()
	_chest_tween.tween_property(_hand_r, "position", reach_r, 0.25) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_chest_tween.parallel().tween_property(_hand_l, "position", reach_l, 0.25) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_chest_tween.parallel().tween_property(_weapon_pivot, "rotation", Vector3(0.9, 0.0, 1.1), 0.25)
	_chest_tween.tween_interval(0.3)
	_chest_tween.tween_property(_hand_r, "position", g["hand_pos"], 0.25) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_chest_tween.parallel().tween_property(_hand_l, "position", _hand_l_parked, 0.25) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_chest_tween.parallel().tween_property(_weapon_pivot, "rotation", g["wpn_rot"], 0.25)
	_chest_tween.tween_callback(_end_chest)


## Stride sync: the walk dip reads the same stride duration the legs use —
## one source of truth, so the hands can't drift off the camera bob.
func on_stride(stride: float) -> void:
	if _dip_tween and _dip_tween.is_valid():
		_dip_tween.kill()
	_dip_tween = create_tween()
	_dip_tween.tween_property(_stride_dip, "position:y", -0.02, stride * 0.5) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_dip_tween.tween_property(_stride_dip, "position:y", 0.0, stride * 0.5) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func _process(delta: float) -> void:
	# Idle breathing: subtle sway, ~4s period. Only in the rest pose — every
	# action tween owns the hands while it runs.
	if _pose != POSE_IDLE:
		return
	_breath_t += delta
	_sway.position = Vector3(
		sin(_breath_t * TAU / 4.0) * 0.002,
		sin(_breath_t * TAU / 8.0 + 1.3) * 0.0015,
		0.0)


func is_swinging() -> bool:
	return _pose == POSE_SWING


func current_grip() -> String:
	return _grip_type


func _fire_impact() -> void:
	if _pending_impact.is_valid():
		var cb := _pending_impact
		_pending_impact = Callable()
		cb.call()


func _end_pose(pose: int) -> void:
	if _pose == pose:
		_pose = POSE_IDLE


func _end_chest() -> void:
	_hand_l.visible = false
	_end_pose(POSE_CHEST)


func _kill_swing() -> void:
	if _swing_tween and _swing_tween.is_valid():
		_swing_tween.kill()
	_swing_tween = null


func _kill_equip() -> void:
	if _equip_tween and _equip_tween.is_valid():
		_equip_tween.kill()
	_equip_tween = null


func _kill_chest() -> void:
	if _chest_tween and _chest_tween.is_valid():
		_chest_tween.kill()
	_chest_tween = null
