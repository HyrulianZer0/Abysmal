extends SceneTree
## Staged monster set (Wave 1 + Wave 2, Oct 27, 2026; model wiring
## Oct 29, 2026): every TYPES entry carries its consolidated data
## definition — family (from monster-roster-2026-10.md), depth band,
## behavior archetype, behavior text, and a sound spec — and every
## base stat obeys the LOCKED balance: hp_mult = depth^1.2,
## atk_mult = depth^1.05 (main.gd _new_depth), defense flat.
## Placeholders carry NO "model" key (honest placeholder claim); the 3
## live types plus the 17 Wave 2/2b wired types do (their models are
## pinned by tests/monster_models_test.gd). Nothing here touches
## spawning.
## Nov 8, 2026: TYPES grew to 300 (28 staged + 272 bestiary); the
## per-entry checks below still cover only the 28 staged types.
##
## Run: godot --headless --path . --script tests/staged_monsters_test.gd
## Exits 0 on pass, 1 on any failure.

const EN = preload("res://scripts/enemy.gd")

const LIVE_TYPES := ["slime", "bat", "skeleton"]
const STAGED_TYPES := ["rat", "spider", "snake", "wasp", "frog",
		"wolf", "goblin", "zombie", "ghost", "golem",
		"boar", "scorpion", "centipede", "skeleton_archer", "kobold",
		"imp", "pixie", "orc", "troll", "minotaur",
		"harpy", "oni", "kappa", "drake", "banshee"]
## Wave 2/2b wired types (real model in TYPES + monster_models.gd).
const WIRED_TYPES := ["rat", "spider", "snake", "wolf", "goblin", "ghost",
		"golem", "boar", "scorpion", "centipede", "skeleton_archer", "imp",
		"orc", "troll", "minotaur", "kappa", "drake", "kobold",
		"wasp", "frog", "zombie", "pixie", "harpy", "oni", "banshee"]
const BANDS := ["T", "D", "Dp", "A"]
const ARCHETYPES := ["brawler", "flyer/skirmisher", "swarmer", "ambusher",
		"flyer/swarm", "skirmisher", "pack skirmisher", "skirmisher/swarm",
		"tank/swarm", "phase skirmisher", "tank", "charger",
		"venom skirmisher", "ranged", "trapper/swarm", "flyer/caster",
		"brute", "tank/regen", "charger/brute", "flyer/skirmisher",
		"grappler/tank", "flyer/brute", "caster"]

var _failures := 0


func _check(cond: bool, name: String, detail: String = "") -> void:
	if cond:
		print("  PASS  " + name)
	else:
		_failures += 1
		printerr("  FAIL  " + name + "  " + detail)


func _initialize() -> void:
	await process_frame
	await process_frame
	_run()


func _run() -> void:
	print("STAGED: roster shape")
	var all: Array = LIVE_TYPES + STAGED_TYPES
	# Nov 8, 2026 TYPES expansion: TYPES now also holds the 272 bestiary
	# entries (one per bestiary row); the staged 28 are the subset pinned
	# by the checks below.
	_check(EN.TYPES.size() == 300, "TYPES has 300 entries (28 staged + 272 bestiary)",
			"got %d" % EN.TYPES.size())
	var behaviors := {}
	for tid in all:
		_check(EN.TYPES.has(tid), "TYPES has " + tid)
		if not EN.TYPES.has(tid):
			continue
		var t: Dictionary = EN.TYPES[tid]
		_check(str(t.get("family", "")).length() > 0, tid + " has a family")
		_check(str(t.get("band", "")) in BANDS, tid + " band valid",
				"got '%s'" % str(t.get("band", "")))
		_check(str(t.get("archetype", "")) in ARCHETYPES, tid + " archetype valid",
				"got '%s'" % str(t.get("archetype", "")))
		_check(str(t.get("behavior", "")).length() > 20, tid + " behavior text present")
		_check(str(t.get("sound_vocal", "")).length() > 0, tid + " vocal spec present")
		_check(str(t.get("sound_steps", "")).length() > 0, tid + " footstep spec present")
		_check(str(t.get("sound_attack", "")).length() > 0, tid + " attack spec present")
		# Behavior variety: no two monsters share the same behavior text.
		var b := str(t["behavior"])
		_check(not behaviors.has(b), tid + " behavior text is unique")
		behaviors[b] = tid
		# Base stats are depth-1 values: positive, sane, defense flat-safe.
		_check(float(t["hp"]) > 0.0 and float(t["atk"]) > 0.0, tid + " positive base hp/atk")
		_check(float(t["hp"]) <= 60.0 and float(t["atk"]) <= 12.0, tid + " base stats in band",
				"hp=%s atk=%s" % [str(t["hp"]), str(t["atk"])])
		_check(float(t["def"]) >= 0.0 and float(t["def"]) <= 3.0, tid + " base def flat-safe")
		# Sound files named by a spec must actually exist on disk.
		for key in ["sound_steps", "sound_attack"]:
			var spec := str(t[key])
			if spec.begins_with("res://"):
				_check(FileAccess.file_exists(spec), tid + " " + key + " file exists",
						spec)
		# Honest model claims: wired types have a model key (pinned by
		# monster_models_test.gd), procedural types must NOT claim one.
		if tid in WIRED_TYPES:
			_check(t.has("model"), tid + " wired type has a model key")
		elif tid in STAGED_TYPES:
			_check(not t.has("model"), tid + " procedural type has NO model key")
		else:
			_check(t.has("model"), tid + " live type keeps its model key")

	print("STAGED: locked scaling curves")
	# main.gd: hp_mult = depth^1.2, atk_mult = depth^1.05. Spot-check the
	# heaviest staged tank (troll) and the frailest (pixie) at depth 10.
	var hp_mult := pow(10.0, 1.2)
	var atk_mult := pow(10.0, 1.05)
	var troll := Enemy.new()
	troll.setup("troll", hp_mult, atk_mult, Vector2i.ZERO)
	root.add_child(troll)
	_check(absf(troll.max_hp - 48.0 * hp_mult) < 0.01, "troll depth-10 hp = 48 * 10^1.2",
			"got %.1f" % troll.max_hp)
	_check(absf(troll.atk - 7.0 * atk_mult) < 0.01, "troll depth-10 atk = 7 * 10^1.05",
			"got %.1f" % troll.atk)
	_check(absf(troll.def - 2.0) < 0.001, "troll def FLAT at depth 10")
	troll.queue_free()
	var pixie := Enemy.new()
	pixie.setup("pixie", hp_mult, atk_mult, Vector2i.ZERO)
	root.add_child(pixie)
	_check(absf(pixie.max_hp - 7.0 * hp_mult) < 0.01, "pixie depth-10 hp = 7 * 10^1.2",
			"got %.1f" % pixie.max_hp)
	pixie.queue_free()

	print("STAGED: archetype variety")
	var seen := {}
	for tid in all:
		seen[str(EN.TYPES[tid]["archetype"])] = true
	_check(seen.size() >= 15, "at least 15 distinct archetypes across the set",
			"got %d" % seen.size())

	if _failures == 0:
		print("STAGED: ALL PASS")
	else:
		printerr("STAGED: %d FAILURES" % _failures)
	quit(_failures)
