extends SceneTree
## Wave 3 spawn-wiring tests: depth bands, weights, horde weak-only.
## Drives DungeonGen.spawn_table() + _pick_type() only — no floor gen,
## no models, no apex (apex must NEVER appear in spawn output).
##
## Run: godot --headless --path . --script tests/wave3_spawn_test.gd
## Exits 0 on pass, 1 on any failure.

const DG = preload("res://scripts/dungeon_gen.gd")
const EN = preload("res://scripts/enemy.gd")

const ALL_28 := ["slime", "bat", "skeleton", "rat", "spider", "snake",
		"wasp", "frog", "wolf", "goblin", "zombie", "ghost", "golem", "boar",
		"scorpion", "centipede", "skeleton_archer", "kobold", "imp", "pixie",
		"orc", "troll", "minotaur", "harpy", "oni", "kappa", "drake", "banshee"]
## Horde-legal: hp<=20, atk<=6, never caster/brute/tank/phase/grappler/ranged.
const HORDE_LEGAL := ["slime", "bat", "rat", "spider", "snake", "frog",
		"wasp", "centipede", "goblin", "kobold"]

var _failures := 0


func _check(cond: bool, name: String, detail: String = "") -> void:
	if cond:
		print("  PASS  " + name)
	else:
		_failures += 1
		printerr("  FAIL  " + name + "  " + detail)


func _table_types(depth: int, weak_only := false) -> Array:
	var out := []
	for entry in DG.spawn_table(depth, weak_only):
		out.append(str(entry[0]))
	return out


func _sample(depth: int, weak_only: bool, rolls: int) -> Dictionary:
	var rng := RandomNumberGenerator.new()
	rng.seed = 987654321
	var seen := {}
	for _i in rolls:
		var t: String = DG._pick_type(depth, rng, weak_only)
		seen[t] = true
	return seen


func _initialize() -> void:
	await process_frame
	_run()


func _run() -> void:
	print("WAVE3-SPAWN: every table entry is a real staged type, no apex")
	for d in [1, 2, 3, 4, 5, 6, 8, 10, 30, 72]:
		for t in _table_types(d):
			_check(EN.TYPES.has(t), "depth %d table type %s is staged" % [d, t])
			_check(not t.contains("cerberus") and t != "apex",
				"depth %d table has no apex (%s)" % [d, t])
		for t in _table_types(d, true):
			_check(HORDE_LEGAL.has(t), "depth %d horde type %s is weak-legal" % [d, t])

	print("WAVE3-SPAWN: depth bands gate correctly")
	_check(_table_types(1) == ["slime", "bat", "rat", "spider", "frog"],
		"depth 1 = gentle five only", str(_table_types(1)))
	_check(not _table_types(1).has("skeleton"), "depth 1 has no skeleton")
	_check(not _table_types(2).has("wolf"), "depth 2 has no wolf")
	_check(_table_types(3).has("wolf") and _table_types(3).has("zombie"),
		"depth 3 adds wolf + zombie")
	_check(not _table_types(3).has("imp"), "depth 3 has no imp (casters wait)")
	_check(_table_types(4).has("imp") and _table_types(4).has("pixie")
		and _table_types(4).has("skeleton_archer"), "depth 4 adds ranged + flyer/casters")
	_check(_table_types(5).has("ghost") and _table_types(5).has("golem")
		and _table_types(5).has("orc") and _table_types(5).has("harpy"),
		"depth 5 adds the D-band")
	_check(_table_types(6).has("troll") and _table_types(6).has("minotaur")
		and _table_types(6).has("oni") and _table_types(6).has("kappa"),
		"depth 6 adds heavy D-band")
	_check(not _table_types(6).has("banshee"), "depth 6 has no banshee (Dp waits)")
	_check(_table_types(8).has("drake") and _table_types(8).has("banshee"),
		"depth 8 adds drake + banshee")
	_check(_table_types(30).size() == 28, "depth 30 table holds all 28",
		"got %d" % _table_types(30).size())

	print("WAVE3-SPAWN: picker reaches the full roster at depth 30")
	var seen30 := _sample(30, false, 20000)
	for t in ALL_28:
		_check(seen30.has(t), "depth 30 picker returns " + t)
	print("WAVE3-SPAWN: picker reaches the full roster at depth 72")
	var seen72 := _sample(72, false, 20000)
	for t in ALL_28:
		_check(seen72.has(t), "depth 72 picker returns " + t)

	print("WAVE3-SPAWN: horde weak-only respected at every depth")
	for d in [1, 2, 3, 10, 30]:
		var seen := _sample(d, true, 8000)
		for t in seen:
			_check(HORDE_LEGAL.has(t), "depth %d horde never returns %s" % [d, t])
		_check(not seen.has("troll") and not seen.has("golem")
			and not seen.has("banshee") and not seen.has("orc")
			and not seen.has("pixie") and not seen.has("skeleton_archer")
			and not seen.has("ghost") and not seen.has("drake"),
			"depth %d horde has no brute/tank/caster/phase" % d)
	var seen_h1 := _sample(1, true, 8000)
	_check(seen_h1.has("slime") and seen_h1.has("bat") and seen_h1.has("rat"),
		"depth 1 horde has slime/bat/rat")
	_check(not seen_h1.has("goblin"), "depth 1 horde has no goblin yet")

	print("WAVE3-SPAWN: deep floors lean heavy but keep weak types")
	var w5 := 0.0
	var w10 := 0.0
	for entry in DG.spawn_table(5):
		if str(entry[0]) == "orc":
			w5 = float(entry[1])
	for entry in DG.spawn_table(10):
		if str(entry[0]) == "orc":
			w10 = float(entry[1])
	_check(absf(w10 - w5 * 1.5) < 0.001, "orc weight x1.5 at depth 10+",
		"5: %s 10: %s" % [str(w5), str(w10)])
	_check(_sample(30, false, 20000).has("slime"),
		"weak types still spawn at depth 30")

	print("WAVE3-SPAWN: weights are positive, picker never empty")
	for d in [1, 30]:
		for entry in DG.spawn_table(d):
			_check(float(entry[1]) > 0.0, "depth %d weight positive for %s" % [d, str(entry[0])])
	var rng := RandomNumberGenerator.new()
	rng.seed = 42
	_check(DG._pick_type(1, rng) != "", "picker returns a type at depth 1")

	if _failures == 0:
		print("WAVE3-SPAWN: ALL PASS")
	else:
		printerr("WAVE3-SPAWN: %d FAILURES" % _failures)
	quit(_failures)
