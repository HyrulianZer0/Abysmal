extends Node
## Prestige system tests (Phase 4): token earning on the 10->11 descend,
## furthest-depth tracking per cycle across deaths, the ascension flow,
## the permanent upgrade (Gilded Soul) + perk registry, save/load
## persistence, and the additive-only guarantee (death/ascension never
## reduce meta power).
##
## Run: godot --headless --path . tests/prestige_scene.tscn
## Exits 0 on pass; prints FAIL lines and exits 1 on any violation.

const SAVE_PATH := "user://savegame.dat"

var _failures := 0
var _main: Node = null
var _phase := 0
var _finished := false


func _check(cond: bool, name: String, detail: String = "") -> void:
	if cond:
		print("  PASS  %s" % name)
	else:
		_failures += 1
		printerr("  FAIL  %s  %s" % [name, detail])


func _wipe_save() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)


func _ready() -> void:
	print("PRESTIGE: unit checks")
	_wipe_save()
	_unit_token_trigger()
	_unit_depth_tracking()
	_unit_ascension()
	_unit_additive_death()
	_unit_gold_mult()
	_unit_serialization()
	# Integration: earn tokens through the real descend funnel, ascend,
	# then save/load round-trip through main.gd.
	Prestige.from_dict({})
	var packed: PackedScene = load("res://scenes/main.tscn")
	_main = packed.instantiate()
	get_tree().root.add_child.call_deferred(_main)
	_phase = 1


## --- unit: token trigger -------------------------------------------------
func _unit_token_trigger() -> void:
	Prestige.from_dict({})
	GameState.depth = 10
	GameState.next_depth()  # 10 -> 11: floor 10 cleared
	_check(Prestige.tokens == 1, "token on 10->11 descend",
		"tokens=%d" % Prestige.tokens)
	_check(Prestige.lifetime_tokens == 1, "lifetime tokens counted")
	_check(GameState.depth == 11, "depth advanced to 11")

	Prestige.from_dict({})
	GameState.depth = 9
	GameState.next_depth()  # 9 -> 10: not a clear
	_check(Prestige.tokens == 0, "no token on 9->10 descend",
		"tokens=%d" % Prestige.tokens)

	Prestige.from_dict({})
	GameState.depth = 11
	GameState.next_depth()  # 11 -> 12: not a clear
	_check(Prestige.tokens == 0, "no token on 11->12 descend",
		"tokens=%d" % Prestige.tokens)

	# Repeatable: a second 1-10 clear earns a second token.
	Prestige.from_dict({})
	GameState.depth = 10
	GameState.next_depth()
	GameState.depth = 10  # new run, cleared 1-10 again
	GameState.next_depth()
	_check(Prestige.tokens == 2, "token repeatable per 1-10 clear",
		"tokens=%d" % Prestige.tokens)


## --- unit: furthest-depth tracking per cycle ------------------------------
func _unit_depth_tracking() -> void:
	Prestige.from_dict({})
	_check(Prestige.cycle_best_depth == 1, "cycle best starts at 1")
	GameState.depth = 4
	GameState.next_depth()  # -> 5
	_check(Prestige.cycle_best_depth == 5, "cycle best tracks descends",
		"best=%d" % Prestige.cycle_best_depth)
	GameState.depth = 2  # a new run that dies shallow...
	GameState.next_depth()  # -> 3
	_check(Prestige.cycle_best_depth == 5, "cycle best never regresses",
		"best=%d" % Prestige.cycle_best_depth)
	Prestige.note_depth(9)
	_check(Prestige.cycle_best_depth == 9, "note_depth records deeper")
	Prestige.note_depth(3)
	_check(Prestige.cycle_best_depth == 9, "note_depth ignores shallower")


## --- unit: ascension flow --------------------------------------------------
func _unit_ascension() -> void:
	# Broke: cannot ascend.
	Prestige.from_dict({})
	var r: Dictionary = Prestige.ascend()
	_check(not bool(r["ok"]), "ascend fails with 0 tokens")
	_check(Prestige.tokens == 0 and Prestige.ascensions == 0,
		"failed ascend changes nothing")

	# Funded, record-breaking cycle: bonus stack.
	Prestige.from_dict({})
	Prestige.tokens = 3
	Prestige.cycle_best_depth = 12
	Prestige.last_cycle_best_depth = 8
	r = Prestige.ascend()
	_check(bool(r["ok"]), "ascend succeeds with 3 tokens")
	_check(int(r["tokens_spent"]) == 3, "ascend spends exactly 3 tokens")
	_check(Prestige.tokens == 0, "tokens consumed")
	_check(bool(r["record_bonus"]), "record delve flagged",
		"cycle 12 > last 8")
	_check(int(r["stacks_granted"]) == 2, "record grants bonus stack")
	_check(Prestige.stacks_of(Prestige.PERK_GILDED_SOUL) == 2,
		"gilded_soul at 2 stacks")
	_check(Prestige.ascensions == 1, "ascension counted")
	_check(Prestige.last_cycle_best_depth == 12, "last cycle recorded")
	_check(Prestige.cycle_best_depth == 1, "new cycle starts at 1")

	# Funded, no record: single stack.
	Prestige.from_dict({})
	Prestige.tokens = 3
	Prestige.cycle_best_depth = 8
	Prestige.last_cycle_best_depth = 12
	r = Prestige.ascend()
	_check(bool(r["ok"]) and not bool(r["record_bonus"]),
		"no bonus without a record")
	_check(Prestige.stacks_of(Prestige.PERK_GILDED_SOUL) == 1,
		"single stack without record")
	# Second ascend immediately: broke again.
	r = Prestige.ascend()
	_check(not bool(r["ok"]), "cannot ascend twice on 3 tokens")


## --- unit: death never taxes meta power ------------------------------------
func _unit_additive_death() -> void:
	Prestige.from_dict({})
	Prestige.tokens = 2
	Prestige.lifetime_tokens = 5
	Prestige.ascensions = 1
	Prestige.cycle_best_depth = 9
	Prestige.last_cycle_best_depth = 7
	Prestige.perk_stacks = {Prestige.PERK_GILDED_SOUL: 2}
	var before: Dictionary = Prestige.to_dict()
	# Mirror _on_player_death + request_restart: die, bump the run counter,
	# start a fresh run. Nothing here may touch Prestige.
	GameState.alive = false
	GameState.run_number += 1
	GameState.reset_run()
	var after: Dictionary = Prestige.to_dict()
	_check(after == before, "death+restart leaves prestige untouched",
		"before=%s after=%s" % [str(before), str(after)])
	# Ascension itself: only the token cost moves; every other meta field
	# is identical or greater.
	Prestige.tokens = 3
	var stacks_before := Prestige.stacks_of(Prestige.PERK_GILDED_SOUL)
	Prestige.ascend()
	_check(Prestige.stacks_of(Prestige.PERK_GILDED_SOUL) > stacks_before,
		"ascension only adds perk stacks")
	_check(Prestige.lifetime_tokens == 5, "lifetime tokens never decrease")
	_check(Prestige.ascensions == 2, "ascensions monotonic")


## --- unit: the permanent upgrade feeds the economy --------------------------
func _unit_gold_mult() -> void:
	Prestige.from_dict({})
	var base := GameState.gold_mult()
	_check(is_equal_approx(base, 1.0), "gold_mult base 1.0 with no perks",
		"got %f" % base)
	Prestige.perk_stacks = {Prestige.PERK_GILDED_SOUL: 1}
	_check(is_equal_approx(GameState.gold_mult(), base * 1.10),
		"1 stack = +10% gold", "got %f" % GameState.gold_mult())
	Prestige.perk_stacks = {Prestige.PERK_GILDED_SOUL: 2}
	_check(is_equal_approx(GameState.gold_mult(), base * 1.21),
		"2 stacks = +21% gold (multiplicative)", "got %f" % GameState.gold_mult())
	_check(is_equal_approx(Prestige.gold_mult_bonus(), 1.21),
		"prestige bonus hook reads 1.21")


## --- unit: serialization -----------------------------------------------------
func _unit_serialization() -> void:
	Prestige.from_dict({})
	Prestige.tokens = 5
	Prestige.lifetime_tokens = 7
	Prestige.ascensions = 2
	Prestige.cycle_best_depth = 14
	Prestige.last_cycle_best_depth = 9
	Prestige.perk_stacks = {Prestige.PERK_GILDED_SOUL: 3}
	var snap: Dictionary = Prestige.to_dict()
	Prestige.from_dict({})
	_check(Prestige.tokens == 0 and Prestige.ascensions == 0,
		"from_dict({}) resets to defaults")
	Prestige.from_dict(snap)
	_check(Prestige.to_dict() == snap, "save/load round-trips prestige",
		"got %s" % str(Prestige.to_dict()))


## --- integration ------------------------------------------------------------
func _process(_delta: float) -> void:
	if _finished or _phase != 1:
		return
	if _main == null or not is_instance_valid(_main):
		return
	if (_main.get("gen") as Dictionary).is_empty():
		return
	_phase = 2
	_integration()
	_finish()


func _integration() -> void:
	print("PRESTIGE: integration (real descend funnel + save/load)")
	_main.set("debug_no_shop", true)
	_main.set("debug_fixed_map", 40)
	Prestige.from_dict({})
	# Three genuine 10->11 descends through _on_reached_stairs (the same
	# funnel the stairs use). Critical-retreat flag skips the stair ward so
	# the test doesn't need a cleared room.
	for i in 3:
		GameState.depth = 10
		_main.set("_critical_retreat", true)
		_main.call("_on_reached_stairs")
	_check(Prestige.tokens == 3, "3 real descends = 3 tokens",
		"tokens=%d" % Prestige.tokens)
	_check(Prestige.cycle_best_depth == 11, "cycle best 11 after descends",
		"best=%d" % Prestige.cycle_best_depth)
	# Ascend for real, then round-trip through the save file.
	var r: Dictionary = Prestige.ascend()
	_check(bool(r["ok"]), "integration ascend ok")
	_check(Prestige.stacks_of(Prestige.PERK_GILDED_SOUL) == 2,
		"record bonus on first ascend (11 > 0)")
	var snap: Dictionary = Prestige.to_dict()
	_main.call("save_game")
	Prestige.from_dict({})
	_main.call("load_game")
	# load_game seeds the cycle record from the live depth (11 here) —
	# the new cycle genuinely reached depth 11 before the save.
	_check(Prestige.tokens == int(snap["tokens"])
		and Prestige.lifetime_tokens == int(snap["lifetime_tokens"])
		and Prestige.ascensions == int(snap["ascensions"])
		and Prestige.last_cycle_best_depth == int(snap["last_cycle_best_depth"])
		and Prestige.perk_stacks == snap["perk_stacks"],
		"save/load restores prestige",
		"got %s" % str(Prestige.to_dict()))
	_check(Prestige.cycle_best_depth == GameState.depth,
		"cycle best seeded from live depth on load",
		"best=%d depth=%d" % [Prestige.cycle_best_depth, GameState.depth])
	_check(GameState.gold_mult() > 1.0, "loaded perks still boost gold",
		"gold_mult=%f" % GameState.gold_mult())


func _finish() -> void:
	_finished = true
	_wipe_save()
	if _failures == 0:
		print("PRESTIGE: ALL PASS")
	else:
		printerr("PRESTIGE: %d FAILURES" % _failures)
	get_tree().quit(_failures)
