extends SceneTree
## Wave 3 fallback-archetype regression tests.
## The four space-form TYPES strings (rat "swarmer", wolf "pack
## skirmisher", ghost "phase skirmisher", scorpion "venom skirmisher")
## must resolve to their NAMED mechanics — not the brawler fallback.
## The TYPES strings themselves are NOT renamed (verbatim state
## archetype is asserted too); only the lookup canonicalizes.
##
## Run: godot --headless --path . --script tests/wave3_fallback_test.gd
## Exits 0 on pass, 1 on any failure.

const BV = preload("res://scripts/behaviors.gd")
const EN = preload("res://scripts/enemy.gd")

var _failures := 0


func _check(cond: bool, name: String, detail: String = "") -> void:
	if cond:
		print("  PASS  " + name)
	else:
		_failures += 1
		printerr("  FAIL  " + name + "  " + detail)


func _initialize() -> void:
	await process_frame
	_run()


func _run() -> void:
	print("WAVE3-FALLBACK: alias map")
	_check(BV.canonical_archetype("swarmer") == "swarm", "swarmer -> swarm")
	_check(BV.canonical_archetype("pack skirmisher") == "pack", "pack skirmisher -> pack")
	_check(BV.canonical_archetype("phase skirmisher") == "phase", "phase skirmisher -> phase")
	_check(BV.canonical_archetype("venom skirmisher") == "venom", "venom skirmisher -> venom")
	_check(BV.canonical_archetype("brawler") == "brawler", "brawler unchanged")
	_check(BV.canonical_archetype("flyer/skirmisher") == "flyer/skirmisher", "composites unchanged")

	print("WAVE3-FALLBACK: profiles are distinct, not brawler")
	for pair in [["swarmer", "nip"], ["pack skirmisher", "circle_burst"],
			["phase skirmisher", "phase_strike"], ["venom skirmisher", "flank_sting"]]:
		var prof: Dictionary = BV.profile_for(pair[0])
		_check(str(prof["special"]) == pair[1],
			pair[0] + " profile special = " + pair[1], str(prof["special"]))
		_check(str(prof["special"]) != "steady_melee",
			pair[0] + " profile is not the brawler fallback")

	print("WAVE3-FALLBACK: TYPES strings verbatim, state verbatim")
	for tid in ["rat", "wolf", "ghost", "scorpion"]:
		var e := Enemy.new()
		e.setup(tid, 1.0, 1.0, Vector2i(3, 3))
		root.add_child(e)
		_check(e.behavior_state.archetype == str(EN.TYPES[tid]["archetype"]),
			tid + " state archetype verbatim", e.behavior_state.archetype)
		e.queue_free()

	print("WAVE3-FALLBACK: rat swarm bonus fires")
	var rat := BV.new_state("swarmer", 10.0, 3.0, 0.0)
	rat.position = Vector2(3, 3)
	var rat_i := BV.update(rat, 0.1, {"player_pos": Vector2(3, 4), "allies": 0})
	_check(rat_i["attack_kind"] == "nip", "rat strike kind = nip", str(rat_i["attack_kind"]))
	var rat_i2 := BV.update(BV.new_state("swarmer", 10.0, 3.0, 0.0), 0.1,
		{"player_pos": Vector2(3, 4), "allies": 5})
	_check(absf(float(rat_i2["damage_mult"]) - 1.5) < 0.001,
		"rat swarm bonus caps at 1.5x with 5 allies", str(rat_i2["damage_mult"]))
	_check(float(rat_i["damage_mult"]) < float(rat_i2["damage_mult"]),
		"rat damage grows with allies")

	print("WAVE3-FALLBACK: wolf pack burst fires")
	var wolf := BV.new_state("pack skirmisher", 22.0, 7.0, 0.0)
	wolf.position = Vector2(3, 3)
	var wolf_solo := BV.update(wolf, 0.1, {"player_pos": Vector2(3, 4), "allies": 1})
	_check(wolf_solo["attack_kind"] != "burst", "wolf solo does not burst",
		str(wolf_solo["attack_kind"]))
	var wolf_pack := BV.update(BV.new_state("pack skirmisher", 22.0, 7.0, 0.0), 0.1,
		{"player_pos": Vector2(3, 4), "allies": 3})
	_check(wolf_pack["attack_kind"] == "burst", "wolf pack bursts at 3 allies",
		str(wolf_pack["attack_kind"]))
	_check(absf(float(wolf_pack["damage_mult"]) - 1.5) < 0.001,
		"wolf pack burst = 1.5x", str(wolf_pack["damage_mult"]))

	print("WAVE3-FALLBACK: ghost phase drift + shimmer + half damage")
	var ghost := BV.new_state("phase skirmisher", 15.0, 8.0, 0.0)
	ghost.position = Vector2(3, 3)
	var ghost_i := BV.update(ghost, 0.1, {"player_pos": Vector2(3, 6)})
	_check(ghost_i["action"] == "drift", "ghost drifts", str(ghost_i["action"]))
	_check(ghost_i["telegraph"] == "shimmer", "ghost shimmer tell",
		str(ghost_i["telegraph"]))
	_check(ghost.phase_drifting, "ghost phase_drifting set by update")
	_check(absf(BV.phase_damage_taken_mult(ghost) - 0.5) < 0.001,
		"drifting ghost takes half damage")

	print("WAVE3-FALLBACK: scorpion sting kind + tail_raised")
	var scorp := BV.new_state("venom skirmisher", 16.0, 5.0, 1.0)
	scorp.position = Vector2(3, 3)
	var scorp_i := BV.update(scorp, 0.1, {"player_pos": Vector2(3, 4)})
	_check(scorp_i["attack_kind"] == "sting", "scorpion strike kind = sting",
		str(scorp_i["attack_kind"]))
	_check(scorp_i["telegraph"] == "tail_raised", "scorpion tail_raised in range",
		str(scorp_i["telegraph"]))
	_check(scorp_i["action"] == "strike", "scorpion strikes in range",
		str(scorp_i["action"]))

	print("WAVE3-FALLBACK: enemy-level tick carries the named mechanics")
	var e := Enemy.new()
	e.setup("scorpion", 1.0, 1.0, Vector2i(3, 3))
	root.add_child(e)
	e.update_behavior(0.1, {"player_pos": Vector2(3, 4)})
	_check(e.behavior_attack_kind == "sting", "enemy scorpion attack_kind = sting",
		e.behavior_attack_kind)
	_check(e.behavior_telegraph == "tail_raised", "enemy scorpion telegraph",
		e.behavior_telegraph)
	e.queue_free()
	var g := Enemy.new()
	g.setup("ghost", 1.0, 1.0, Vector2i(3, 3))
	root.add_child(g)
	g.update_behavior(0.1, {"player_pos": Vector2(3, 6)})
	_check(g.behavior_action == "drift", "enemy ghost action = drift", g.behavior_action)
	_check(g.behavior_telegraph == "shimmer", "enemy ghost telegraph", g.behavior_telegraph)
	g.queue_free()

	if _failures == 0:
		print("WAVE3-FALLBACK: ALL PASS")
	else:
		printerr("WAVE3-FALLBACK: %d FAILURES" % _failures)
	quit(_failures)
