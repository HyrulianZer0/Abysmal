extends SceneTree
## Wave 2 model wiring (Oct 29, 2026): every wired type spawns its real
## model at the registry target size, grounded (or hovering for
## flyers), with junk nodes removed, PS1 textures re-linked, and no
## HELD file or human-stand-in mapping anywhere. Procedural types keep
## their placeholder bodies with procedural idle motion. Balance is
## untouched (setup()/scaling curves are not re-tested here — the
## staged-monsters suite still pins them).
##
## Run: godot --headless --path . --script tests/monster_models_test.gd
## Exits 0 on pass, 1 on any failure.
## NOTE: wired models must be editor-imported first (their .import
## files); a missing import makes _build_model fall back to the
## placeholder and the ModelRoot checks below fail loudly, by design.

const EN = preload("res://scripts/enemy.gd")
const MM = preload("res://scripts/monster_models.gd")

const WIRED := ["rat", "spider", "snake", "wolf", "goblin", "ghost", "golem",
		"boar", "scorpion", "centipede", "skeleton_archer", "imp", "orc",
		"troll", "minotaur", "kappa", "drake", "kobold",
		"wasp", "frog", "zombie", "pixie", "harpy", "oni", "banshee"]
const PROCEDURAL := []  # Wave 5 (Nov 2, 2026): all 7 former procedural types wired; none left.
const LIVE := ["slime", "bat", "skeleton"]
## Nov 8, 2026 TYPES expansion: the 5 golem variants are ROSTER rows but
## NOT bestiary creatures (no INDEX row, no spec section); they stay out
## of TYPES until the variant-selection mechanism is decided.
const GOLEM_VARIANTS := ["golem-fire", "golem-ice", "golem-stone", "golem-storm", "golem-water"]
const ANIMATED := ["rat", "wolf", "ghost", "golem", "boar", "centipede", "imp",
		"orc", "troll", "minotaur", "drake"]
const TEXTURED := ["snake", "scorpion", "skeleton_archer"]
const JUNK := ["Plane", "Plane.001", "ShadowPlane", "Hair"]

var _failures := 0


func _check(cond: bool, name: String, detail: String = "") -> void:
	if cond:
		print("  PASS  " + name)
	else:
		_failures += 1
		printerr("  FAIL  " + name + "  " + detail)


func _spawn(tid: String) -> Enemy:
	var e := Enemy.new()
	e.setup(tid, 1.0, 1.0, Vector2i(3, 3))
	root.add_child(e)
	return e


func _has_node_named(e: Enemy, wanted: String) -> bool:
	var stack: Array = [e._model_root]
	while not stack.is_empty():
		var n: Node = stack.pop_back()
		if str(n.name) == wanted:
			return true
		for c in n.get_children():
			stack.push_back(c)
	return false


func _initialize() -> void:
	await process_frame
	await process_frame
	_run()


func _run() -> void:
	print("MODELS: registry data shape")
	for tid in WIRED:
		var reg: Dictionary = MM.for_type(tid)
		_check(not reg.is_empty(), tid + " has a registry entry")
		if reg.is_empty():
			continue
		var path := str(reg.get("model", ""))
		_check(FileAccess.file_exists(path), tid + " model file exists", path)
		_check(not MM.is_held_path(path), tid + " model is not HELD", path)
		_check(str(EN.TYPES[tid].get("model", "")) == path,
				tid + " TYPES model matches registry", str(EN.TYPES[tid].get("model", "")))
		_check(str(reg.get("norm_axis", "y")) in ["x", "y", "z"], tid + " norm_axis valid")
		_check(float(reg.get("target", 0.0)) >= 0.2 and float(reg.get("target", 0.0)) <= 3.0,
				tid + " target sane (%.2f)" % float(reg.get("target", 0.0)))
		var tex := str(reg.get("texture", ""))
		if tex != "":
			_check(FileAccess.file_exists(tex), tid + " texture file exists", tex)
	for rid in MM.ROSTER_MODELS.keys():
		var reg: Dictionary = MM.ROSTER_MODELS[rid]
		var path := str(reg.get("model", ""))
		_check(FileAccess.file_exists(path), "roster " + rid + " model file exists", path)
		_check(not MM.is_held_path(path), "roster " + rid + " model is not HELD", path)
		# Nov 8, 2026 TYPES expansion (director decision Nov 7): every
		# bestiary-path roster row now HAS a TYPES entry — one per bestiary
		# row, stats from family defaults (see design-notes/types-expansion-20261108.md).
		# The old "no TYPES entry (no invented stats)" guard is retired for
		# bestiary rows; it survives only for non-bestiary roster rows and
		# the golem variants, which must stay out of TYPES.
		if path.contains("/bestiary/") and not rid in GOLEM_VARIANTS:
			_check(EN.TYPES.has(rid), "roster bestiary " + rid + " has a TYPES entry", path)
			if EN.TYPES.has(rid):
				_check(str(EN.TYPES[rid].get("model", "")) == path,
						"roster bestiary " + rid + " TYPES model matches registry",
						str(EN.TYPES[rid].get("model", "")))
		else:
			_check(not EN.TYPES.has(rid), "roster non-bestiary " + rid + " has no TYPES entry")

	print("MODELS: no HELD file, no human stand-in anywhere")
	for tid in WIRED:
		var path := str(MM.for_type(tid).get("model", ""))
		_check(not path.contains("kenney"), tid + " does not use a Kenney humanoid", path)
		_check(not path.contains("minion"), tid + " does not use a Gobkit minion stand-in", path)
	# Wave 5 (Nov 2, 2026): the 7 former procedural types are wired above with
	# real guide-built models, so the old stays-procedural guard is retired.
	# Nov 1, 2026: kobold leaves the procedural set — James approved
	# goblin.glb as its fallback wire (stands unless a true kobold is
	# found), so it is WIRED above, not listed here.
	print("MODELS: Wave 2b visual-review + attribution flags")
	for tid in ["spider", "wolf", "golem"]:
		var note := str(MM.for_type(tid).get("note", ""))
		_check(note.contains("VISUAL REVIEW REQUIRED"),
				tid + " registry note flags visual review")
	_check(str(MM.for_type("golem").get("note", "")).contains("Fire/Ice/Stone Golem by umask007"),
			"golem registry note carries the REQUIRED attribution")
	_check(str(MM.for_type("spider").get("note", "")).contains("3DAssets.dev"),
			"spider registry note names the AI source")
	_check(str(MM.for_type("wolf").get("note", "")).contains("3DAssets.dev"),
			"wolf registry note names the AI source")
	_check(not MM.MODELS.has("skeleton"), "live skeleton keeps Quaternius (no fgc_skeleton wire)")
	_check(not MM.ROSTER_MODELS.has("fgc_skeleton"), "fgc_skeleton rejected, not even rostered")

	var cam := Camera3D.new()
	cam.position = Vector3(0, 1.6, 5)
	root.add_child(cam)

	print("MODELS: wired types spawn their model at target size")
	for tid in WIRED:
		var e := _spawn(tid)
		_check(e.get_node_or_null("ModelRoot") != null, tid + " has ModelRoot")
		_check(e.get_node_or_null("PlaceholderBody") == null, tid + " no placeholder")
		if e._model_root == null:
			e.queue_free()
			continue
		var reg: Dictionary = MM.for_type(tid)
		var box: AABB = e._measure_aabb(e._model_root)
		var axis := str(reg.get("norm_axis", "y"))
		var got: float = box.size.y
		if axis == "x":
			got = box.size.x
		elif axis == "z":
			got = box.size.z
		var want: float = float(reg.get("target", 0.0))
		_check(absf(got - want) < want * 0.1 + 0.01,
				tid + " norm_axis size ~ target (%.2f vs %.2f)" % [got, want])
		var y_off: float = float(reg.get("y_offset", 0.0))
		_check(absf(box.position.y - y_off) < 0.05,
				tid + " grounded/hovering (min y %.2f vs %.2f)" % [box.position.y, y_off])
		var model_node := e._model_root.get_child(0) as Node3D
		if model_node != null:
			var sc := model_node.scale
			_check(sc.x == sc.y and sc.y == sc.z, tid + " uniform scale")
			_check(sc.x > 0.0005 and sc.x < 5000.0, tid + " scale sane (%.1f)" % sc.x)
		for junk in JUNK:
			_check(not _has_node_named(e, junk), tid + " junk node removed: " + junk)
		if tid in ANIMATED:
			_check(e._anim != null and e._anim.is_playing(), tid + " animation playing")
			_check(not e._proc_motion, tid + " animated, no procedural motion")
			if e._anim != null:
				var names := e._anim.get_animation_list()
				for role in reg.get("clips", {}).keys():
					_check(str(reg["clips"][role]) in names,
							tid + " clip present: " + role + "=" + str(reg["clips"][role]))
			if tid == "troll":
				_check(e._anim != null and e._anim.current_animation == "Action",
						"troll plays first unnamed Action clip (mapping not invented)")
		else:
			_check(e._proc_motion, tid + " static model gets procedural motion")
			_check(e._anim == null or not e._anim.is_playing(), tid + " static model has no playing clip")
		if tid in TEXTURED:
			var all_tex := e._body_mats.size() > 0
			for m in e._body_mats:
				if m.albedo_texture == null:
					all_tex = false
			_check(all_tex, tid + " every surface has a texture (re-linked)")
		e.queue_free()

	print("MODELS: procedural types keep upgraded placeholders + motion")
	for tid in PROCEDURAL:
		var e := _spawn(tid)
		_check(e.get_node_or_null("PlaceholderBody") != null, tid + " builds PlaceholderBody")
		_check(e.get_node_or_null("ModelRoot") == null, tid + " no ModelRoot")
		_check(e._proc_motion, tid + " procedural idle motion on")
		_check(str(e._proc_profile) != "", tid + " motion profile set: " + str(e._proc_profile))
		e.queue_free()

	print("MODELS: live three unchanged")
	for tid in LIVE:
		var e := _spawn(tid)
		_check(e.get_node_or_null("ModelRoot") != null, tid + " has ModelRoot (FBX)")
		_check(not e._proc_motion, tid + " animated, no procedural motion")
		e.queue_free()

	print("MODELS: procedural motion actually moves the body")
	var s := _spawn("scorpion")
	var y0 := s._model_root.position.y
	var z0 := s._model_root.rotation.z
	s._process(0.4)
	_check(s._model_root.position.y != y0 or s._model_root.rotation.z != z0,
			"scorpion root moves under _process",
			"y %.4f->%.4f z %.4f->%.4f" % [y0, s._model_root.position.y, z0, s._model_root.rotation.z])
	s.queue_free()

	if _failures == 0:
		print("MODELS: ALL PASS")
	else:
		printerr("MODELS: %d FAILURES" % _failures)
	quit(_failures)
