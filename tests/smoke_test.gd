extends SceneTree
## Headless unit smoke test: dungeon gen, combat math, big-number formatting.
## Run: godot --headless --path . -s tests/smoke_test.gd
## Exits 0 on success, 1 on any failure.

const DG = preload("res://scripts/dungeon_gen.gd")
const CB = preload("res://scripts/combat.gd")
const BN = preload("res://autoload/big_numbers.gd")
const EN = preload("res://scripts/enemy.gd")
const IT = preload("res://scripts/items.gd")

var _failures := 0


func _check(cond: bool, name: String, detail: String = "") -> void:
	if cond:
		print("  PASS  %s" % name)
	else:
		_failures += 1
		printerr("  FAIL  %s  %s" % [name, detail])


func _initialize() -> void:
	print("SMOKE_UNIT: starting")
	_test_dungeon_gen()
	_test_monster_floor()
	_test_loot_gen()
	_test_items()
	_test_rarity_ladder()
	_test_combat()
	_test_starting_stats_scrappy()
	_test_big_numbers()
	if _failures == 0:
		print("SMOKE_UNIT: ALL PASS")
	else:
		printerr("SMOKE_UNIT: %d FAILURES" % _failures)
	quit(_failures)


func _test_dungeon_gen() -> void:
	print("== DungeonGen ==")
	var rng := RandomNumberGenerator.new()
	rng.seed = 42
	for depth in [1, 5, 12]:
		var gen: Dictionary = DG.generate(40, 40, depth, rng)
		var grid: Array = gen["grid"]
		var start: Vector2i = gen["player_start"]
		var stairs: Vector2i = gen["stairs"]
		_check(_cell(grid, start) == DG.FLOOR, "d%d start on floor" % depth)
		_check(_cell(grid, stairs) == DG.STAIRS, "d%d stairs placed" % depth)
		_check(_flood_reaches(grid, 40, 40, start, stairs), "d%d stairs reachable" % depth)
		var enemies: Array = gen["enemies"]
		_check(enemies.size() >= 6, "d%d enemy count sane (%d)" % [depth, enemies.size()])
		var types_ok := true
		for e in enemies:
			if not EN.TYPES.has(e["type"]):
				types_ok = false
			if _cell(grid, e["pos"]) != DG.FLOOR:
				types_ok = false
		_check(types_ok, "d%d enemies valid" % depth)


func _cell(grid: Array, p: Vector2i) -> int:
	return (grid[p.y] as Array)[p.x]


func _flood_reaches(grid: Array, w: int, h: int, src: Vector2i, dst: Vector2i) -> bool:
	var seen := {src: true}
	var stack: Array = [src]
	while not stack.is_empty():
		var p: Vector2i = stack.pop_back()
		if p == dst:
			return true
		for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
			var q: Vector2i = p + d
			if q.x < 0 or q.y < 0 or q.x >= w or q.y >= h or seen.has(q):
				continue
			if _cell(grid, q) == DG.WALL:
				continue
			seen[q] = true
			stack.push_back(q)
	return false


func _test_combat() -> void:
	print("== Combat ==")
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	var min_dmg := 1e9
	var saw_crit := false
	for i in 200:
		var res: Dictionary = CB.calc_damage(10.0, 3.0, rng)
		min_dmg = minf(min_dmg, float(res["amount"]))
		if bool(res["crit"]):
			saw_crit = true
	_check(min_dmg >= 1.0, "damage floor >= 1 (min=%.2f)" % min_dmg)
	_check(saw_crit, "crits occur in 200 rolls")
	# Overwhelming defense still chips.
	var chip: Dictionary = CB.calc_damage(2.0, 100.0, rng)
	_check(float(chip["amount"]) >= 1.0, "min chip damage vs huge defense")
	_check(CB.xp_for_level(1) > 0.0, "xp_for_level positive")


func _test_big_numbers() -> void:
	print("== BigNumbers ==")
	_check(BN.format(0.0) == "0", "zero")
	_check(BN.format(999.0) == "999", "sub-1000 int")
	_check(BN.format(999.5) == "999.5", "sub-1000 float")
	_check(BN.format(1000.0) == "1.00K", "thousands")
	_check(BN.format(1234567.0) == "1.23M", "millions")
	_check(BN.format(1.0e12) == "1.00T", "trillions")
	_check(BN.format(1.0e18) == "1.00Qi", "quintillions")
	_check(BN.format(1.0e33) == "1.00Dc", "decillions")
	var huge := BN.format(1.0e100)
	_check(huge == "1.00e100", "beyond suffixes -> scientific", "got " + huge)
	_check(BN.format(-2500.0) == "-2.50K", "negatives")
	_check(BN.format(5.0e306).begins_with("5.00e306"), "near float max")


func _test_monster_floor() -> void:
	print("== MonsterFloor ==")
	var rng := RandomNumberGenerator.new()
	rng.seed = 31337
	# Forced horde: flagged, inflated count, weak types only, layout valid.
	var gen: Dictionary = DG.generate(40, 40, 5, rng, true)
	_check(bool(gen["monster_floor"]), "forced horde flagged")
	var grid: Array = gen["grid"]
	var start: Vector2i = gen["player_start"]
	var stairs: Vector2i = gen["stairs"]
	var enemies: Array = gen["enemies"]
	_check(enemies.size() > 42, "horde count inflated (%d)" % enemies.size())
	_check(enemies.size() <= DG.HORDE_CAP, "horde capped at %d" % DG.HORDE_CAP)
	_check(_flood_reaches(grid, 40, 40, start, stairs), "horde floor stairs reachable")
	var weak_ok := true
	var cells := {}
	for e in enemies:
		# Wave 3: the horde pool is the full weak set (hp<=20, atk<=6,
		# never caster/brute/tank/phase/grappler/ranged), not just
		# slime/bat — see DungeonGen.HORDE_TYPES.
		if not DG.HORDE_TYPES.has(str(e["type"])):
			weak_ok = false
		var p: Vector2i = e["pos"]
		if _cell(grid, p) != DG.FLOOR:
			weak_ok = false
		if cells.has(p):
			weak_ok = false
		cells[p] = true
	_check(weak_ok, "horde: weak types only, on floor, unique cells")
	# Depth 1 never rolls a horde — onboarding stays gentle.
	var r2 := RandomNumberGenerator.new()
	var d1_horde := false
	for i in 200:
		r2.seed = 1000 + i
		if bool(DG.generate(40, 40, 1, r2)["monster_floor"]):
			d1_horde = true
	_check(not d1_horde, "depth 1 never a monster floor (200 rolls)")
	# Natural hordes do occur at depth 5+.
	var natural := false
	for i in 200:
		r2.seed = 5000 + i
		if bool(DG.generate(40, 40, 5, r2)["monster_floor"]):
			natural = true
	_check(natural, "natural horde occurs at depth 5 (200 rolls)")


func _test_loot_gen() -> void:
	print("== LootGen ==")
	var rng := RandomNumberGenerator.new()
	rng.seed = 99
	for depth in [1, 4, 9]:
		var gen: Dictionary = DG.generate(40, 40, depth, rng)
		var grid: Array = gen["grid"]
		var start: Vector2i = gen["player_start"]
		var loot: Array = gen["loot"]
		var chests: Array = gen["chests"]
		_check(loot.size() >= 16, "d%d loot count sane (%d)" % [depth, loot.size()])
		_check(chests.size() >= 3 and chests.size() <= 5,
			"d%d chest count 3-5 (%d)" % [depth, chests.size()])
		var cells := {}
		var ok := true
		for l in loot:
			var p: Vector2i = l["pos"]
			if _cell(grid, p) != DG.FLOOR:
				ok = false
			if cells.has(p):
				ok = false
			cells[p] = true
			if not ["weapon", "armor", "health_potion", "mana_potion"].has(str(l["kind"])):
				ok = false
		for c in chests:
			var p2: Vector2i = c["pos"]
			if _cell(grid, p2) != DG.FLOOR:
				ok = false
			if cells.has(p2):
				ok = false
			cells[p2] = true
			if (p2 - start).length() < 5.0:
				ok = false
		_check(ok, "d%d loot/chests valid (floor, unique, chests away from start)" % depth)


func _test_items() -> void:
	print("== Items ==")
	var rng := RandomNumberGenerator.new()
	rng.seed = 1234
	var w1: Dictionary = IT.make_weapon(1, rng)
	_check(str(w1["slot"]) == "weapon" and float(w1["atk"]) > 0.0, "weapon has atk")
	var a1: Dictionary = IT.make_armor(1, rng)
	_check(str(a1["slot"]) == "armor" and float(a1["def"]) > 0.0, "armor has def")
	# Deep-floor gear strictly outclasses depth-1 gear (tiers don't overlap).
	var w9: Dictionary = IT.make_weapon(9, rng)
	_check(IT.gear_score(w9) > IT.gear_score(w1), "depth 9 weapon beats depth 1")
	_check(IT.better(w9, w1), "better() true for upgrade")
	_check(not IT.better(w1, w9), "better() false for downgrade")
	_check(IT.better(w1, {}), "better() true vs empty slot")
	_check(IT.sell_value(w1) > 0.0, "sell value positive")
	_check(IT.gear_score({}) == 0.0, "empty gear scores 0")


func _test_rarity_ladder() -> void:
	print("== RarityLadder (canon data table) ==")
	var ladder: Array = IT.RARITY_LADDER
	# Design notes list 39 names ("40 rungs" in prose); assert the table
	# matches the listed canon exactly.
	_check(ladder.size() == 39, "ladder has 39 canon rungs (%d)" % ladder.size())
	_check(str(ladder[0]["name"]) == "Common", "ladder starts at Common")
	_check(str(ladder[ladder.size() - 1]["name"]) == "Infinite", "ladder ends at Infinite")
	var names := {}
	var order_ok := true
	for i in ladder.size():
		var n := str(ladder[i]["name"])
		if names.has(n):
			order_ok = false
		names[n] = true
		if not (ladder[i]["color"] is Color):
			order_ok = false
	_check(order_ok, "ladder names unique, all have colors")
	for spot in [["Mythic", 5], ["F", 7], ["SSS+", 24], ["Ω", 25],
			["X", 27], ["ZZ", 31], ["EX", 32], ["Cosmic", 33], ["Void", 35]]:
		_check(IT.rarity_index(str(spot[0])) == int(spot[1]),
			"ladder index %s == %d" % [str(spot[0]), int(spot[1])])
	_check(IT.rarity_index("Nope") == -1, "unknown rarity index -1")
	var c := IT.rarity_color("Legendary")
	_check(c is Color and c.r > 0.9, "known rarity has its color")
	var gray := IT.rarity_color("Fine")  # pre-ladder drop rarity -> neutral
	_check(gray is Color and absf(gray.r - 0.75) < 0.01, "unknown rarity -> neutral gray")


func _test_starting_stats_scrappy() -> void:
	print("== StartingStats (fresh run stays scrappy) ==")
	# Fresh player: atk 6 / def 1 / hp 50. Depth-1 slime: 18 hp / 4 atk / 0 def.
	# Fights must take several rounds; nothing one-shots either way.
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	var max_player_hit := 0.0
	var total := 0.0
	for i in 200:
		var dmg := float(CB.calc_damage(6.0, 0.0, rng)["amount"])
		max_player_hit = maxf(max_player_hit, dmg)
		total += dmg
	_check(max_player_hit < 18.0, "player never one-shots a full-HP slime (max=%.1f)" % max_player_hit)
	_check(total / 200.0 < 9.0, "average player hit < 9 dmg -> 2+ rounds typical")
	var max_slime_hit := 0.0
	for i in 200:
		max_slime_hit = maxf(max_slime_hit, float(CB.calc_damage(4.0, 1.0, rng)["amount"]))
	_check(max_slime_hit < 50.0 / 3.0, "slime never chunks >1/3 of fresh HP (max=%.1f)" % max_slime_hit)
