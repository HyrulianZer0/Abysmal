extends Node
## Regression test for the sealed-chest partition soft-lock (2026-09-27):
## a sealed chest spawning on a cut-vertex cell walls off part of the floor
## permanently — its own seal can never break because the room's hostiles are
## unreachable, and the idle brain degrades to wandering forever. The
## generator must now reject any chest spot that partitions the floor.
##
## Property test: generate many floors across random seeds and depths; with
## every sealed chest treated as solid, all enemies and the stairs must stay
## reachable from the player start.
##
## Run: godot --headless --path . tests/chest_partition_scene.tscn
## Exits 0 on pass, 1 on any failure.

const DungeonGenScript := preload("res://scripts/dungeon_gen.gd")

const FLOORS_PER_DEPTH := 12
const MAX_DEPTH := 6

var _failures := 0
var _checked := 0


func _check(cond: bool, name: String, detail: String = "") -> void:
	if cond:
		pass
	else:
		_failures += 1
		printerr("  FAIL  %s  %s" % [name, detail])


func _flood_reachable(gen: Dictionary) -> bool:
	var grid: Array = gen["grid"]
	var w: int = int(gen["width"])
	var h: int = int(gen["height"])
	var start: Vector2i = gen["player_start"]
	var solid := {}
	for ch in (gen["chests"] as Array):
		var cd := ch as Dictionary
		if not bool(cd["opened"]) and bool(cd.get("sealed", false)):
			solid[cd["pos"]] = true
	var want := {}
	want[gen["stairs"]] = true
	for e in (gen["enemies"] as Array):
		want[(e as Dictionary)["pos"]] = true
	var seen := {start: true}
	var queue: Array[Vector2i] = [start]
	var found := 0
	while not queue.is_empty():
		var cur: Vector2i = queue.pop_front()
		if want.has(cur):
			found += 1
			if found == want.size():
				return true
		for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
			var nxt: Vector2i = cur + d
			if nxt.x < 0 or nxt.y < 0 or nxt.x >= w or nxt.y >= h:
				continue
			if seen.has(nxt):
				continue
			if int((grid[nxt.y] as Array)[nxt.x]) == DungeonGenScript.WALL:
				continue
			if solid.has(nxt):
				continue
			seen[nxt] = true
			queue.push_back(nxt)
	return found == want.size()


func _ready() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 20260927
	for depth in range(1, MAX_DEPTH + 1):
		for i in FLOORS_PER_DEPTH:
			# Force a monster floor on some iterations for dense blockers.
			var gen: Dictionary = DungeonGenScript.generate(
				40, 40, depth, rng, i % 4 == 3)
			_checked += 1
			_check(_flood_reachable(gen), "floor_connected",
				"depth=%d iter=%d: sealed chest partitions the floor" % [depth, i])
	if _failures == 0:
		print("CHESTPARTITION: ALL PASS (%d floors)" % _checked)
	else:
		printerr("CHESTPARTITION: %d FAILURES over %d floors" % [_failures, _checked])
	get_tree().quit(1 if _failures > 0 else 0)
