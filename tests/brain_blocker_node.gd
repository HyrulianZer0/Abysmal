extends Node
## Regression test for the deep-delve soft-lock (2026-09-26): a dormant
## monster or an unopened chest sitting in a 1-wide corridor used to make
## every idle-brain BFS return "unreachable", so the crawler wandered
## randomly forever. The brain must now path THROUGH blockers — it
## bump-attacks / bump-opens them via _try_step.
##
## Run: godot --headless --path . tests/brain_blocker_scene.tscn
## Exits 0 on pass, 1 on any failure.

const DungeonGenScript := preload("res://scripts/dungeon_gen.gd")
const EnemyScript := preload("res://scripts/enemy.gd")

var _failures := 0
var _main: Node = null


func _check(cond: bool, name: String, detail: String = "") -> void:
	if cond:
		print("  PASS  %s" % name)
	else:
		_failures += 1
		printerr("  FAIL  %s  %s" % [name, detail])


func _ready() -> void:
	Engine.time_scale = 4.0
	# Fresh boot: a stale hub save (e.g. death_sort's town save) would
	# restore with no live floor and crash the arena setup.
	if FileAccess.file_exists("user://savegame.dat"):
		DirAccess.remove_absolute("user://savegame.dat")
	var packed: PackedScene = load("res://scenes/main.tscn")
	_main = packed.instantiate()
	get_tree().root.add_child.call_deferred(_main)
	await get_tree().process_frame
	await get_tree().process_frame
	_setup_arena()
	_test_bfs_through_enemy()
	_test_bfs_through_chest()
	await _test_auto_step_kills_blocker()
	Engine.time_scale = 1.0
	if _failures == 0:
		print("BLOCKER: ALL PASS")
	else:
		printerr("BLOCKER: %d FAILURES" % _failures)
	get_tree().quit(_failures)


## Seal a 1-wide test corridor: x=10..16 at y=20, everything around it wall.
## Player at (10,20); the only way east is straight through x=13.
func _setup_arena() -> void:
	GameState.idle_mode = false  # we drive _auto_step by hand
	for e in (_main.get("enemies") as Array):
		if is_instance_valid(e):
			e.queue_free()
	(_main.get("enemies") as Array).clear()
	(_main.get("loot") as Array).clear()
	(_main.get("chests") as Array).clear()
	var grid: Array = (_main.get("gen"))["grid"]
	for y in range(19, 22):
		for x in range(9, 18):
			var keep := y == 20 and x >= 10 and x <= 16
			(grid[y] as Array)[x] = DungeonGenScript.FLOOR if keep else DungeonGenScript.WALL
	var players := _main.find_children("", "Player", true, false)
	players[0].place_at(Vector2i(10, 20), 1)
	print("BLOCKER: arena sealed, player at (10,20)")


func _spawn_blocker(at: Vector2i):  # -> Enemy
	var e = EnemyScript.new()
	e.setup("slime", 1.0, 1.0, at)
	e.position = (_main.get("view") as Node).world_pos(at)
	_main.add_child(e)
	(_main.get("enemies") as Array).append(e)
	return e


func _clear_blockers() -> void:
	for e in (_main.get("enemies") as Array):
		if is_instance_valid(e):
			e.queue_free()
	(_main.get("enemies") as Array).clear()
	(_main.get("chests") as Array).clear()


func _test_bfs_through_enemy() -> void:
	_clear_blockers()
	_spawn_blocker(Vector2i(13, 20))
	var targets: Array[Vector2i] = [Vector2i(16, 20)]
	var step: Vector2i = _main._bfs_first_step(targets)
	_check(step == Vector2i(1, 0), "BFS routes through a blocking enemy",
		"got %s, want (1,0)" % str(step))


func _test_bfs_through_chest() -> void:
	_clear_blockers()
	(_main.get("chests") as Array).append({"pos": Vector2i(13, 20), "opened": false})
	var targets: Array[Vector2i] = [Vector2i(16, 20)]
	var step: Vector2i = _main._bfs_first_step(targets)
	_check(step == Vector2i(1, 0), "BFS routes through an unopened chest",
		"got %s, want (1,0)" % str(step))


## End-to-end: the brain walks up to the blocker and kills it by bumping.
## End-to-end: the brain walks up to the blocker and kills it by bumping.
## (Driven with idle OFF, so each brain step also grants the monster its
## turn-based move — the blocker approaches while the brain closes in.)
func _test_auto_step_kills_blocker() -> void:
	_clear_blockers()
	var blocker = _spawn_blocker(Vector2i(13, 20))
	var players := _main.find_children("", "Player", true, false)
	players[0].place_at(Vector2i(10, 20), 1)
	var dead := false
	for i in 14:
		_main._auto_step()
		await get_tree().create_timer(0.5).timeout
		if not is_instance_valid(blocker) or blocker.dead:
			dead = true
			break
	_check(dead, "brain bump-attacks through the corridor blocker")
	var gp: Vector2i = players[0].grid_pos
	_check(int(_main.call("cell_at", gp)) != DungeonGenScript.WALL,
		"player never ended inside a wall (%s)" % str(gp))
