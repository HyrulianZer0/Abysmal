extends Node
## Turn-based manual-mode regression test (v0.4.0):
##  1. Input parity: the touch D-pad (pad_action signal) steps the player,
##     and a real keyboard InputEvent through _unhandled_input turns the
##     player — both route through the same _handle_action pipeline.
##  2. With idle OFF and no input, monsters never act (world frozen).
##  3. Each player action grants every living monster exactly one turn:
##     an adjacent foe strikes exactly once; a mid-range foe steps exactly
##     one cell closer.
## Run: godot --headless --path . tests/turn_based_scene.tscn
## Exits 0 on success, 1 on failure.

const DG = preload("res://scripts/dungeon_gen.gd")
const DIRS: Array[Vector2i] = [
	Vector2i(0, -1), Vector2i(1, 0), Vector2i(0, 1), Vector2i(-1, 0)
]

var _main: Node = null
var _touch: Node = null
var _phase := 0
var _frames := 0
var _phase_frame := 0
var _failures := 0
var _f0 := 0
var _gp0 := Vector2i.ZERO
var _frozen := {}
var _frozen_hp := 0.0
var _combat_hp := 0.0
var _striker: Node = null


func _ready() -> void:
	var packed: PackedScene = load("res://scenes/main.tscn")
	_main = packed.instantiate()
	get_tree().root.add_child.call_deferred(_main)
	print("TURNTEST: scene starting")


func _fail(msg: String) -> void:
	_failures += 1
	printerr("TURNTEST FAIL: ", msg)


func _ok(msg: String) -> void:
	print("TURNTEST PASS: ", msg)


func _player() -> Node:
	return _main.get("player")


func _manhattan(a: Vector2i, b: Vector2i) -> int:
	return absi(a.x - b.x) + absi(a.y - b.y)


func _goto(n: int) -> void:
	_phase = n
	_phase_frame = _frames


## Facing index with a plain open floor cell ahead (no wall/stairs/enemy/
## unopened chest). -1 if none.
func _open_dir() -> int:
	var p: Node = _player()
	for i in DIRS.size():
		var c: Vector2i = p.grid_pos + DIRS[i]
		if _main.cell_at(c) != DG.FLOOR:
			continue
		if _main.enemy_at(c) != null:
			continue
		var chd: Dictionary = _main.chest_at(c)
		if not chd.is_empty() and not bool(chd["opened"]):
			continue
		return i
	return -1


## Floor cell maximizing distance from the player (enemy parking spot).
func _far_cell() -> Vector2i:
	var p: Node = _player()
	var best := Vector2i(-1, -1)
	var best_d := -1
	var w: int = _main.gen["width"]
	var h: int = _main.gen["height"]
	for y in h:
		for x in w:
			var c := Vector2i(x, y)
			if _main.cell_at(c) != DG.FLOOR:
				continue
			var d := _manhattan(c, p.grid_pos)
			if d > best_d:
				best_d = d
				best = c
	return best


func _teleport(e: Node, c: Vector2i) -> void:
	e.grid_pos = c
	e.position = _main.view.world_pos(c)


func _living_enemies() -> Array:
	var out := []
	for e in _main.get("enemies"):
		if is_instance_valid(e) and not e.dead:
			out.append(e)
	return out


func _process(_delta: float) -> void:
	_frames += 1
	if _main == null or not is_instance_valid(_main):
		return
	if _frames > 3000:
		_fail("test timed out waiting for the game (phase %d)" % _phase)
		_quit()
		return
	match _phase:
		0:
			if _frames >= 12:
				_begin()
		1:
			# Wait for any in-flight tween, then take one D-pad step.
			if not _player().busy:
				_do_step()
		2:
			if not _player().busy:
				_check_step()
		3:
			if not _player().busy:
				_check_turn()
		4:
			# No input for 120 frames: the world must stay frozen.
			if _frames - _phase_frame >= 120:
				_check_frozen()
		5:
			if not _player().busy:
				_setup_striker()
		6:
			if not _player().busy:
				_check_single_strike()
		7:
			# No input for 90 frames: no extra strikes allowed.
			if _frames - _phase_frame >= 90:
				_setup_stepper()
		8:
			if not _player().busy:
				_finish()


func _quit() -> void:
	print("TURNTEST: %d failures" % _failures)
	if _failures == 0:
		print("TURNTEST: ALL PASS")
		get_tree().quit(0)
	else:
		get_tree().quit(1)


# -- phase 0/1: go manual, verify D-pad wiring, take one D-pad step --------

func _begin() -> void:
	GameState.idle_mode = false
	var found := _main.find_children("", "TouchControls", true, false)
	if found.is_empty():
		_fail("TouchControls node missing")
		_goto(99)
		return
	_touch = found[0]
	if not _touch.is_connected("pad_action", Callable(_main, "_handle_action")):
		_fail("pad_action not connected to main._handle_action")
		_goto(99)
		return
	_ok("pad_action wired to the keyboard action pipeline")
	_goto(1)


func _do_step() -> void:
	var d := _open_dir()
	if d < 0:
		_fail("no open direction for the step test")
		_goto(99)
		return
	_player().place_at(_player().grid_pos, d)
	_f0 = d
	_gp0 = _player().grid_pos
	_touch.pad_action.emit(&"move_forward")
	_goto(2)


# -- phase 2: the D-pad step must have moved the player one cell -----------

func _check_step() -> void:
	var p: Node = _player()
	var want: Vector2i = _gp0 + DIRS[_f0]
	if p.grid_pos != want:
		_fail("D-pad step: grid=%s, want=%s" % [str(p.grid_pos), str(want)])
		_goto(99)
		return
	_ok("D-pad step moved the player %s -> %s" % [str(_gp0), str(p.grid_pos)])
	# Keyboard path: a real InputEvent through _unhandled_input, so the
	# keyboard dispatcher stays guarded alongside the touch signal.
	var ev := InputEventAction.new()
	ev.action = &"turn_left"
	ev.pressed = true
	_main._unhandled_input(ev)
	_goto(3)


# -- phase 3: the D-pad turn must have rotated the player ------------------

func _check_turn() -> void:
	var p: Node = _player()
	var want := posmod(_f0 - 1, 4)
	# Snapshot the frozen world first, so the freeze check stays meaningful
	# even if the turn assertion below fails.
	_frozen.clear()
	for e in _living_enemies():
		_frozen[e] = e.grid_pos
	_frozen_hp = GameState.hp
	if int(p.facing) != want:
		_fail("D-pad turn: facing=%d, want=%d" % [p.facing, want])
		_goto(99)
		return
	_ok("keyboard turn rotated the player (facing %d)" % p.facing)
	_goto(4)


# -- phase 4: no input -> nothing moves ------------------------------------

func _check_frozen() -> void:
	for e in _living_enemies():
		if _frozen.has(e) and e.grid_pos != _frozen[e]:
			_fail("enemy moved with idle OFF and no input")
			_goto(99)
			return
	if GameState.hp != _frozen_hp:
		_fail("player took damage with idle OFF and no input")
		_goto(99)
		return
	_ok("world frozen: %d monsters idle, hp steady over 120 frames" % _frozen.size())
	_check_free_potion()
	_goto(5)


## Quaffing a potion in manual mode is a free action: HP restored, and no
## monster gets a turn.
func _check_free_potion() -> void:
	GameState.health_potions = 2
	GameState.hp = GameState.max_hp * 0.5
	_frozen.clear()
	for e in _living_enemies():
		_frozen[e] = e.grid_pos
	var before_hp: float = GameState.hp
	_main._handle_action(&"drink_potion")
	if GameState.hp <= before_hp:
		_fail("potion did not restore HP")
		_goto(99)
		return
	for e in _living_enemies():
		if _frozen.has(e) and e.grid_pos != _frozen[e]:
			_fail("enemy moved when quaffing a potion — not a free action")
			_goto(99)
			return
	_ok("potion quaff is free: hp %s -> %s, monsters frozen" % [str(before_hp), str(GameState.hp)])


# -- phase 5/6: park one foe adjacent, turn in place -> one strike ---------

func _setup_striker() -> void:
	GameState.hp = GameState.max_hp  # clean slate for the strike test
	var foes := _living_enemies()
	if foes.is_empty():
		_fail("no living enemies for the strike test")
		_goto(99)
		return
	# Prefer an awake foe: ~30% spawn asleep, and sleepers never strike.
	# Wave 3: prefer a foe that both strikes on demand AND steps closer
	# on a monster turn. Special-windup casters (banshee), breath
	# windup (drake), kiters (archer/imp/pixie), retreaters
	# (skirmishers), and telegraph-rooted chargers (boar/minotaur)
	# legitimately do something else on their turn — picking one would
	# fail the test for correct behavior, not a bug. Fall back to any
	# awake foe only if no advance-type foe spawned.
	_striker = null
	var advance_types := ["slime", "skeleton", "zombie", "golem", "orc",
		"oni", "troll", "kappa", "ghost", "scorpion", "wolf", "rat",
		"spider", "snake", "kobold"]
	for f in foes:
		if not f.asleep and advance_types.has(str(f.type_id)):
			_striker = f
			break
	if _striker == null:
		for f in foes:
			if not f.asleep:
				_striker = f
				break
	if _striker == null:
		_striker = foes[0]
		_main._wake(_striker)
	var p: Node = _player()
	var adj := Vector2i(-1, -1)
	for d in DIRS:
		var c: Vector2i = p.grid_pos + d
		if _main.cell_at(c) == DG.FLOOR and _main.enemy_at(c) == null:
			adj = c
			break
	if adj == Vector2i(-1, -1):
		_fail("no adjacent floor cell for the striker")
		_goto(99)
		return
	_teleport(_striker, adj)
	var far := _far_cell()
	for e in foes:
		if e != _striker:
			_teleport(e, far)
			if _manhattan(far, p.grid_pos) <= 6:
				_fail("parking cell too close (dist<=6)")
				_goto(99)
				return
	_combat_hp = GameState.hp
	_main._handle_action(&"turn_left")  # turn in place: costs one monster turn
	_goto(6)


func _check_single_strike() -> void:
	if GameState.hp >= _combat_hp:
		_fail("adjacent foe did not strike on the player turn")
		_goto(99)
		return
	var p: Node = _player()
	if _manhattan(_striker.grid_pos, p.grid_pos) != 1:
		_fail("striker moved instead of attacking")
		_goto(99)
		return
	_ok("one player turn -> exactly one strike (hp %s -> %s)"
		% [str(_combat_hp), str(GameState.hp)])
	_combat_hp = GameState.hp  # freeze check below reuses this
	_goto(7)


# -- phase 7/8: mid-range foe steps exactly one cell closer ----------------

func _setup_stepper() -> void:
	if GameState.hp != _combat_hp:
		_fail("hp changed with idle OFF and no input (extra strike!)")
		_goto(99)
		return
	_ok("no extra strikes without input — one turn really means one turn")
	var p: Node = _player()
	# Straight open line: foe at +3d, player steps sideways, foe -> +2d.
	var line_dir := -1
	for i in DIRS.size():
		var line_ok := true
		for k in [1, 2, 3]:
			if _main.cell_at(p.grid_pos + DIRS[i] * k) != DG.FLOOR:
				line_ok = false
				break
		if line_ok:
			line_dir = i
			break
	if line_dir < 0:
		_fail("no 3-cell straight line for the stepper")
		_goto(99)
		return
	# Player steps perpendicular: pick an open side cell.
	var side := -1
	for off in [1, 3]:  # DIRS rotated +/-90 from line_dir
		var s: int = (line_dir + off) % 4
		var c: Vector2i = p.grid_pos + DIRS[s]
		if _main.cell_at(c) == DG.FLOOR and _main.enemy_at(c) == null:
			var chd: Dictionary = _main.chest_at(c)
			if chd.is_empty() or bool(chd["opened"]):
				side = s
				break
	if side < 0:
		_fail("no open side cell for the player step")
		_goto(99)
		return
	_teleport(_striker, p.grid_pos + DIRS[line_dir] * 3)
	_player().place_at(p.grid_pos, side)
	_frozen.clear()
	for e in _living_enemies():
		_frozen[e] = e.grid_pos
	_main._handle_action(&"move_forward")
	_goto(8)


func _finish() -> void:
	var p: Node = _player()
	var moved := false
	for e in _living_enemies():
		if not _frozen.has(e):
			continue
		var before: Vector2i = _frozen[e]
		var d0 := _manhattan(before, p.grid_pos)
		var d1 := _manhattan(e.grid_pos, p.grid_pos)
		if e == _striker:
			if d1 != d0 - 1:
				_fail("stepper: dist %d -> %d, want exactly one closer" % [d0, d1])
				_quit()
				return
			moved = true
		elif d1 != d0:
			_fail("bystander enemy moved on the player turn")
			_quit()
			return
	if not moved:
		_fail("stepper did not move")
		_quit()
		return
	_ok("mid-range foe stepped exactly one cell closer; bystanders dormant")
	_quit()
