class_name TownView
extends Node3D
## Town view stub — Phase 3 scaffolding.
##
## A minimal but real town the game can enter and leave: placeholder
## geometry (primitive boxes + Label3D signs, zero art assets), its own
## camera, and UI buttons that drive the state machine — delve back into
## the dungeon, or travel to the overworld stub.
##
## Long-term this is the seed of the guild-hall chain: run-down tavern ->
## guild -> expanded guild -> adventurer's guild HQ, with visible upgrades
## per stage. None of that exists yet — this is the navigable placeholder.

const FoundersScript := preload("res://scripts/founders.gd")

signal delve_requested
signal overworld_requested

var delve_button: Button
var overworld_button: Button
var info_label: Label

var _camera: Camera3D


func _ready() -> void:
	_build_ground()
	_build_light()
	_build_camera()
	# Placeholder "buildings": colored boxes with floating signs.
	_add_building(Vector3(-7.0, 0.0, -5.0), Vector3(6.0, 4.0, 5.0),
		Color(0.45, 0.30, 0.18), "Tavern (stub)")
	_add_building(Vector3(7.0, 0.0, -5.0), Vector3(6.0, 5.0, 5.0),
		Color(0.35, 0.36, 0.40), "Smithy (stub)")
	_add_building(Vector3(0.0, 0.0, -10.5), Vector3(9.0, 7.0, 6.0),
		Color(0.20, 0.25, 0.45), "Guild Hall (future)")
	_add_delve_gate()
	_add_founder_figures()
	_build_ui()
	refresh_info()


## Run/gold/level line under the title — called on entry.
func refresh_info() -> void:
	if is_instance_valid(info_label):
		info_label.text = "Run #%d  ·  Level %d  ·  Gold %s  ·  You are safe here.  ·  Deed: %s" % [
			GameState.run_number, GameState.level,
			BigNumbers.format(GameState.gold),
			"signed" if LifeTree.town_deed_signed else "unsigned (reach depth 10)"]


func _build_ground() -> void:
	var ground := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(48.0, 48.0)
	ground.mesh = plane
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.16, 0.20, 0.16)
	mat.roughness = 1.0
	ground.material_override = mat
	add_child(ground)


func _build_light() -> void:
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-48.0, -30.0, 0.0)
	sun.light_energy = 0.9
	add_child(sun)


func _build_camera() -> void:
	_camera = Camera3D.new()
	_camera.position = Vector3(0.0, 9.5, 17.0)
	_camera.fov = 60.0
	add_child(_camera)
	_camera.look_at(Vector3(0.0, 1.5, -4.0))
	_camera.make_current()


func _add_building(pos: Vector3, size: Vector3, color: Color, sign_text: String) -> void:
	var box := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	box.mesh = mesh
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = 0.9
	box.material_override = mat
	box.position = pos + Vector3(0.0, size.y * 0.5, 0.0)
	add_child(box)
	# Simple "roof": a slightly larger flat box on top.
	var roof := MeshInstance3D.new()
	var roof_mesh := BoxMesh.new()
	roof_mesh.size = Vector3(size.x + 0.6, 0.4, size.z + 0.6)
	roof.mesh = roof_mesh
	var roof_mat := StandardMaterial3D.new()
	roof_mat.albedo_color = color.darkened(0.35)
	roof.material_override = roof_mat
	roof.position = pos + Vector3(0.0, size.y + 0.2, 0.0)
	add_child(roof)
	_add_sign(pos + Vector3(0.0, size.y + 1.6, 0.0), sign_text)


func _add_delve_gate() -> void:
	# The way back down: two pillars and a lintel, sign overhead.
	var stone := StandardMaterial3D.new()
	stone.albedo_color = Color(0.42, 0.42, 0.46)
	stone.roughness = 1.0
	for x in [-2.2, 2.2]:
		var pillar := MeshInstance3D.new()
		var pm := BoxMesh.new()
		pm.size = Vector3(1.0, 5.0, 1.0)
		pillar.mesh = pm
		pillar.material_override = stone
		pillar.position = Vector3(x, 2.5, 6.0)
		add_child(pillar)
	var lintel := MeshInstance3D.new()
	var lm := BoxMesh.new()
	lm.size = Vector3(5.6, 0.8, 1.2)
	lintel.mesh = lm
	lintel.material_override = stone
	lintel.position = Vector3(0.0, 5.4, 6.0)
	add_child(lintel)
	_add_sign(Vector3(0.0, 6.8, 6.0), "Delve Gate")


func _add_sign(pos: Vector3, text: String) -> void:
	var label := Label3D.new()
	label.text = text
	label.font_size = 72
	label.pixel_size = 0.012
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.no_depth_test = false
	label.position = pos
	add_child(label)


## Met founders stand in town (v0.11.0 embodiment): simple dark
## silhouette figures — primitives only, no art assets. Unmet founders
## simply aren't here yet; the row fills as the player meets them.
func _add_founder_figures() -> void:
	var i := 0
	for fid in LifeTree.met_ids():
		var f := FoundersScript.founder_by_id(fid)
		if f.is_empty():
			continue
		var x := -4.0 + float(i) * 2.0
		var mat := StandardMaterial3D.new()
		mat.albedo_color = (Color(f["color"]) as Color).darkened(0.45)
		mat.roughness = 1.0
		var body := MeshInstance3D.new()
		var bm := BoxMesh.new()
		bm.size = Vector3(0.7, 1.7, 0.4)
		body.mesh = bm
		body.material_override = mat
		body.position = Vector3(x, 0.85, 2.0)
		add_child(body)
		var head := MeshInstance3D.new()
		var hm := SphereMesh.new()
		hm.radius = 0.28
		hm.height = 0.56
		head.mesh = hm
		head.material_override = mat
		head.position = Vector3(x, 2.0, 2.0)
		add_child(head)
		_add_sign(Vector3(x, 2.7, 2.0),
			"%s (%s)" % [str(f["name"]), str(f["buff_name"])])
		i += 1


func _build_ui() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_top", 16)
	layer.add_child(margin)
	var vbox := VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_BEGIN
	vbox.add_theme_constant_override("separation", 8)
	margin.add_child(vbox)

	var title := Label.new()
	title.text = "TOWN — scaffolding (Phase 3)"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 30)
	title.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	vbox.add_child(title)

	info_label = Label.new()
	info_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	info_label.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	vbox.add_child(info_label)

	var hint := Label.new()
	hint.text = "Placeholder visuals — the real town grows here with the guild-hall chain."
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.add_theme_font_size_override("font_size", 14)
	hint.modulate = Color(1, 1, 1, 0.65)
	hint.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	vbox.add_child(hint)

	delve_button = Button.new()
	delve_button.text = "Delve into the dungeon"
	delve_button.custom_minimum_size = Vector2(280, 48)
	delve_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	delve_button.pressed.connect(func() -> void: delve_requested.emit())
	vbox.add_child(delve_button)

	overworld_button = Button.new()
	overworld_button.text = "Travel: Overworld (stub)"
	overworld_button.custom_minimum_size = Vector2(280, 48)
	overworld_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	overworld_button.pressed.connect(func() -> void: overworld_requested.emit())
	vbox.add_child(overworld_button)
