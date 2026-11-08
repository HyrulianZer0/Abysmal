extends SceneTree
## Wave 1 + Wave 2/2b placeholder models: every PROCEDURAL monster type
## builds its primitive composite without errors, with a distinct
## silhouette, working HP bar / name label / sleep tint / damage flash
## plumbing, and the facing hook (_model_root) wired like the FBX
## models. Wave 2/2b wired types (18) are covered by
## tests/monster_models_test.gd instead and are excluded from the
## PlaceholderBody loops below. Also guards that the original three
## types still take the model path, that TYPES holds the 28 staged types
## + the 272 bestiary types (Nov 8, 2026 expansion), and — the Wave 3 contract that
## REPLACES the old staged-only spawn guard — that the spawn picker
## names staged types ONLY through its depth-banded spawn table (the
## guard was lifted on purpose: Wave 3 wires spawning).
##
## Run: godot --headless --path . --script tests/placeholder_models_test.gd
## Exits 0 on pass, 1 on any failure.

const EN = preload("res://scripts/enemy.gd")

const NEW_TYPES := ["rat", "spider", "snake", "wasp", "frog",
		"wolf", "goblin", "zombie", "ghost", "golem",
		"boar", "scorpion", "centipede", "skeleton_archer", "kobold",
		"imp", "pixie", "orc", "troll", "minotaur",
		"harpy", "oni", "kappa", "drake", "banshee"]

## Wave 5 (Nov 2, 2026): no procedural types remain — all 25 staged types
## are wired models (monster_models_test.gd). The PlaceholderBody loops
## below now run over an empty set; the banshee translucency and zombie
## sleep checks run against model-path _body_mats instead.
const PROCEDURAL_TYPES := []  # Wave 5 (Nov 2, 2026): all 7 former procedural types wired; none left.

var _failures := 0


func _check(cond: bool, name: String, detail: String = "") -> void:
	if cond:
		print("  PASS  " + name)
	else:
		_failures += 1
		printerr("  FAIL  " + name + "  " + detail)


func _spawn(tid: String, asleep: bool = false) -> Enemy:
	var e := Enemy.new()
	e.setup(tid, 1.0, 1.0, Vector2i(3, 3))
	e.asleep = asleep
	root.add_child(e)
	return e


func _initialize() -> void:
	await process_frame
	await process_frame
	_run()


func _count_tree(e: Enemy) -> Dictionary:
	var bars := 0
	var labels := 0
	var stack: Array = [e]
	while not stack.is_empty():
		var n: Node = stack.pop_back()
		if n is MeshInstance3D and (n as MeshInstance3D).mesh is QuadMesh:
			bars += 1
		if n is Label3D and str((n as Label3D).text) == e.display_name:
			labels += 1
		for c in n.get_children():
			stack.push_back(c)
	return {"bars": bars, "labels": labels}


func _run() -> void:
	print("PLACEHOLDERS: table shape")
	_check(EN.TYPES.size() == 300, "TYPES has 300 entries (28 staged + 272 bestiary)",
			"got %d" % EN.TYPES.size())
	print("PLACEHOLDERS: Wave 3 spawn contract (guard lifted, bands rule)")
	var DG2 = load("res://scripts/dungeon_gen.gd")
	var deep_table: Array = DG2.spawn_table(30)
	var deep_types := []
	for entry in deep_table:
		deep_types.append(str(entry[0]))
	for tid in NEW_TYPES:
		_check(deep_types.has(tid),
				"spawn picker names staged type " + tid + " at depth 30")
	for entry in deep_table:
		_check(EN.TYPES.has(str(entry[0])),
				"spawn table entry " + str(entry[0]) + " is a staged type, never apex")
	for tid in NEW_TYPES:
		_check(EN.TYPES.has(tid), "TYPES has " + tid)
		if EN.TYPES.has(tid):
			_check(str(EN.TYPES[tid].get("build", "")) == tid,
					tid + " build key wired")

	var cam := Camera3D.new()
	cam.position = Vector3(0, 1.6, 5)
	root.add_child(cam)

	print("PLACEHOLDERS: per-type build")
	var sizes := {}
	for tid in PROCEDURAL_TYPES:
		var e := _spawn(tid)
		var root_node := e.get_node_or_null("PlaceholderBody")
		_check(root_node != null, tid + " builds PlaceholderBody")
		if root_node == null:
			e.queue_free()
			continue
		_check(e._model_root == root_node, tid + " facing root is _model_root")
		var parts := 0
		var shadows_ok := true
		for c in root_node.get_children():
			if c is MeshInstance3D:
				parts += 1
				if (c as MeshInstance3D).cast_shadow != GeometryInstance3D.SHADOW_CASTING_SETTING_ON:
					shadows_ok = false
		_check(parts >= 4, tid + " composite has >=4 parts", "got %d" % parts)
		_check(shadows_ok, tid + " part shadows match existing monsters (ON)")
		_check(e._body_mats.size() >= 2, tid + " tintable materials (%d)" % e._body_mats.size())
		var counts := _count_tree(e)
		_check(int(counts["bars"]) == 2, tid + " HP bar bg+fg quads present")
		_check(int(counts["labels"]) == 1, tid + " name label present")
		var box: AABB = e._measure_aabb(root_node)
		sizes[tid] = box.size
		_check(box.size.y > 0.2 and box.size.y < 1.8,
				tid + " height in sane band (%.2f)" % box.size.y)
		_check(box.size.x > 0.15 and box.size.z > 0.15,
				tid + " footprint sane (%.2f x %.2f)" % [box.size.x, box.size.z])
		# Damage path: flash + bar shrink must run clean on composite mats.
		var hp0 := e.hp
		_check(not e.take_damage(2.0) and e.hp < hp0, tid + " takes damage, bar updates")
		e.queue_free()

	print("PLACEHOLDERS: silhouettes are distinct")
	var ids := sizes.keys()
	for i in ids.size():
		for j in range(i + 1, ids.size()):
			var a: Vector3 = sizes[ids[i]]
			var b: Vector3 = sizes[ids[j]]
			var distinct := absf(a.x - b.x) > 0.05 or absf(a.y - b.y) > 0.05 \
					or absf(a.z - b.z) > 0.05
			_check(distinct, "%s vs %s silhouettes differ" % [ids[i], ids[j]],
					"%s vs %s" % [str(a), str(b)])

	print("PLACEHOLDERS: banshee translucency")
	# NOTE (Wave 5, Nov 2, 2026): the banshee is now a wired model too — its
	# translucent shroud is carried by its own materials (body materials
	# BLEND alpha 0.7 in the wired copy, per its guide; eyes stay opaque),
	# so this check runs against the model path's _body_mats, not a placeholder.
	var b := _spawn("banshee")
	var banshee_transparent := false
	for m in b._body_mats:
		if m.transparency == BaseMaterial3D.TRANSPARENCY_ALPHA and m.albedo_color.a < 0.9:
			banshee_transparent = true
	_check(banshee_transparent, "banshee has a translucent material")
	b.queue_free()

	print("PLACEHOLDERS: sleep tint + wake on a composite")
	# Wave 5 (Nov 2, 2026): zombie is a wired model now, so this sleep check
	# runs against the model path's shared _body_mats plumbing (same as
	# the wolf sleep tint before it).
	var w := _spawn("zombie", true)
	_check(w._sleep_label != null, "asleep zombie shows z z label")
	var dark_lum := 0.0
	for m in w._body_mats:
		dark_lum += m.albedo_color.get_luminance()
	w.wake_up()
	var bright_lum := 0.0
	for m in w._body_mats:
		bright_lum += m.albedo_color.get_luminance()
	_check(bright_lum > dark_lum + 0.1, "woken zombie brightens (%.2f -> %.2f)" % [dark_lum, bright_lum])
	w.queue_free()

	print("PLACEHOLDERS: facing yaw follows travel direction")
	var r := _spawn("rat")
	r.facing = Vector2i(1, 0)
	await process_frame
	await process_frame
	_check(is_instance_valid(r._model_root)
			and absf(wrapf(r._model_root.rotation.y - atan2(-1.0, 0.0), -PI, PI)) < 0.01,
			"rat root yaws to facing", "rot.y=%.3f" % (r._model_root.rotation.y if is_instance_valid(r._model_root) else -999.0))
	r.queue_free()

	print("PLACEHOLDERS: original three still take the model path")
	for tid in ["slime", "bat", "skeleton"]:
		var e := _spawn(tid)
		_check(e.get_node_or_null("ModelRoot") != null, tid + " has ModelRoot (FBX)")
		_check(e.get_node_or_null("PlaceholderBody") == null, tid + " no placeholder")
		e.queue_free()

	if _failures == 0:
		print("PLACEHOLDERS: ALL PASS")
	else:
		printerr("PLACEHOLDERS: %d FAILURES" % _failures)
	quit(_failures)
