class_name DungeonView
extends Node3D
## Builds the 3D dungeon from a DungeonGen grid using MultiMeshes:
## batched MultiMeshes per texture variant of the floor's theme
## (mossy_dark: 5 wall, 2 floor, 2 ceiling cap; lava: 1 + 1 + 1 + 1).
## Wall tops get thin dark
## "ceiling cap" slabs, and — since v0.10.0's device playtest, where the
## black void above every room read as "ceilings are missing" — every open
## (non-wall) cell gets a matching ceiling slab at the same height, so the
## dungeon has a real ceiling plane (one more MultiMesh per cap variant).
## Mossy brick variants are folded into the wall rotation and the cap
## rotation for vine pop. Per-instance brightness tint breaks up tiling.
## Doors are individual slabs (core + textured quad faces — see _make_door
## for why a single BoxMesh can't show a door texture); stairs/loot markers
## untouched.

const CELL := 2.0
const WALL_HEIGHT := 2.4

## Theme sets. The dungeon has no zone-exclusive list (locked canon) — the
## theme for each floor is picked RANDOMLY from the available sets at
## build_floor() time (director call, Nov 8; correctable — e.g. weight lava
## rarer later). Each theme is a dictionary of texture PATHS (strings, not
## preloads): the lava JPGs are staged with hand-written .import files and
## may not be imported yet on a fresh checkout, so _load_theme_tex resolves
## them at build time (importer first, direct-decode fallback).
## "mossy_dark" is the live look today: staged flakdeau textures (CC0,
## hand-made pixel art — no AI assets). Wall set: cohesive grey-brick
## family with mossy variants folded in for vine pop (Grey_Moss on grey,
## Black_Moss as rare dark accent). The orange flakdeau ceiling texture is
## deliberately NOT used anywhere.
## "lava" is the sixth set, staged Nov 8 (see
## design-notes/lava-volcano-theme.md): photoreal 1K maps, LINEAR filter,
## emissive floor + ceiling, cap lift 1.3.
const THEMES := {
	"mossy_dark": {
		"walls": [
			"res://assets/textures/flakdeau/walls/Bricks_01_Grey_2.png",
			"res://assets/textures/flakdeau/walls/Bricks_02_Grey_4.png",
			"res://assets/textures/flakdeau/walls/Bricks_04_Grey_2.png",
			"res://assets/textures/flakdeau/walls/Bricks_04_Grey_Moss_1.png",
			"res://assets/textures/flakdeau/walls/Bricks_04_Black_Moss_2.png",
		],
		"wall_weights": [45, 30, 10, 10, 5],
		"floors": [
			"res://assets/textures/flakdeau/floors/Cobblestones_01_Grey_1.png",
			"res://assets/textures/flakdeau/floors/Stones_Loose_01_Grey_1.png",
		],
		"floor_weights": [60, 40],
		"caps": [
			"res://assets/textures/flakdeau/walls/Bricks_04_Black_2.png",
			"res://assets/textures/flakdeau/walls/Bricks_04_Black_Moss_1.png",
		],
		"cap_weights": [65, 35],
		"cap_lift": 1.9,
		"linear": false,
		"floor_emission": "",
		"floor_emission_energy": 0.0,
		"ceiling_emission": "",
		"ceiling_emission_energy": 0.0,
	},
	"lava": {
		"walls": ["res://assets/textures/dungeon/lava/wall_diff_1k.jpg"],
		"wall_weights": [100],
		"floors": ["res://assets/textures/dungeon/lava/floor_diff_1k.jpg"],
		"floor_weights": [100],
		"caps": ["res://assets/textures/dungeon/lava/ceiling_diff_1k.jpg"],
		"cap_weights": [100],
		"cap_lift": 1.3,
		"linear": true,
		"floor_emission": "res://assets/textures/dungeon/lava/floor_emissive_1k.jpg",
		"floor_emission_energy": 1.0,
		"ceiling_emission": "res://assets/textures/dungeon/lava/ceiling_emissive_1k.jpg",
		"ceiling_emission_energy": 0.5,
	},
}
## Cap slab thickness; centered on the wall-box top so the bottom embeds in
## the wall and the top lip sticks out — no coplanar faces, no z-fighting.
const CAP_THICK := 0.12
const DOOR_TEX_CLOSED := preload("res://assets/textures/flakdeau/doors/Door_Wood_Green_1.png")
const DOOR_TEX_LOCKED := preload("res://assets/textures/flakdeau/doors/Door_Wood_Blue_1.png")
const DOOR_TEX_OPEN := preload("res://assets/textures/flakdeau/floors/Cobblestones_01_Grey_2.png")
## The flakdeau door PNGs carry TRANSPARENT margins around the artwork
## (white RGB underneath): blue art spans cols 38-217 / rows 16-255, green
## cols 26-227 / rows 6-255 of the 256px canvas. Door face quads sample
## only the artwork rect (uv1 offset/scale), or the margins render as flat
## white x tint — the pale "half a door" slabs from the v0.10.0 playtest.
const DOOR_UV_CLOSED := Rect2(26.0 / 256.0, 6.0 / 256.0, 202.0 / 256.0, 250.0 / 256.0)
const DOOR_UV_LOCKED := Rect2(38.0 / 256.0, 16.0 / 256.0, 180.0 / 256.0, 240.0 / 256.0)

var _wall_mats: Array[StandardMaterial3D] = []
var _floor_mats: Array[StandardMaterial3D] = []
var _cap_mats: Array[StandardMaterial3D] = []
var _ceil_mats: Array[StandardMaterial3D] = []
## Current theme for this floor ("mossy_dark" or "lava"), picked per floor
## in build_floor(). Public so tests can assert which theme built.
var current_theme: String = "mossy_dark"
var _theme: Dictionary = {}
## Direct-decode fallback cache (path -> Texture2D); see _load_theme_tex.
var _tex_cache := {}
## Loot/chest markers, keyed by grid pos so pickups can be removed.
var _loot_nodes := {}
## Door slabs, keyed by grid pos so state changes can restyle them.
var _door_nodes := {}


func world_pos(gp: Vector2i) -> Vector3:
	return Vector3(gp.x * CELL, 0.0, gp.y * CELL)


func build_floor(gen: Dictionary, theme_override: String = "") -> void:
	for child in get_children():
		child.queue_free()
	_wall_mats.clear()
	_floor_mats.clear()
	_cap_mats.clear()
	_ceil_mats.clear()
	_loot_nodes.clear()
	_door_nodes.clear()
	_header_mat = null
	_pick_theme(theme_override)
	_ensure_materials()

	var grid: Array = gen["grid"]
	var width: int = gen["width"]
	var height: int = gen["height"]

	# Bucket cells by texture variant (deterministic position hash) so large
	# rooms don't look like repeating wallpaper. One MultiMesh per variant
	# keeps the batching approach (mossy_dark: 5 wall + 2 floor + 2 cap +
	# 2 ceiling draw calls; lava: 1 + 1 + 1 + 1).
	var floor_paths: Array = _theme["floors"]
	var wall_paths: Array = _theme["walls"]
	var cap_paths: Array = _theme["caps"]
	var floor_weights: Array = _theme["floor_weights"]
	var wall_weights: Array = _theme["wall_weights"]
	var cap_weights: Array = _theme["cap_weights"]
	var floor_buckets: Array = []
	var wall_buckets: Array = []
	var cap_buckets: Array = []
	var ceil_buckets: Array = []
	for i in floor_paths.size():
		floor_buckets.append([])
	for i in wall_paths.size():
		wall_buckets.append([])
	for i in cap_paths.size():
		cap_buckets.append([])
		ceil_buckets.append([])
	for y in height:
		for x in width:
			var cell: int = (grid[y] as Array)[x]
			if cell == DungeonGen.WALL:
				# Only draw walls that touch a non-wall (hollow shell).
				if _touches_open(grid, width, height, x, y):
					var wv: int = _pick_variant(x, y, wall_weights)
					(wall_buckets[wv] as Array).append(Vector3(x * CELL, 0, y * CELL))
					# Dark ceiling cap crowns every drawn wall box.
					var cv: int = _pick_variant(x * 3 + 7, y * 5 + 1, cap_weights)
					(cap_buckets[cv] as Array).append(Vector3(x * CELL, 0, y * CELL))
			else:
				var fv: int = _pick_variant(x, y, floor_weights)
				(floor_buckets[fv] as Array).append(Vector3(x * CELL, 0, y * CELL))
				# Real ceiling over every open cell — same slab, same center
				# height as the wall caps, so cap bottoms and ceiling bottoms
				# form one continuous dark plane (y 2.34) over the whole floor.
				var cv2: int = _pick_variant(x * 7 + 3, y * 11 + 5, cap_weights)
				(ceil_buckets[cv2] as Array).append(Vector3(x * CELL, 0, y * CELL))

	for i in floor_paths.size():
		_make_multimesh(floor_buckets[i], _textured_box(Vector3(CELL, 0.1, CELL), _floor_mats[i]), Vector3(0, -0.05, 0))
	for i in wall_paths.size():
		_make_multimesh(wall_buckets[i], _textured_box(Vector3(CELL, WALL_HEIGHT, CELL), _wall_mats[i]), Vector3(0, WALL_HEIGHT * 0.5, 0))
	for i in cap_paths.size():
		_make_multimesh(cap_buckets[i], _textured_box(Vector3(CELL, CAP_THICK, CELL), _cap_mats[i]), Vector3(0, WALL_HEIGHT, 0))
		_make_multimesh(ceil_buckets[i], _textured_box(Vector3(CELL, CAP_THICK, CELL), _ceil_mats[i]), Vector3(0, WALL_HEIGHT, 0))

	# Stairs marker: golden pad + floating label.
	var stairs: Vector2i = gen["stairs"]
	var pad := MeshInstance3D.new()
	var pad_mesh := BoxMesh.new()
	pad_mesh.size = Vector3(CELL * 0.9, 0.12, CELL * 0.9)
	pad.mesh = pad_mesh
	var pad_mat := StandardMaterial3D.new()
	pad_mat.albedo_color = Color(0.95, 0.75, 0.25)
	pad_mat.emission_enabled = true
	pad_mat.emission = Color(0.9, 0.65, 0.2)
	pad.material_override = pad_mat
	pad.position = world_pos(stairs) + Vector3(0, 0.06, 0)
	add_child(pad)
	var label := Label3D.new()
	label.text = "▼ EXIT"
	label.font_size = 64
	label.pixel_size = 0.006
	label.position = world_pos(stairs) + Vector3(0, 1.6, 0)
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.modulate = Color(1.0, 0.85, 0.4)
	add_child(label)


# ------------------------------------------------------------------- loot ---

## Loot marker colors/tags by pickup kind.
const LOOT_STYLE := {
	"weapon": {"color": Color(0.85, 0.85, 0.95), "tag": "WPN"},
	"armor": {"color": Color(0.35, 0.75, 0.90), "tag": "ARM"},
	"health_potion": {"color": Color(0.95, 0.30, 0.30), "tag": "HP"},
	"mana_potion": {"color": Color(0.35, 0.50, 0.95), "tag": "MP"},
}


## Build glowing pickup markers + chests for a fresh floor.
func build_loot(loot: Array, chests: Array) -> void:
	for l in loot:
		if not bool(l["taken"]):
			_loot_nodes[l["pos"]] = _make_loot_marker(l)
	for c in chests:
		if not bool(c["opened"]):
			_loot_nodes[c["pos"]] = _make_chest(c)


func _make_loot_marker(l: Dictionary) -> Node3D:
	var root := Node3D.new()
	root.position = world_pos(l["pos"])
	var style: Dictionary = LOOT_STYLE.get(str(l["kind"]), {"color": Color.WHITE, "tag": "?"})
	var color: Color = style["color"]
	var mi := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(0.4, 0.4, 0.4)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.emission_enabled = true
	mat.emission = color
	mat.emission_energy_multiplier = 0.7
	box.material = mat
	mi.mesh = box
	mi.position = Vector3(0, 0.55, 0)
	root.add_child(mi)
	var label := Label3D.new()
	label.text = str(style["tag"])
	label.font_size = 40
	label.pixel_size = 0.004
	label.position = Vector3(0, 1.05, 0)
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.modulate = color
	root.add_child(label)
	add_child(root)
	return root


func _make_chest(c: Dictionary) -> Node3D:
	var root := Node3D.new()
	root.position = world_pos(c["pos"])
	var sealed := bool(c.get("sealed", false))
	var locked := int(c.get("tumblers", 0)) > 0
	# Wooden box + lid. Sealed chests glow violet (ward); locked chests get a
	# red shackle. Both can apply at once.
	var body := MeshInstance3D.new()
	var body_mesh := BoxMesh.new()
	body_mesh.size = Vector3(0.9, 0.45, 0.9)
	var wood := StandardMaterial3D.new()
	wood.albedo_color = Color(0.45, 0.28, 0.14)
	wood.roughness = 1.0
	body_mesh.material = wood
	body.mesh = body_mesh
	body.position = Vector3(0, 0.28, 0)
	root.add_child(body)
	var lid := MeshInstance3D.new()
	var lid_mesh := BoxMesh.new()
	lid_mesh.size = Vector3(0.95, 0.16, 0.95)
	var lid_mat := StandardMaterial3D.new()
	if sealed:
		lid_mat.albedo_color = Color(0.45, 0.25, 0.75)
		lid_mat.emission_enabled = true
		lid_mat.emission = Color(0.55, 0.3, 0.95)
		lid_mat.emission_energy_multiplier = 0.8
	else:
		lid_mat.albedo_color = Color(0.85, 0.65, 0.25)
		lid_mat.emission_enabled = true
		lid_mat.emission = Color(0.85, 0.65, 0.25)
		lid_mat.emission_energy_multiplier = 0.5
	lid_mesh.material = lid_mat
	lid.mesh = lid_mesh
	lid.position = Vector3(0, 0.58, 0)
	root.add_child(lid)
	if locked:
		var shackle := MeshInstance3D.new()
		var shackle_mesh := BoxMesh.new()
		shackle_mesh.size = Vector3(0.28, 0.28, 0.14)
		var red := StandardMaterial3D.new()
		red.albedo_color = Color(0.8, 0.15, 0.15)
		red.emission_enabled = true
		red.emission = Color(0.9, 0.2, 0.2)
		red.emission_energy_multiplier = 0.9
		shackle_mesh.material = red
		shackle.mesh = shackle_mesh
		shackle.position = Vector3(0, 0.62, 0.5)
		root.add_child(shackle)
	var label := Label3D.new()
	if sealed:
		label.text = "SEALED"
		label.modulate = Color(0.75, 0.55, 1.0)
	elif locked:
		label.text = "LOCKED"
		label.modulate = Color(1.0, 0.5, 0.5)
	else:
		label.text = "CHEST"
		label.modulate = Color(1.0, 0.85, 0.45)
	label.font_size = 44
	label.pixel_size = 0.0045
	label.position = Vector3(0, 1.1, 0)
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	root.add_child(label)
	add_child(root)
	return root


## Rebuild a chest's marker (seal broken, lock picked, …).
func update_chest(c: Dictionary) -> void:
	var pos: Vector2i = c["pos"]
	if _loot_nodes.has(pos):
		(_loot_nodes[pos] as Node).queue_free()
		_loot_nodes.erase(pos)
	if not bool(c.get("opened", false)):
		_loot_nodes[pos] = _make_chest(c)


# ------------------------------------------------------------------ doors ---

## Build door slabs for a fresh floor. Closed = wooden slab, locked = slab +
## red shackle, open = flat threshold plate. Every doorway also gets a brick
## header filling the slot between the slab top (1.9) and the ceiling (2.4).
func build_doors(doors: Array) -> void:
	for d in doors:
		_door_nodes[d["pos"]] = _make_door(d)


func _make_door(d: Dictionary) -> Node3D:
	# Doors are built in LOCAL "ns" space (slab spans X, thin in Z) and the
	# root is rotated 90° for "ew" doors. Two hard-won reasons (v0.10.0
	# device playtest):
	#  1. A single-material BoxMesh does NOT map the full texture onto its
	#     faces — Godot 4 BoxMesh faces sample partial, per-face offset
	#     sub-rects of the texture (verified with quadrant/gradient test
	#     textures). A textured box door therefore shows a shifted crop:
	#     half flat tint (the texture's transparent margin, white RGB x
	#     tint), half of one leaf, no handles. The wide faces here are
	#     QuadMeshes, whose UVs are a clean 0-1 across the face.
	#  2. The old per-axis box sizes put the shackle at the slab's center —
	#     inside the 0.35-thick slab, invisible from both sides.
	var root := Node3D.new()
	root.position = world_pos(d["pos"])
	if str(d.get("axis", "ns")) == "ew":
		root.rotation.y = PI * 0.5
	var state := str(d.get("state", "closed"))
	if state == "open":
		var plate := MeshInstance3D.new()
		var plate_mesh := BoxMesh.new()
		plate_mesh.size = Vector3(1.9, 0.08, 1.9)
		# Flat threshold plate: stone texture, slightly dimmed.
		plate_mesh.material = _make_door_material(DOOR_TEX_OPEN, Color(0.72, 0.72, 0.78))
		plate.mesh = plate_mesh
		plate.position = Vector3(0, 0.04, 0)
		root.add_child(plate)
	else:
		# Dark wood core: gives the slab thickness/edges behind the faces.
		var core := MeshInstance3D.new()
		var core_mesh := BoxMesh.new()
		core_mesh.size = Vector3(1.8, 1.9, 0.34)
		var core_mat := StandardMaterial3D.new()
		core_mat.albedo_color = Color(0.20, 0.13, 0.08)
		core_mat.roughness = 1.0
		core_mesh.material = core_mat
		core.mesh = core_mesh
		core.position = Vector3(0, 0.95, 0)
		root.add_child(core)
		# Textured faces, front and back, sampling only the artwork rect of
		# the PNG (see DOOR_UV_*): the full double door, both leaves, center
		# handles — no transparent-margin bands.
		var tex := DOOR_TEX_CLOSED
		var tint := Color.WHITE
		var uv := DOOR_UV_CLOSED
		if state == "locked":  # blue wood, darkened — shackle + label mark it.
			tex = DOOR_TEX_LOCKED
			tint = Color(0.78, 0.78, 0.85)
			uv = DOOR_UV_LOCKED
		var face_mat := _make_door_material(tex, tint, uv)
		for side in [1.0, -1.0]:
			var face := MeshInstance3D.new()
			var quad := QuadMesh.new()
			quad.size = Vector2(1.8, 1.9)
			quad.material = face_mat
			face.mesh = quad
			face.position = Vector3(0, 0.95, side * 0.176)
			if side < 0.0:
				face.rotation.y = PI
			root.add_child(face)
	# Brick header over the doorway: slab top is 1.9, ceiling plane is 2.4 —
	# without this the slot above every door reads as a black notch.
	var header := MeshInstance3D.new()
	var header_mesh := BoxMesh.new()
	header_mesh.size = Vector3(1.8, 0.5, 0.36)
	header_mesh.material = _header_material()
	header.mesh = header_mesh
	header.position = Vector3(0, 2.15, 0)
	root.add_child(header)
	if state == "locked":
		var shackle := MeshInstance3D.new()
		var sm := BoxMesh.new()
		# Deeper than the slab (0.5 vs 0.34) so the lock housing protrudes
		# from BOTH faces — a door can be approached from either side.
		sm.size = Vector3(0.34, 0.34, 0.5)
		var red := StandardMaterial3D.new()
		red.albedo_color = Color(0.8, 0.15, 0.15)
		red.emission_enabled = true
		red.emission = Color(0.95, 0.25, 0.25)
		red.emission_energy_multiplier = 1.0
		sm.material = red
		shackle.mesh = sm
		shackle.position = Vector3(0, 1.1, 0.0)
		root.add_child(shackle)
		var label := Label3D.new()
		label.text = "LOCKED"
		label.font_size = 40
		label.pixel_size = 0.004
		label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		label.modulate = Color(1.0, 0.45, 0.45)
		root.add_child(label)
		# One label per face, hovering just off the header: a single centered
		# label would be swallowed by the header box, and a door is
		# approached from both sides.
		var label2 := label.duplicate() as Label3D
		label.position = Vector3(0, 2.15, 0.32)
		label2.position = Vector3(0, 2.15, -0.32)
		root.add_child(label2)
	add_child(root)
	return root


## Restyle a door after its state changed.
func update_door(d: Dictionary) -> void:
	var pos: Vector2i = d["pos"]
	if _door_nodes.has(pos):
		(_door_nodes[pos] as Node).queue_free()
		_door_nodes.erase(pos)
	_door_nodes[pos] = _make_door(d)


## Remove a collected pickup's marker.
func remove_loot_at(pos: Vector2i) -> void:
	if _loot_nodes.has(pos):
		(_loot_nodes[pos] as Node).queue_free()
		_loot_nodes.erase(pos)


## Swap a chest to its opened look: dark, lid sunk, label gone.
func mark_chest_opened(pos: Vector2i) -> void:
	if not _loot_nodes.has(pos):
		return
	var root: Node3D = _loot_nodes[pos]
	for child in root.get_children():
		if child is Label3D:
			child.queue_free()
		elif child is MeshInstance3D:
			var mi := child as MeshInstance3D
			mi.scale = Vector3(1.0, 0.45, 1.0)
			var m := (mi.mesh as BoxMesh).material as StandardMaterial3D
			if m != null:
				m.emission_enabled = false
				m.albedo_color = m.albedo_color.darkened(0.55)


func _touches_open(grid: Array, width: int, height: int, x: int, y: int) -> bool:
	for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
		var nx: int = x + d.x
		var ny: int = y + d.y
		if nx < 0 or ny < 0 or nx >= width or ny >= height:
			return true  # map edge: draw the boundary
		if (grid[ny] as Array)[nx] != DungeonGen.WALL:
			return true
	return false


## Pick the theme for this floor: forced name, else random among THEMES.
## If the picked theme's textures can't be resolved (e.g. never imported),
## fall back to mossy_dark so a floor always builds.
func _pick_theme(theme_override: String) -> void:
	var name := theme_override
	if name == "" or not THEMES.has(name):
		var keys: Array = THEMES.keys()
		name = str(keys[randi() % keys.size()])
	_theme = THEMES[name] as Dictionary
	if not _theme_textures_ok(_theme):
		push_warning("DungeonView: theme '%s' textures failed to load; falling back to mossy_dark" % name)
		name = "mossy_dark"
		_theme = THEMES[name] as Dictionary
	current_theme = name


## True when every texture a theme needs resolves (walls/floors/caps plus
## any emission maps). Uses _load_theme_tex, so the direct-decode fallback
## counts as resolved.
func _theme_textures_ok(theme: Dictionary) -> bool:
	for key in ["walls", "floors", "caps"]:
		for p in (theme[key] as Array):
			if _load_theme_tex(str(p)) == null:
				return false
	for key in ["floor_emission", "ceiling_emission"]:
		var p := str(theme[key])
		if p != "" and _load_theme_tex(p) == null:
			return false
	return true


## Resolve a theme texture path. Importer first (the proper path on a real
## editor run); direct-decode fallback when the texture was never imported
## (headless CI: this container's Godot does not import new files, so the
## lava JPGs resolve only via this fallback until a real editor run
## generates the .ctex artifacts). Decoded textures are cached per view
## instance and labelled with their source path so tests and debugging see
## the same resource_path an imported texture would carry.
func _load_theme_tex(path: String) -> Texture2D:
	var t := load(path) as Texture2D
	if t != null:
		return t
	if _tex_cache.has(path):
		return _tex_cache[path]
	var img := Image.load_from_file(path)
	if img == null:
		return null
	var itex := ImageTexture.create_from_image(img)
	itex.take_over_path(path)
	_tex_cache[path] = itex
	return itex


## Build (once per floor) the cached textured materials for the current
## theme's walls/floors/caps. Caps and open-cell ceilings share the theme's
## cap textures but get SEPARATE materials: caps take the theme's cap lift
## only, ceilings add the ceiling emission map (lava). The black-brick cap
## textures crush to pure black on phone screens under the dim ambient
## (real-device report, v0.8.0) — the lift (1.9x mossy_dark, 1.3x lava)
## keeps them readable. albedo_color >1 multiplies the texture.
func _ensure_materials() -> void:
	if not _wall_mats.is_empty():
		return
	var linear := bool(_theme["linear"])
	var cap_lift := float(_theme["cap_lift"])
	for p in (_theme["walls"] as Array):
		_wall_mats.append(_make_tex_material(_load_theme_tex(str(p)), linear))
	for p in (_theme["floors"] as Array):
		var fm := _make_tex_material(_load_theme_tex(str(p)), linear)
		var fe := str(_theme["floor_emission"])
		if fe != "":
			fm.emission_enabled = true
			fm.emission_texture = _load_theme_tex(fe)
			fm.emission = Color.WHITE
			fm.emission_energy_multiplier = float(_theme["floor_emission_energy"])
		_floor_mats.append(fm)
	for p in (_theme["caps"] as Array):
		var cm := _make_tex_material(_load_theme_tex(str(p)), linear)
		cm.albedo_color = Color(cap_lift, cap_lift, cap_lift)
		_cap_mats.append(cm)
		var ceil_m := _make_tex_material(_load_theme_tex(str(p)), linear)
		ceil_m.albedo_color = Color(cap_lift, cap_lift, cap_lift)
		var ce := str(_theme["ceiling_emission"])
		if ce != "":
			ceil_m.emission_enabled = true
			ceil_m.emission_texture = _load_theme_tex(ce)
			ceil_m.emission = Color.WHITE
			ceil_m.emission_energy_multiplier = float(_theme["ceiling_emission_energy"])
		_ceil_mats.append(ceil_m)


## Textured StandardMaterial3D. `linear` switches the filter: NEAREST keeps
## the pixel-art crisp (mossy_dark/flakdeau), LINEAR suits the photoreal
## 1K maps (lava). Roughness 1.0 keeps the matte dungeon look. Fog +
## radius light work as-is.
func _make_tex_material(tex: Texture2D, linear := false) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_texture = tex
	mat.albedo_color = Color.WHITE
	mat.roughness = 1.0
	if linear:
		mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR
	else:
		mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	return mat


## Fresh textured material for a single door slab (doors are few; no sharing).
## `uv_rect` (when non-empty) restricts sampling to the texture's artwork
## region via uv1 offset/scale — see DOOR_UV_* for why doors need it.
func _make_door_material(tex: Texture2D, tint: Color, uv_rect := Rect2()) -> StandardMaterial3D:
	var mat := _make_tex_material(tex)
	mat.albedo_color = tint
	if uv_rect.size != Vector2.ZERO:
		mat.uv1_offset = Vector3(uv_rect.position.x, uv_rect.position.y, 0)
		mat.uv1_scale = Vector3(uv_rect.size.x, uv_rect.size.y, 1)
	return mat


## Shared brick material for door headers (built once, lazily).
var _header_mat: StandardMaterial3D = null


func _header_material() -> StandardMaterial3D:
	if _header_mat == null:
		# Doors can be built on a view that never built a floor (tests do
		# this) — _theme is empty then, so fall back to mossy_dark.
		var theme: Dictionary = _theme if not _theme.is_empty() else THEMES["mossy_dark"]
		_header_mat = _make_tex_material(
			_load_theme_tex(str((theme["walls"] as Array)[0])), bool(theme["linear"]))
	return _header_mat


## Deterministic texture-variant pick from grid position, honoring weights.
func _pick_variant(x: int, y: int, weights: Array) -> int:
	var h: int = int(abs(x * 73856093 ^ y * 19349663)) % 100
	var acc := 0
	for i in weights.size():
		acc += int(weights[i])
		if h < acc:
			return i
	return weights.size() - 1


## Subtle per-instance brightness tint (0.90–1.0) to further break up tiling.
func _instance_tint(x: float, z: float) -> Color:
	var h: int = int(abs(int(x * 10.0) * 83492791 ^ int(z * 10.0) * 2971215073)) % 100
	var b := 0.90 + 0.10 * (float(h) / 100.0)
	return Color(b, b, minf(b * 1.03, 1.0))


func _textured_box(size: Vector3, mat: StandardMaterial3D) -> BoxMesh:
	var mesh := BoxMesh.new()
	mesh.size = size
	mesh.material = mat
	return mesh


func _make_multimesh(positions: Array, mesh: BoxMesh, y_offset: Vector3) -> void:
	if positions.is_empty():
		return
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.use_colors = true
	mm.mesh = mesh
	mm.instance_count = positions.size()
	for i in positions.size():
		var p: Vector3 = positions[i]
		mm.set_instance_transform(i, Transform3D(Basis(), p + y_offset))
		mm.set_instance_color(i, _instance_tint(p.x, p.z))
	var mmi := MultiMeshInstance3D.new()
	mmi.multimesh = mm
	add_child(mmi)
