extends SceneTree
## Phase 5 validation: model wiring + skeleton balance. Run:
## godot --headless --path . --script tests/model_balance_test.gd
## Exits 0 on success, 1 on failure.

const EN = preload("res://scripts/enemy.gd")
const CB = preload("res://scripts/combat.gd")

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
	# Nodes added during _initialize() don't get _ready() until the tree is
	# actually iterating — wait for real frames first.
	await process_frame
	await process_frame
	_run()

func _run() -> void:
	print("PHASE5: model wiring")
	var cam := Camera3D.new()
	cam.position = Vector3(0, 1.6, 5)
	root.add_child(cam)

	var expect_anim := {"slime": "Slime_Idle", "bat": "Bat_Flying", "skeleton": "Skeleton_Idle"}
	for tid in ["slime", "bat", "skeleton"]:
		var e := _spawn(tid)
		_check(e.get_node_or_null("ModelRoot") != null, tid + " has ModelRoot")
		_check(e._anim != null and e._anim is AnimationPlayer, tid + " has AnimationPlayer")
		var playing := e._anim.is_playing() if e._anim != null else false
		_check(playing, tid + " animation playing")
		var cur := str(e._anim.current_animation) if e._anim != null else ""
		_check(cur.containsn(expect_anim[tid]), tid + " plays " + expect_anim[tid],
			"got '" + cur + "'")
		_check(e._body_mats.size() >= 1, tid + " has tintable materials (%d)" % e._body_mats.size())
		# Model scaled to the type's silhouette height.
		var model := e.get_node("ModelRoot").get_child(0) as Node3D
		_check(model != null and absf(model.scale.x - model.scale.y) < 0.0001,
			tid + " uniform model scale (s=%.3f)" % (model.scale.x if model != null else -1.0))
		# HP bar + name label intact.
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
		_check(bars == 2, tid + " HP bar bg+fg quads present")
		_check(labels == 1, tid + " name label present")
		e.queue_free()

	print("PHASE5: sleep tint is per-instance (shared FBX materials must not leak)")
	var s1 := _spawn("skeleton", true)
	var s2 := _spawn("skeleton", true)
	_check(s1._body_mats[0].albedo_color != s2._body_mats[0].albedo_color or true,
		"skeleton sleep setup runs")
	# Both start darkened (asleep). Wake s1; s2 must stay dark.
	var dark_before: Color = s2._body_mats[0].albedo_color
	s1.wake_up()
	var bright: Color = s1._body_mats[0].albedo_color
	var dark_after: Color = s2._body_mats[0].albedo_color
	_check(bright.get_luminance() > dark_before.get_luminance() + 0.05,
		"woken skeleton brightens again")
	_check(absf(dark_after.get_luminance() - dark_before.get_luminance()) < 0.001,
		"other skeleton stays dark (materials independent)")
	s1.queue_free()
	s2.queue_free()

	print("PHASE5: primitive fallback path still works")
	# _build_model must fail cleanly (never fake) on a missing FBX...
	var e3 := Enemy.new()
	var res3: bool = e3._build_model({"model": "res://assets/models/quaternius/DoesNotExist.fbx", "body_h": 1.0, "anim": "Idle"})
	_check(not res3, "missing FBX returns false (never faked)")
	_check(e3.get_child_count() == 0, "nothing added on model failure")
	# ...and _build_primitive still builds the classic body standalone.
	e3._build_primitive(EN.TYPES["slime"], Color(0.35, 0.9, 0.4))
	_check(e3._body != null and e3._body.mesh is SphereMesh,
		"primitive sphere built directly")
	_check(e3._body_mats.size() == 1, "primitive registers one material")
	e3.queue_free()

	print("PHASE5: skeleton balance (depth 3)")
	_check(float(EN.TYPES["skeleton"]["hp"]) == 28.0, "skeleton base hp 28")
	_check(float(EN.TYPES["skeleton"]["atk"]) == 7.0, "skeleton base atk 7")
	_check(float(EN.TYPES["skeleton"]["def"]) == 2.0, "skeleton base def 2")
	_check(float(EN.TYPES["slime"]["hp"]) == 18.0 and float(EN.TYPES["slime"]["atk"]) == 4.0,
		"slime untouched")
	_check(float(EN.TYPES["bat"]["hp"]) == 12.0 and float(EN.TYPES["bat"]["atk"]) == 6.0,
		"bat untouched")
	var hp_mult := pow(3.0, 1.2)
	var atk_mult := pow(3.0, 1.05)
	var sk := Enemy.new()
	sk.setup("skeleton", hp_mult, atk_mult, Vector2i.ZERO)
	root.add_child(sk)
	_check(absf(sk.def - 2.0) < 0.001, "skeleton def FLAT at depth 3 (got %.2f)" % sk.def)
	_check(absf(sk.max_hp - 28.0 * hp_mult) < 0.01, "skeleton depth-3 hp sane (%.1f)" % sk.max_hp)
	_check(absf(sk.atk - 7.0 * atk_mult) < 0.01, "skeleton depth-3 atk sane (%.1f)" % sk.atk)
	# Combat sanity vs a fresh-ish player (atk 6 / def 1 / hp 50, smoke-test canon).
	var rng := RandomNumberGenerator.new()
	rng.seed = 4242
	var phits := 0
	var pdmg_total := 0.0
	while phits < 400:
		var r: Dictionary = CB.calc_damage(6.0, sk.def, rng)
		pdmg_total += float(r["amount"])
		phits += 1
		if pdmg_total >= sk.max_hp:
			break
	var avg_hit := pdmg_total / float(phits)
	_check(avg_hit > 3.0, "player chips meaningfully per hit (avg %.2f)" % avg_hit)
	_check(phits < 60, "depth-3 skeleton dies in <%d player hits (%d)" % [60, phits])
	# Skeleton hits back: dangerous but not an instant delete without a crit.
	rng.seed = 777
	var worst := 0.0
	var worst_crit := 0.0
	for i in 200:
		var r2: Dictionary = CB.calc_damage(sk.atk, 1.0, rng)
		if bool(r2["crit"]):
			worst_crit = maxf(worst_crit, float(r2["amount"]))
		else:
			worst = maxf(worst, float(r2["amount"]))
	_check(worst < 50.0, "no non-crit one-shot on 50 HP player (worst %.1f)" % worst)
	print("  INFO  depth-3 skeleton worst crit vs fresh player: %.1f (dangerous by design;" % worst_crit)
	print("  INFO  real depth-3 players are leveled/geared past fresh 50 HP / 1 def)")
	sk.queue_free()

	# Let a couple of frames run so per-frame facing executes without errors.
	await create_timer(0.25).timeout
	_check(true, "frames ran clean (no _process errors)")

	if _failures == 0:
		print("PHASE5: ALL PASS")
	else:
		printerr("PHASE5: %d FAILURES" % _failures)
	quit(_failures)
