class_name GuildHallView
extends Node3D
## Stub 3D representation of the guild-hall unlock chain.
##
## Each stage builds a simple, visibly distinct structure from primitives:
## strictly growing footprint/height, different wall colors, different prop
## sets, and a floating stage label. Real art replaces these later — the
## STAGES and the transitions between them are the real part.
##
## Usage: add to a scene, call set_stage(GameState.guild_stage). The view
## rebuilds with a pop transition and emits stage_shown(index).

signal stage_shown(index: int)

var stage: int = 0
var _root: Node3D = null


func _ready() -> void:
	_root = Node3D.new()
	_root.name = "StageRoot"
	add_child(_root)


func set_stage(index: int) -> void:
	if _root == null:
		_root = Node3D.new()
		_root.name = "StageRoot"
		add_child(_root)
	for c in _root.get_children():
		_root.remove_child(c)
		c.free()  # immediate: transitions verify synchronously in headless tests
	stage = index
	_build(index)
	stage_shown.emit(index)


# --- Builders ---------------------------------------------------------------

func _build(index: int) -> void:
	_ground()
	if index <= 0:
		_empty_lot()
		return
	var s: Dictionary = GuildHall.stage(index)
	var fp: Vector2 = s["footprint"]
	var h: float = float(s["height"])
	var walls: Color = s["walls"]
	var roof: Color = s["roof"]
	var props: Array = s["props"]
	# Main body.
	_box(Vector3(fp.x, h, fp.y), Vector3(0, h * 0.5, 0), walls)
	# Roof: simple gable approximated with two tilted slabs.
	var slab := Vector3(fp.x * 0.62, 0.35, fp.y * 1.05)
	_box(slab, Vector3(-fp.x * 0.24, h + 0.6, 0), roof, 0.5)
	_box(slab, Vector3(fp.x * 0.24, h + 0.6, 0), roof, -0.5)
	# Front door (dark inset).
	_box(Vector3(1.4, 2.2, 0.3), Vector3(0, 1.1, fp.y * 0.5), Color(0.16, 0.11, 0.08))
	for prop in props:
		_prop(str(prop), fp, h, walls)
	# Floating stage label above the building.
	_label(str(s["label"]), Vector3(0, h + 2.6, 0), 96)


func _empty_lot() -> void:
	# Stage 0: a dirt lot with a FOR SALE sign — clearly "not bought yet".
	_sign("FOR SALE", Vector3(0, 1.2, 0), 72, Color(0.9, 0.75, 0.2))
	_label("GUILD PLOT", Vector3(0, 3.0, 0), 64)


func _prop(prop: String, fp: Vector2, h: float, walls: Color) -> void:
	match prop:
		"tilted_chimney":
			_box(Vector3(0.8, 1.6, 0.8), Vector3(fp.x * 0.3, h + 0.6, 0), Color(0.35, 0.33, 0.32), 0.18)
		"rubble":
			for i in 3:
				var p := Vector3(fp.x * 0.5 + 1.2 + i * 0.9, 0.25, fp.y * 0.5 + 0.8 - i * 0.5)
				_box(Vector3(0.9 - i * 0.15, 0.5, 0.7), p, Color(0.45, 0.44, 0.42))
		"dim_window":
			_box(Vector3(1.0, 1.0, 0.2), Vector3(-fp.x * 0.2, h * 0.55, fp.y * 0.5), Color(0.55, 0.45, 0.25))
		"repair_sign":
			_sign("NEEDS WORK", Vector3(fp.x * 0.5 + 1.5, 1.0, 0), 56, Color(0.8, 0.6, 0.3))
		"sign_post":
			_sign(str(GuildHall.stage(stage)["label"]), Vector3(-fp.x * 0.5 - 1.5, 1.2, fp.y * 0.5 + 1.0), 64, Color(0.75, 0.6, 0.35))
		"banner":
			_box(Vector3(0.25, 4.0, 0.25), Vector3(fp.x * 0.5 + 1.2, 2.0, -fp.y * 0.5), Color(0.4, 0.25, 0.15))
			_box(Vector3(1.6, 1.0, 0.1), Vector3(fp.x * 0.5 + 2.0, 3.4, -fp.y * 0.5), Color(0.7, 0.15, 0.15))
		"warm_windows":
			for i in 3:
				var x := -fp.x * 0.3 + i * fp.x * 0.3
				_box(Vector3(1.1, 1.1, 0.2), Vector3(x, h * 0.6, fp.y * 0.5), Color(1.0, 0.8, 0.45))
		"lanterns":
			for i in [-1, 1]:
				_box(Vector3(0.25, 2.2, 0.25), Vector3(i * (fp.x * 0.5 + 1.0), 1.1, fp.y * 0.5 + 1.5), Color(0.3, 0.2, 0.12))
				var orb := MeshInstance3D.new()
				var sm := SphereMesh.new()
				sm.radius = 0.28
				sm.height = 0.56
				orb.mesh = sm
				orb.position = Vector3(i * (fp.x * 0.5 + 1.0), 2.4, fp.y * 0.5 + 1.5)
				orb.material_override = _emissive(Color(1.0, 0.75, 0.4))
				_root.add_child(orb)
		"second_floor":
			_box(Vector3(fp.x * 0.8, h * 0.45, fp.y * 0.8), Vector3(0, h + h * 0.22, 0), walls.lightened(0.08))
		"wings":
			for i in [-1, 1]:
				_box(Vector3(fp.x * 0.28, h * 0.7, fp.y * 0.8),
					Vector3(i * fp.x * 0.64, h * 0.35, 0), walls.darkened(0.06))
		"fence":
			var n := 6
			for i in n + 1:
				var x := -fp.x * 0.5 - 2.5 + i * (fp.x + 5.0) / n
				_box(Vector3(0.25, 1.1, 0.25), Vector3(x, 0.55, fp.y * 0.5 + 3.0), Color(0.45, 0.32, 0.2))
			_box(Vector3(fp.x + 5.0, 0.15, 0.2), Vector3(0, 0.85, fp.y * 0.5 + 3.0), Color(0.45, 0.32, 0.2))
		"flag":
			_box(Vector3(0.2, 3.0, 0.2), Vector3(0, h + 1.5 + h * 0.45, 0), Color(0.35, 0.35, 0.4))
			_box(Vector3(1.4, 0.8, 0.08), Vector3(0.8, h + 2.4 + h * 0.45, 0), Color(0.15, 0.35, 0.7))
		"towers":
			for i in [-1, 1]:
				var t := MeshInstance3D.new()
				var cm := CylinderMesh.new()
				cm.bottom_radius = 1.4
				cm.top_radius = 1.4
				cm.height = h + 3.0
				t.mesh = cm
				t.position = Vector3(i * (fp.x * 0.5 + 1.6), (h + 3.0) * 0.5, fp.y * 0.5)
				t.material_override = _mat(Color(0.8, 0.78, 0.74))
				_root.add_child(t)
				var cap := MeshInstance3D.new()
				var cone := CylinderMesh.new()
				cone.bottom_radius = 1.7
				cone.top_radius = 0.05
				cone.height = 2.2
				cap.mesh = cone
				cap.position = Vector3(i * (fp.x * 0.5 + 1.6), h + 3.0 + 1.1, fp.y * 0.5)
				cap.material_override = _mat(Color(0.55, 0.30, 0.60))
				_root.add_child(cap)
		"gold_trim":
			_box(Vector3(fp.x + 0.3, 0.35, fp.y + 0.3), Vector3(0, h - 0.4, 0), Color(0.95, 0.75, 0.25))
		"grand_doors":
			_box(Vector3(2.6, 3.0, 0.35), Vector3(0, 1.5, fp.y * 0.5), Color(0.35, 0.22, 0.1))
			_box(Vector3(0.15, 3.0, 0.4), Vector3(0, 1.5, fp.y * 0.5), Color(0.95, 0.75, 0.25))
		"braziers":
			for i in [-1, 1]:
				_box(Vector3(0.3, 1.4, 0.3), Vector3(i * 3.2, 0.7, fp.y * 0.5 + 2.0), Color(0.25, 0.2, 0.15))
				var flame := MeshInstance3D.new()
				var sm2 := SphereMesh.new()
				sm2.radius = 0.35
				sm2.height = 0.7
				flame.mesh = sm2
				flame.position = Vector3(i * 3.2, 1.75, fp.y * 0.5 + 2.0)
				flame.material_override = _emissive(Color(1.0, 0.55, 0.15))
				_root.add_child(flame)


# --- Primitive helpers --------------------------------------------------------

func _mat(c: Color) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = c
	m.roughness = 0.9
	return m


func _emissive(c: Color) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = c
	m.emission_enabled = true
	m.emission = c
	m.emission_energy_multiplier = 1.5
	return m


func _box(size: Vector3, pos: Vector3, color: Color, rot_z: float = 0.0) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = size
	mi.mesh = bm
	mi.position = pos
	mi.rotation.z = rot_z
	mi.material_override = _mat(color)
	_root.add_child(mi)
	return mi


func _ground() -> void:
	var mi := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = Vector3(30, 0.4, 26)
	mi.mesh = bm
	mi.position = Vector3(0, -0.2, 0)
	mi.material_override = _mat(Color(0.25, 0.32, 0.2))
	_root.add_child(mi)
	# Dirt path to the door.
	var path := MeshInstance3D.new()
	var pm := BoxMesh.new()
	pm.size = Vector3(2.4, 0.45, 10)
	path.mesh = pm
	path.position = Vector3(0, -0.18, 12)
	path.material_override = _mat(Color(0.5, 0.42, 0.3))
	_root.add_child(path)


func _sign(text: String, pos: Vector3, px: int, color: Color) -> void:
	_box(Vector3(0.25, 2.0, 0.25), Vector3(pos.x, 1.0, pos.z), Color(0.4, 0.28, 0.16))
	var board := _box(Vector3(2.6, 1.2, 0.15), Vector3(pos.x, pos.y + 0.8, pos.z), color)
	var l := Label3D.new()
	l.text = text
	l.font_size = px
	l.position = Vector3(pos.x, pos.y + 0.8, pos.z + 0.15)
	l.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	board.add_child(l)


func _label(text: String, pos: Vector3, px: int) -> Label3D:
	var l := Label3D.new()
	l.text = text
	l.font_size = px
	l.position = pos
	l.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	l.no_depth_test = true
	_root.add_child(l)
	return l
