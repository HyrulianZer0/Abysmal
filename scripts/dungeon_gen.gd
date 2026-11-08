class_name DungeonGen
extends RefCounted
## Procedural dungeon generator: rooms + L corridors on a grid.
## One floor per call; stairs tile leads to the next (deeper) floor.

const WALL := 0
const FLOOR := 1
const STAIRS := 2
## Door cells are FLOOR underneath; the door state lives in the `doors` array
## (main.gd). A door on a 1-wide corridor neck never disconnects the map —
## the player can always get through (closed: bump open; locked: pick/bash).
const DOOR := 3

const MIN_ROOMS := 10
const MAX_ROOMS := 14

# --- Monster floor ("oh no" floor) -------------------------------------------
# A special floor event: the dungeon packs the floor with a horde of weak /
# average monsters. Overwhelm, not kill — the threat is being surrounded
# (action economy), never unfair one-shot power. Tuning knobs in one place.
const MONSTER_FLOOR_CHANCE := 0.12
const MONSTER_FLOOR_MIN_DEPTH := 2  # depth 1 stays gentle (onboarding)
const HORDE_MULT := 3
const HORDE_CAP := 80


## Generate a dungeon floor. Returns a Dictionary:
## { grid, width, height, player_start: Vector2i, stairs: Vector2i,
##   rooms: Array[Rect2i],
##   enemies: Array of {pos: Vector2i, type: String, asleep: bool},
##   loot: Array of {pos: Vector2i, kind: String, taken: bool},
##   chests: Array of {pos: Vector2i, opened: bool, sealed: bool,
##                     lock_tier: int, tumblers: int, room_idx: int},
##   doors: Array of {pos: Vector2i, state: String, tier: int,
##                    tumblers: int, bash_hp: int},
##   monster_floor: bool }
static func generate(width: int, height: int, depth: int, rng: RandomNumberGenerator,
		force_monster_floor: bool = false) -> Dictionary:
	var grid: Array = []
	grid.resize(height)
	for y in height:
		# NOTE: plain Array (not PackedByteArray) — nested subscript writes
		# stick because Array is by-reference; Packed* arrays are copy-on-write
		# and silently drop writes made through a container.
		var row: Array = []
		row.resize(width)
		row.fill(WALL)
		grid[y] = row

	# --- Rooms: random non-overlapping rects --------------------------------
	# Room count scales with map area so deep (bigger) floors don't feel
	# empty: ~10-14 rooms on the classic 40x40, up to ~3x on huge floors.
	# (Density pass, Oct 2026: base range raised from 7-11 for ~+35% rooms
	# per floor at every size — floors stay roomy, just less empty. The
	# first cut at 10-15 measured +45% but lengthened floor sweeps enough
	# to trip the soak's no-progress watchdog noticeably more often, so
	# the top of the range came down one notch.)
	var rooms: Array[Rect2i] = []
	var want_rooms := rng.randi_range(MIN_ROOMS, MAX_ROOMS)
	var area_scale := sqrt(float(width * height) / float(40 * 40))
	want_rooms = clampi(int(round(float(want_rooms) * area_scale)), MIN_ROOMS, 44)
	var attempts := 0
	while rooms.size() < want_rooms and attempts < 300 + want_rooms * 30:
		attempts += 1
		var rw := rng.randi_range(4, 9)
		var rh := rng.randi_range(4, 7)
		var rx := rng.randi_range(1, width - rw - 2)
		var ry := rng.randi_range(1, height - rh - 2)
		var room := Rect2i(rx, ry, rw, rh)
		var overlaps := false
		for other in rooms:
			if room.grow(1).intersects(other):
				overlaps = true
				break
		if overlaps:
			continue
		rooms.append(room)
		_carve_rect(grid, room)

	if rooms.is_empty():
		# Paranoia fallback: one big room so the floor is never broken.
		var fallback := Rect2i(2, 2, width - 4, height - 4)
		rooms.append(fallback)
		_carve_rect(grid, fallback)

	# --- Corridors: connect room centers with L shapes ----------------------
	for i in range(1, rooms.size()):
		var a := rooms[i - 1].get_center()
		var b := rooms[i].get_center()
		_carve_h(grid, a.x, b.x, a.y, width)
		_carve_v(grid, a.y, b.y, b.x, height)

	var player_start := rooms[0].get_center()

	# --- Stairs: farthest room center from start (Manhattan) -----------------
	var stairs := rooms[rooms.size() - 1].get_center()
	var best := -1
	for room in rooms:
		var c := room.get_center()
		var d := absi(c.x - player_start.x) + absi(c.y - player_start.y)
		if d > best:
			best = d
			stairs = c
	_grid_set(grid, stairs, STAIRS)

	# --- Guarantee connectivity: flood fill must reach stairs ---------------
	if not _reachable(grid, width, height, player_start, stairs):
		_carve_h(grid, player_start.x, stairs.x, player_start.y, width)
		_carve_v(grid, player_start.y, stairs.y, stairs.x, height)
		_grid_set(grid, stairs, STAIRS)

	# --- Enemies -------------------------------------------------------------
	# Monster floor roll: a horde of weak/average monsters (overwhelm, not kill).
	var monster_floor := force_monster_floor \
		or (depth >= MONSTER_FLOOR_MIN_DEPTH and rng.randf() < MONSTER_FLOOR_CHANCE)
	var enemies: Array = []
	var count := mini(6 + depth * 2, 42)
	if monster_floor:
		count = mini(count * HORDE_MULT, HORDE_CAP)
	var placed := 0
	var guard := 0
	# Sleepers: ~30% of monsters spawn asleep. They don't aggro, wander, or
	# strike until woken (disturbed, damaged, or startled by a bashed door).
	# This is what the Stealth skill plays against.
	const SLEEP_CHANCE := 0.30
	while placed < count and guard < count * 40:
		guard += 1
		var p := Vector2i(rng.randi_range(1, width - 2), rng.randi_range(1, height - 2))
		if _grid_get(grid, p) != FLOOR:
			continue
		if _manhattan(p, player_start) < 5:
			continue
		if _manhattan(p, stairs) < 2:
			continue
		var taken := false
		for e in enemies:
			if e["pos"] == p:
				taken = true
				break
		if taken:
			continue
		enemies.append({"pos": p, "type": _pick_type(depth, rng, monster_floor),
			"asleep": rng.randf() < SLEEP_CHANCE})
		placed += 1

	# --- Loot + chests -------------------------------------------------------
	var loot: Array = []
	var chests: Array = []
	var taken_cells := {}
	taken_cells[stairs] = true
	for e in enemies:
		taken_cells[e["pos"]] = true
	_place_loot_and_chests(grid, width, height, player_start, rooms, taken_cells,
		loot, chests, depth, rng, enemies, stairs)

	# --- Doors ---------------------------------------------------------------
	# Pinch-point cells (exactly two opposite open neighbors = 1-wide
	# corridor neck) become doors. Never on loot/enemy/stairs cells, never
	# near spawn, never adjacent to another door.
	var doors := _place_doors(grid, width, height, player_start, taken_cells, depth, rng)

	return {
		"grid": grid,
		"width": width,
		"height": height,
		"player_start": player_start,
		"stairs": stairs,
		"rooms": rooms,
		"enemies": enemies,
		"loot": loot,
		"chests": chests,
		"doors": doors,
		"monster_floor": monster_floor,
	}


## Scatter weapons/armor/potions across the floor and place 3-5 chests.
## Everything lands on open floor, away from the player start, on unique
## cells that don't collide with enemies or the stairs.
## v0.3.0: generous test-build spread so the loot loop can be *felt*.
##
## Chests spawn SEALED (a ward breaks when their room is clear of hostiles)
## and ~35% carry a padlock (tier scales with depth; Lockpicking opens them;
## locked chests roll better loot). `taken_cells` is filled in as we go.
##
## A sealed chest is solid to movement and pathing until its room clears, so
## a chest dropped on a cut-vertex cell would wall off the floor permanently
## (its own seal could never break — the classic self-sealing soft-lock).
## After each placement we flood-fill with all sealed chests solid and reject
## any spot that cuts an enemy or the stairs off from the player start.
static func _place_loot_and_chests(grid: Array, width: int, height: int,
		player_start: Vector2i, rooms: Array, taken_cells: Dictionary,
		loot: Array, chests: Array, depth: int, rng: RandomNumberGenerator,
		enemies: Array, stairs: Vector2i) -> void:
	var taken := taken_cells
	var want := {
		"weapon": rng.randi_range(4, 6),
		"armor": rng.randi_range(4, 6),
		"health_potion": rng.randi_range(6, 9),
		"mana_potion": rng.randi_range(4, 6),
	}
	for kind in want:
		var n: int = want[kind]
		var placed := 0
		var guard := 0
		while placed < n and guard < n * 60:
			guard += 1
			var p := Vector2i(rng.randi_range(1, width - 2), rng.randi_range(1, height - 2))
			if _grid_get(grid, p) != FLOOR:
				continue
			if _manhattan(p, player_start) < 4:
				continue
			if taken.has(p):
				continue
			taken[p] = true
			loot.append({"pos": p, "kind": kind, "taken": false})
			placed += 1

	const LOCK_CHANCE := 0.35
	var chest_n := rng.randi_range(3, 5)
	var chest_placed := 0
	var chest_guard := 0
	while chest_placed < chest_n and chest_guard < chest_n * 60:
		chest_guard += 1
		var p := Vector2i(rng.randi_range(1, width - 2), rng.randi_range(1, height - 2))
		if _grid_get(grid, p) != FLOOR:
			continue
		if _manhattan(p, player_start) < 6:
			continue
		if taken.has(p):
			continue
		# Chests live in rooms, never in corridors: a sealed chest is solid
		# until its room clears, and one dropped in a 1-wide corridor could
		# wall off the map permanently (its seal would never break either).
		if _room_index_of(rooms, p) < 0:
			continue
		taken[p] = true
		var lock_tier := 0
		if rng.randf() < LOCK_CHANCE:
			lock_tier = clampi(1 + depth / 4 + rng.randi_range(0, 1), 1, 5)
		chests.append({
			"pos": p,
			"opened": false,
			"sealed": true,  # ward breaks when the chest's room is clear
			"lock_tier": lock_tier,
			"tumblers": lock_tier * 3,
			"room_idx": _room_index_of(rooms, p),
		})
		# Never let a sealed chest (alone or with the others) partition the
		# floor: every enemy and the stairs must stay reachable from spawn.
		var targets: Array = [stairs]
		for e in enemies:
			targets.append((e as Dictionary)["pos"])
		if not _sealed_chests_keep_connected(grid, width, height,
				player_start, chests, targets):
			chests.pop_back()
			taken.erase(p)
			continue
		chest_placed += 1


## Room index containing `p`, or the nearest room's index for corridor cells.
static func _room_index_of(rooms: Array, p: Vector2i) -> int:
	for i in rooms.size():
		if (rooms[i] as Rect2i).has_point(p):
			return i
	var best_idx := 0
	var best_d := 1 << 30
	for i in rooms.size():
		var d := _manhattan(p, (rooms[i] as Rect2i).get_center())
		if d < best_d:
			best_d = d
			best_idx = i
	return best_idx


## Doors on corridor pinch points. `state` is "closed" or "locked";
## locked doors get a tier (depth-scaled), tumblers (tier x 3 pick attempts),
## and bash_hp (2 + tier bashes to splinter).
static func _place_doors(grid: Array, width: int, height: int,
		player_start: Vector2i, taken_cells: Dictionary, depth: int,
		rng: RandomNumberGenerator) -> Array:
	var pinch: Array[Vector2i] = []
	for y in range(1, height - 1):
		for x in range(1, width - 1):
			var p := Vector2i(x, y)
			if _grid_get(grid, p) != FLOOR or taken_cells.has(p):
				continue
			if _manhattan(p, player_start) < 6:
				continue
			var n: bool = _grid_get(grid, p + Vector2i(0, -1)) == FLOOR
			var s: bool = _grid_get(grid, p + Vector2i(0, 1)) == FLOOR
			var e: bool = _grid_get(grid, p + Vector2i(1, 0)) == FLOOR
			var w: bool = _grid_get(grid, p + Vector2i(-1, 0)) == FLOOR
			if (n and s and not e and not w) or (e and w and not n and not s):
				pinch.append(p)
	# Shuffle so doors spread across the floor instead of clustering top-left.
	for i in range(pinch.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var tmp := pinch[i]
		pinch[i] = pinch[j]
		pinch[j] = tmp
	var doors: Array = []
	var want := mini(2 + depth / 3, 4)
	for p in pinch:
		if doors.size() >= want:
			break
		var clear := true
		for d in doors:
			if _manhattan(p, d["pos"]) < 4:
				clear = false
				break
		if not clear:
			continue
		var locked := rng.randf() < 0.45
		var tier := 0
		if locked:
			tier = mini(1 + depth / 4 + rng.randi_range(0, 1), 5)
		# Corridor axis (for rendering the slab across the passage).
		var n2: bool = _grid_get(grid, p + Vector2i(0, -1)) == FLOOR
		var s2: bool = _grid_get(grid, p + Vector2i(0, 1)) == FLOOR
		# The slab's wide dimension runs perpendicular to travel: any N/S
		# opening means travel along Z, so the slab spans X ("ns"). Only a
		# purely E-W opening gets the Z-spanning slab ("ew"). The old
		# `n2 and s2` test mis-oriented dead-ends and corners, leaving the
		# player staring at the texture-smeared 0.35m thin edge.
		var axis := "ns" if (n2 or s2) else "ew"
		doors.append({
			"pos": p,
			"state": "locked" if locked else "closed",
			"axis": axis,
			"tier": tier,
			"tumblers": tier * 3,
			"bash_hp": 2 + tier,
		})
		taken_cells[p] = true
	return doors


## Enemy roster unlocks as depth grows (roguelike escalation).
## Wave 3 spawn wiring: the full 28-type staged roster actually appears
## in gameplay (previously only slime/bat/skeleton ever spawned).
## Bands (depth = floor number; weights are relative, need not sum to 1):
##  d1: the gentle five (weak, hp<=20, atk<=6) — onboarding stays gentle.
##  d2: + skeleton, snake, centipede, goblin, boar (honest bruiser +
##      weak crawlers + the first charger, whose pawing telegraph teaches tells).
##  d3: + zombie, wolf, scorpion, wasp, kobold (pack/swarm/venom/trapper join).
##  d4: + skeleton_archer, imp, pixie (ranged + flyer/casters, mid-depth).
##  d5: + ghost, golem, orc, harpy (the D-band: phase, tank, brute, flyer).
##  d6: + troll, minotaur, oni, kappa (heavy D-band: regen, charger/brute,
##      brute, grappler/tank).
##  d8: + drake, banshee (flyer/brute breath + AoE caster; banshee is the
##      Dp-band caster, so it waits longest).
##  d10+: D/Dp weights x1.5 — the deep game leans heavy, but weak types
##      never vanish (endless variety, not replacement).
## Stats are NOT invented here: every type's depth-1 hp/atk/def come from
## enemy.gd TYPES and scale on the locked curves (hp x depth^1.2,
## atk x depth^1.05, def flat). No apex bosses spawn here — Wave 4 owns apex.
## On monster floors only weak types spawn — the horde overwhelms through
## numbers, never through elite one-shot power. Horde pool (all hp<=20,
## atk<=6, and never a caster, brute, tank, phase, grappler, or ranged
## type — a horde of pixie dazzles or archer kites would be degenerate):
## slime, bat, rat, spider, snake, frog, wasp, centipede, goblin, kobold,
## depth-gated the same way (d1: slime/bat/rat only).
## DEEP_TYPES mirrors the "band" field in enemy.gd TYPES (D + Dp).
const DEEP_TYPES: Array[String] = ["ghost", "golem", "orc", "harpy",
		"troll", "minotaur", "oni", "kappa", "drake", "banshee"]
const HORDE_TYPES: Array[String] = ["slime", "bat", "rat", "spider",
		"snake", "frog", "wasp", "centipede", "goblin", "kobold"]


## Weighted spawn table for a depth: Array of [type, weight] pairs.
## Public (not just for _pick_type) so tests can audit bands directly.
static func spawn_table(depth: int, weak_only: bool = false) -> Array:
	if weak_only:
		# Horde pool, depth-gated: d1 gentle, d2 adds frog/spider,
		# d3+ the full weak pool. Weights favor slime/bat slightly.
		var pool: Array = []
		pool.append(["slime", 3.0])
		pool.append(["bat", 2.0])
		pool.append(["rat", 2.0])
		if depth >= 2:
			pool.append(["frog", 1.5])
			pool.append(["spider", 1.5])
		if depth >= 3:
			pool.append(["snake", 1.0])
			pool.append(["wasp", 1.0])
			pool.append(["centipede", 1.0])
			pool.append(["goblin", 1.0])
			pool.append(["kobold", 1.0])
		return pool
	var table: Array = []
	# Depth 1: the gentle five.
	table.append(["slime", 3.0])
	table.append(["bat", 2.0])
	table.append(["rat", 2.0])
	table.append(["spider", 1.5])
	table.append(["frog", 1.5])
	if depth >= 2:
		table.append(["skeleton", 1.5])
		table.append(["snake", 1.2])
		table.append(["centipede", 1.2])
		table.append(["goblin", 1.0])
		table.append(["boar", 1.0])
	if depth >= 3:
		table.append(["zombie", 1.2])
		table.append(["wolf", 1.2])
		table.append(["scorpion", 1.0])
		table.append(["wasp", 1.0])
		table.append(["kobold", 1.0])
	if depth >= 4:
		table.append(["skeleton_archer", 1.0])
		table.append(["imp", 0.8])
		table.append(["pixie", 0.8])
	if depth >= 5:
		table.append(["ghost", 0.9])
		table.append(["golem", 0.9])
		table.append(["orc", 0.9])
		table.append(["harpy", 0.9])
	if depth >= 6:
		table.append(["troll", 0.8])
		table.append(["minotaur", 0.8])
		table.append(["oni", 0.8])
		table.append(["kappa", 0.8])
	if depth >= 8:
		table.append(["drake", 0.7])
		table.append(["banshee", 0.7])
	if depth >= 10:
		# Deep floors lean heavy: D/Dp weights x1.5, weak types untouched.
		for entry in table:
			if DEEP_TYPES.has(entry[0]):
				entry[1] = float(entry[1]) * 1.5
	return table


static func _pick_type(depth: int, rng: RandomNumberGenerator, weak_only: bool = false) -> String:
	var table: Array = spawn_table(depth, weak_only)
	var total := 0.0
	for entry in table:
		total += float(entry[1])
	if total <= 0.0:
		return "slime"
	var roll := rng.randf() * total
	for entry in table:
		roll -= float(entry[1])
		if roll <= 0.0:
			return str(entry[0])
	return str(table[table.size() - 1][0])


static func _carve_rect(grid: Array, room: Rect2i) -> void:
	for y in range(room.position.y, room.position.y + room.size.y):
		for x in range(room.position.x, room.position.x + room.size.x):
			_grid_set(grid, Vector2i(x, y), FLOOR)


static func _carve_h(grid: Array, x0: int, x1: int, y: int, width: int) -> void:
	for x in range(mini(x0, x1), maxi(x0, x1) + 1):
		if x >= 1 and x < width - 1:
			_grid_set(grid, Vector2i(x, y), FLOOR)


static func _carve_v(grid: Array, y0: int, y1: int, x: int, height: int) -> void:
	for y in range(mini(y0, y1), maxi(y0, y1) + 1):
		if y >= 1 and y < height - 1:
			_grid_set(grid, Vector2i(x, y), FLOOR)


static func _grid_get(grid: Array, p: Vector2i) -> int:
	return (grid[p.y] as Array)[p.x]


static func _grid_set(grid: Array, p: Vector2i, v: int) -> void:
	(grid[p.y] as Array)[p.x] = v


static func _manhattan(a: Vector2i, b: Vector2i) -> int:
	return absi(a.x - b.x) + absi(a.y - b.y)


## Flood fill from `src`; true if `dst` is reachable over FLOOR/STAIRS.
## Flood fill from `src` treating every chest in `chests` as solid (they all
## spawn sealed). Returns true only if every cell in `targets` is reachable.
## Used during generation so a sealed chest can never partition the floor.
static func _sealed_chests_keep_connected(grid: Array, width: int, height: int,
		src: Vector2i, chests: Array, targets: Array) -> bool:
	var solid := {}
	for ch in chests:
		solid[(ch as Dictionary)["pos"]] = true
	var want := {}
	for t in targets:
		want[t] = true
	var seen := {src: true}
	var queue: Array[Vector2i] = [src]
	var found := 0
	while not queue.is_empty():
		var cur: Vector2i = queue.pop_front()
		if want.has(cur):
			found += 1
			if found == want.size():
				return true
		for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
			var nxt: Vector2i = cur + d
			if nxt.x < 0 or nxt.y < 0 or nxt.x >= width or nxt.y >= height:
				continue
			if seen.has(nxt):
				continue
			if _grid_get(grid, nxt) == WALL:
				continue
			if solid.has(nxt):
				continue
			seen[nxt] = true
			queue.push_back(nxt)
	return found == want.size()


static func _reachable(grid: Array, width: int, height: int, src: Vector2i, dst: Vector2i) -> bool:
	var seen := {}
	var stack: Array[Vector2i] = [src]
	seen[src] = true
	while not stack.is_empty():
		var p: Vector2i = stack.pop_back()
		if p == dst:
			return true
		for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
			var q: Vector2i = p + d
			if q.x < 0 or q.y < 0 or q.x >= width or q.y >= height:
				continue
			if seen.has(q):
				continue
			if _grid_get(grid, q) == WALL:
				continue
			seen[q] = true
			stack.push_back(q)
	return false
