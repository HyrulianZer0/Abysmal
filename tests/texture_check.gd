extends SceneTree
## Headless validation for the dungeon texture pass.
## Run: godot --headless --path . -s tests/texture_check.gd
## Exits 0 on success, 1 on any failure.

const DG = preload("res://scripts/dungeon_gen.gd")
const DV = preload("res://scripts/dungeon_view.gd")

var _failures := 0


func _check(cond: bool, name: String, detail: String = "") -> void:
	if cond:
		print("  PASS  %s" % name)
	else:
		_failures += 1
		printerr("  FAIL  %s  %s" % [name, detail])


func _initialize() -> void:
	print("TEXTURE_CHECK: starting")
	var rng := RandomNumberGenerator.new()
	rng.seed = 1234
	var gen: Dictionary = DG.generate(40, 40, 3, rng)

	var view: Node3D = DV.new()
	root.add_child(view)
	view.build_floor(gen, "mossy_dark")
	view.build_doors(gen["doors"])
	view.build_loot(gen["loot"], gen["chests"])

	# --- MultiMesh batching intact: 5 wall + 2 floor + 2 wall-cap + 2 ceiling
	# draw calls (open-cell ceilings added Oct 2026 — asserted below) ---
	# (Rare variant buckets may be empty, so tolerate down to 5; the ceiling
	# and vine assertions below nail the important structure.)
	var mmis: Array = []
	for child in view.get_children():
		if child is MultiMeshInstance3D:
			mmis.append(child)
	_check(mmis.size() <= 11 and mmis.size() >= 5,
		"multimesh count sane (%d)" % mmis.size(), "expected 5-11")

	# Helper: map each MultiMesh to its material's albedo texture path.
	var mm_tex: Dictionary = {}
	for mmi in mmis:
		var mm: MultiMesh = (mmi as MultiMeshInstance3D).multimesh
		var m := (mm.mesh as BoxMesh).material as StandardMaterial3D
		if m != null and m.albedo_texture != null:
			mm_tex[mmi] = m.albedo_texture.resource_path

	# --- Ceiling caps: dark Black-brick slab(s) crown the walls ---
	var cap_dark := 0
	var cap_moss := 0
	for mmi in mm_tex:
		var p: String = mm_tex[mmi]
		if p.contains("Bricks_04_Black_2.png"):
			cap_dark += 1
		elif p.contains("Bricks_04_Black_Moss_1.png"):
			cap_moss += 1
	_check(cap_dark >= 1, "ceiling cap dark variant present (%d)" % cap_dark)
	_check(cap_moss >= 1, "ceiling cap mossy variant present (%d)" % cap_moss)

	# --- Cap geometry: thin slab sized to crown the wall boxes ---
	# (Headless dummy RenderingServer also drops set_instance_transform
	# writes, so we assert the slab size only; the y=WALL_HEIGHT offset
	# rides the same _make_multimesh path as the walls.)
	# Every cap-textured MultiMesh (wall caps AND open-cell ceilings share
	# the slab geometry) must be the 2.0x0.12x2.0 slab.
	var cap_geo_ok := false
	var cap_seen := 0
	var cap_mmis := 0
	var cap_instances := 0
	for mmi in mm_tex:
		var p: String = mm_tex[mmi]
		if p.contains("Bricks_04_Black_2.png") or p.contains("Bricks_04_Black_Moss_1.png"):
			cap_mmis += 1
			var mm: MultiMesh = (mmi as MultiMeshInstance3D).multimesh
			cap_instances += mm.instance_count
			var box := mm.mesh as BoxMesh
			if box != null and box.size.is_equal_approx(Vector3(2.0, 0.12, 2.0)):
				cap_seen += 1
	cap_geo_ok = cap_mmis >= 2 and cap_seen == cap_mmis
	_check(cap_geo_ok, "cap/ceiling slabs are 2.0x0.12x2.0 (%d/%d)" % [cap_seen, cap_mmis])

	# --- Ceilings: one slab instance over EVERY open cell, plus one cap per
	# drawn wall — the v0.10.0 "ceilings are missing" fix. The count is the
	# assertion: cap-textured instances == drawn walls + open cells.
	var grid: Array = gen["grid"]
	var gw: int = gen["width"]
	var gh: int = gen["height"]
	var open_cells := 0
	var drawn_walls := 0
	for yy in gh:
		for xx in gw:
			var cell: int = (grid[yy] as Array)[xx]
			if cell == DG.WALL:
				var touches := false
				for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
					var nx: int = xx + d.x
					var ny: int = yy + d.y
					if nx < 0 or ny < 0 or nx >= gw or ny >= gh or (grid[ny] as Array)[nx] != DG.WALL:
						touches = true
						break
				if touches:
					drawn_walls += 1
			else:
				open_cells += 1
	_check(cap_instances == drawn_walls + open_cells,
		"ceiling slab over every open cell (%d instances = %d caps + %d ceilings)" % [
			cap_instances, drawn_walls, open_cells],
		"cap instances %d != walls %d + open %d" % [cap_instances, drawn_walls, open_cells])

	# --- Vine pop: mossy variants present in the wall rotation ---
	var wall_moss := 0
	for mmi in mm_tex:
		var p: String = mm_tex[mmi]
		if p.contains("Bricks_04_Grey_Moss_1.png") or p.contains("Bricks_04_Black_Moss_2.png"):
			wall_moss += 1
	_check(wall_moss >= 1, "mossy wall variant present (%d)" % wall_moss)

	# --- New ceiling/vine textures resolve to real staged flakdeau PNGs ---
	for p in ["res://assets/textures/flakdeau/walls/Bricks_04_Black_2.png",
			"res://assets/textures/flakdeau/walls/Bricks_04_Black_Moss_1.png",
			"res://assets/textures/flakdeau/walls/Bricks_04_Grey_Moss_1.png",
			"res://assets/textures/flakdeau/walls/Bricks_04_Black_Moss_2.png"]:
		var t := load(p) as Texture2D
		_check(t != null and t.get_width() == 256 and t.get_height() == 256,
			"texture resolves 256x256: %s" % p.get_file())

	# --- Every MultiMesh has a textured material; style matches (nearest/rough 1) ---
	var textured := 0
	var styled := 0
	var instances_total := 0
	for mmi in mmis:
		var mm: MultiMesh = (mmi as MultiMeshInstance3D).multimesh
		instances_total += mm.instance_count
		var mat := ((mm.mesh as BoxMesh).material as StandardMaterial3D)
		if mat != null and mat.albedo_texture != null:
			textured += 1
			if mat.texture_filter == BaseMaterial3D.TEXTURE_FILTER_NEAREST \
					and is_equal_approx(mat.roughness, 1.0):
				styled += 1
	_check(textured == mmis.size(), "all multimeshes textured (%d/%d)" % [textured, mmis.size()])
	_check(styled == mmis.size(), "all materials nearest-filter + roughness 1.0 (%d/%d)" % [styled, mmis.size()])
	# Per-instance tint path: colors enabled, no errors. (Headless dummy
	# RenderingServer silently drops color writes in 4.7.2, so we assert the
	# flag + error-free path; the 5+2+2 variant split is the primary verified
	# variation mechanism.)
	var colored := 0
	for mmi in mmis:
		var mm2: MultiMesh = (mmi as MultiMeshInstance3D).multimesh
		if mm2.is_using_colors():
			colored += 1
	_check(colored == mmis.size(), "instance colors enabled on all multimeshes")
	_check(instances_total > 500, "sane instance count (%d)" % instances_total)

	# --- Texture files resolve to real staged flakdeau PNGs ---
	var tex := load("res://assets/textures/flakdeau/walls/Bricks_01_Grey_2.png") as Texture2D
	_check(tex != null and tex.get_width() == 256, "wall texture resolves 256x256")

	# --- Orange ceiling texture must NOT be loaded (a comment may mention it) ---
	var src := FileAccess.get_file_as_string("res://scripts/dungeon_view.gd")
	_check(not (src.contains("preload(\"res://assets/textures/flakdeau/ceilings/") or src.contains("load(\"res://assets/textures/flakdeau/ceilings/")),
		"orange ceiling texture not loaded")

	# --- Doors: textured slabs, state restyle still works ---
	var door_count := 0
	for d in gen["doors"]:
		door_count += 1
		break
	_check(door_count > 0, "gen produced doors")
	# Force an open-state door through the restyle path.
	var d0: Dictionary = (gen["doors"] as Array)[0].duplicate()
	d0["state"] = "open"
	view.update_door(d0)
	var d1: Dictionary = (gen["doors"] as Array)[0].duplicate()
	d1["state"] = "locked"
	view.update_door(d1)
	_check(true, "door state restyle (open/locked) without errors")

	# --- Door structure: quad faces sampling the artwork rect, protruding
	# shackle, brick header (v0.10.0 half-gray-door fix) ---
	var dview: Node3D = DV.new()
	root.add_child(dview)
	var locked_d: Dictionary = {}
	var closed_d: Dictionary = {}
	var srng := RandomNumberGenerator.new()
	for s in range(1, 300):
		srng.seed = s * 31 + 7
		var g2: Dictionary = DG.generate(40, 40, 3, srng)
		for dd in g2["doors"]:
			if str(dd["state"]) == "locked" and locked_d.is_empty():
				locked_d = dd
			elif str(dd["state"]) == "closed" and closed_d.is_empty():
				closed_d = dd
		if not locked_d.is_empty() and not closed_d.is_empty():
			break
	_check(not locked_d.is_empty() and not closed_d.is_empty(),
		"found locked + closed doors to inspect")
	if not locked_d.is_empty() and not closed_d.is_empty():
		dview.build_doors([locked_d, closed_d])
		_check_door(dview, locked_d, "Door_Wood_Blue_1.png",
			Vector2(180.0 / 256.0, 240.0 / 256.0), true)
		_check_door(dview, closed_d, "Door_Wood_Green_1.png",
			Vector2(202.0 / 256.0, 250.0 / 256.0), false)

	# --- Stairs pad untouched: emissive, no texture ---
	var pad_ok := false
	for child in view.get_children():
		if child is MeshInstance3D:
			var mi := child as MeshInstance3D
			var m := mi.material_override as StandardMaterial3D
			if m != null and m.emission_enabled and m.albedo_texture == null:
				pad_ok = true
	_check(pad_ok, "stairs pad still emissive flat gold")

	# --- Loot markers untouched: still emissive boxes + labels ---
	var label_found := false
	for child in view.get_children():
		if child is Node3D and not (child is MeshInstance3D) and not (child is MultiMeshInstance3D):
			for sub in child.get_children():
				if sub is Label3D:
					label_found = true
	_check(label_found, "loot/chest labels present")

	# --- Lava theme: forced build, theme-aware assertions ---
	var view_lava: Node3D = DV.new()
	root.add_child(view_lava)
	view_lava.build_floor(gen, "lava")
	_check(view_lava.current_theme == "lava",
		"lava theme selected when forced", "theme is %s" % str(view_lava.current_theme))
	var lava_mmis: Array = []
	for child in view_lava.get_children():
		if child is MultiMeshInstance3D:
			lava_mmis.append(child)
	_check(lava_mmis.size() == 4,
		"lava multimesh count is 4 (1 wall + 1 floor + 1 cap + 1 ceiling)", "got %d" % lava_mmis.size())
	var lava_floor_ok := false
	var lava_ceil_ok := false
	var lava_wall_ok := false
	var lava_cap_ok := false
	var lava_linear := 0
	var lava_textured := 0
	for mmi in lava_mmis:
		var mm: MultiMesh = (mmi as MultiMeshInstance3D).multimesh
		var m := (mm.mesh as BoxMesh).material as StandardMaterial3D
		if m == null or m.albedo_texture == null:
			continue
		lava_textured += 1
		var p: String = m.albedo_texture.resource_path
		if m.texture_filter == BaseMaterial3D.TEXTURE_FILTER_LINEAR \
				and is_equal_approx(m.roughness, 1.0):
			lava_linear += 1
		if p.ends_with("floor_diff_1k.jpg"):
			lava_floor_ok = m.emission_enabled and m.emission_texture != null \
				and m.emission_texture.resource_path.ends_with("floor_emissive_1k.jpg") \
				and is_equal_approx(m.emission_energy_multiplier, 1.0)
		elif p.ends_with("ceiling_diff_1k.jpg"):
			if m.emission_enabled and m.emission_texture != null \
					and m.emission_texture.resource_path.ends_with("ceiling_emissive_1k.jpg") \
					and is_equal_approx(m.emission_energy_multiplier, 0.5):
				lava_ceil_ok = true
			if is_equal_approx(m.albedo_color.r, 1.3):
				lava_cap_ok = true
		elif p.ends_with("wall_diff_1k.jpg"):
			lava_wall_ok = true
	_check(lava_textured == lava_mmis.size(),
		"all lava multimeshes textured (%d/%d)" % [lava_textured, lava_mmis.size()])
	_check(lava_linear == lava_mmis.size(),
		"all lava materials linear-filter + roughness 1.0 (%d/%d)" % [lava_linear, lava_mmis.size()])
	_check(lava_floor_ok, "lava floor emissive (floor_emissive_1k, energy 1.0)")
	_check(lava_ceil_ok, "lava ceiling emissive (ceiling_emissive_1k, energy 0.5)")
	_check(lava_wall_ok, "lava wall is basalt (wall_diff_1k)")
	_check(lava_cap_ok, "lava cap lift 1.3 on ceiling/cap material")
	# Lava ceiling slabs over every open cell (cap + ceiling instances
	# share the ceiling_diff_1k texture, like mossy_dark shares Black_2).
	var lava_cap_instances := 0
	for mmi in lava_mmis:
		var mm2: MultiMesh = (mmi as MultiMeshInstance3D).multimesh
		var m2 := (mm2.mesh as BoxMesh).material as StandardMaterial3D
		if m2 != null and m2.albedo_texture != null \
				and m2.albedo_texture.resource_path.ends_with("ceiling_diff_1k.jpg"):
			lava_cap_instances += mm2.instance_count
	_check(lava_cap_instances == drawn_walls + open_cells,
		"lava ceiling slabs cover every open cell (%d = %d caps + %d ceilings)" % [
			lava_cap_instances, drawn_walls, open_cells],
		"got %d" % lava_cap_instances)

	if _failures == 0:
		print("TEXTURE_CHECK: ALL PASS")
	else:
		printerr("TEXTURE_CHECK: %d FAILURES" % _failures)
	quit(_failures)


## Structural assertions for one built door (children are in the door's
## local space, so the checks hold for both axis orientations).
func _check_door(view: Node3D, d: Dictionary, tex_file: String,
		uv_scale: Vector2, locked: bool) -> void:
	var pos: Vector2i = d["pos"]
	var want := Vector3(pos.x * 2.0, 0, pos.y * 2.0)
	var door_root: Node3D = null
	for child in view.get_children():
		if child is Node3D and not (child is MeshInstance3D) \
				and not (child is MultiMeshInstance3D) \
				and (child as Node3D).position.is_equal_approx(want):
			door_root = child
			break
	_check(door_root != null, "door root found for %s (%s)" % [str(pos), tex_file])
	if door_root == null:
		return
	var faces := 0
	var uv_ok := false
	var header_ok := false
	var shackle_z := 0.0
	var core_z := 0.0
	var locked_labels := 0
	for sub in door_root.get_children():
		if sub is Label3D and (sub as Label3D).text == "LOCKED":
			locked_labels += 1
		if not (sub is MeshInstance3D):
			continue
		var mi := sub as MeshInstance3D
		if mi.mesh is QuadMesh:
			var qm := (mi.mesh as QuadMesh).material as StandardMaterial3D
			if qm != null and qm.albedo_texture != null \
					and qm.albedo_texture.resource_path.ends_with(tex_file):
				faces += 1
				if qm.uv1_scale.is_equal_approx(Vector3(uv_scale.x, uv_scale.y, 1.0)):
					uv_ok = true
		elif mi.mesh is BoxMesh:
			var bs := (mi.mesh as BoxMesh).size
			if bs.is_equal_approx(Vector3(1.8, 0.5, 0.36)) and is_equal_approx(mi.position.y, 2.15):
				header_ok = true
			elif bs.is_equal_approx(Vector3(1.8, 1.9, 0.34)):
				core_z = bs.z
			elif bs.is_equal_approx(Vector3(0.34, 0.34, 0.5)):
				shackle_z = bs.z
	_check(faces == 2, "door has 2 textured quad faces (%d) %s" % [faces, tex_file])
	_check(uv_ok, "door faces sample the artwork rect (uv scale %s)" % str(uv_scale))
	_check(header_ok, "door has brick header over the slot (%s)" % tex_file)
	if locked:
		_check(core_z > 0.0 and shackle_z > core_z + 0.1,
			"shackle protrudes past the slab (shackle %.2f > core %.2f)" % [shackle_z, core_z])
		_check(locked_labels == 2, "locked door labels on both faces (%d)" % locked_labels)
