extends Node
## Wave 3 main-loop wiring scene tests (boots the real main.tscn).
## Covers what unit tests cannot: _tick_enemy_behavior in main.gd,
## grapple movement block + struggle-by-movement-keys, flyer reach,
## venom DoT application, ambush reveal on bump-attack, kobold trap
## place/trigger/root, pixie player-side dazzle store, telegraph
## sidestep chance, and behavior-directed retreat stepping.
##
## SAVE SAFETY: this harness backs the shared user://savegame.dat up
## in memory, deletes it for a fresh floor, and RESTORES it on quit
## (existing scene suites just delete it — this one does not).
## Player HP is set huge (100000) so damage assertions never flake
## on death; Agility is 0 on a fresh run, so damage_player never
## dodges in these tests.
##
## Run: godot --headless --path . tests/wave3_mainloop_scene.tscn
## Exits 0 on success, 1 on failure.

const DG = preload("res://scripts/dungeon_gen.gd")
const DIRS: Array[Vector2i] = [
	Vector2i(0, -1), Vector2i(1, 0), Vector2i(0, 1), Vector2i(-1, 0)
]

var _main: Node = null
var _phase := 0
var _frames := 0
var _failures := 0
var _saved_text := ""
var _had_save := false
var _player_cell := Vector2i.ZERO
var _foe: Node = null
var _foe_hp := 0.0
var _hp_mark := 0.0
var _wait_frames := 0


func _check(cond: bool, name: String, detail: String = "") -> void:
	if cond:
		print("  PASS  " + name)
	else:
		_failures += 1
		printerr("  FAIL  " + name + "  " + detail)


func _quit() -> void:
	# Restore the shared save (or remove the test-created one).
	if _had_save:
		var f := FileAccess.open("user://savegame.dat", FileAccess.WRITE)
		if f != null:
			f.store_string(_saved_text)
			f.close()
	else:
		if FileAccess.file_exists("user://savegame.dat"):
			DirAccess.remove_absolute("user://savegame.dat")
	print("WAVE3-MAINLOOP: %d failures" % _failures)
	if _failures == 0:
		print("WAVE3-MAINLOOP: ALL PASS")
		get_tree().quit(0)
	else:
		get_tree().quit(1)


func _ready() -> void:
	if FileAccess.file_exists("user://savegame.dat"):
		var f := FileAccess.open("user://savegame.dat", FileAccess.READ)
		if f != null:
			_saved_text = f.get_as_text()
			f.close()
			_had_save = true
		DirAccess.remove_absolute("user://savegame.dat")
	var packed: PackedScene = load("res://scenes/main.tscn")
	_main = packed.instantiate()
	get_tree().root.add_child.call_deferred(_main)
	print("WAVE3-MAINLOOP: scene starting (save backed up: %s)" % str(_had_save))


func _player() -> Node:
	return _main.get("player")


func _open_cell_near(origin: Vector2i, dist: int) -> Vector2i:
	for d in DIRS:
		var c := origin + d * dist
		if _main.cell_at(c) != DG.FLOOR:
			continue
		if _main.enemy_at(c) != null:
			continue
		var chd: Dictionary = _main.chest_at(c)
		if not chd.is_empty() and not bool(chd["opened"]):
			continue
		var dr: Dictionary = _main.door_at(c)
		if not dr.is_empty() and str(dr["state"]) != "open":
			continue
		return c
	return Vector2i(-999, -999)


func _despawn(foe: Node) -> void:
	if foe == null or not is_instance_valid(foe):
		return
	var arr: Array = _main.get("enemies")
	arr.erase(foe)
	foe.queue_free()


func _wait_busy_clear() -> bool:
	# The swing tween resolves the hit on the downswing; wait for it.
	if _wait_frames > 0:
		_wait_frames -= 1
		return false
	if _player().busy:
		_wait_frames = 40
		return false
	return true


func _process(_delta: float) -> void:
	_frames += 1
	if _frames > 9000:
		_check(false, "test timed out (phase %d)" % _phase)
		_quit()
		return
	if _main == null or not is_instance_valid(_main) or _player() == null:
		return
	match _phase:
		0:
			if _frames < 20:
				return
			GameState.idle_mode = false
			GameState.max_hp = 100000.0
			GameState.hp = 100000.0
			_player_cell = _player().grid_pos
			_phase = 1
		1:
			# --- Grapple: kappa adjacent, monster turns until held ---
			var kap_cell := _open_cell_near(_player_cell, 1)
			if kap_cell == Vector2i(-999, -999):
				_check(false, "grapple setup: no adjacent open cell")
				_quit()
				return
			_foe = _main._spawn_enemy("kappa", kap_cell, false)
			_phase = 2
			_wait_frames = 0
		2:
			# Up to 12 monster turns: grab telegraph (turn 1) -> held
			# (turn 2), unless a 25% sidestep breaks it (then retry).
			if _main._player_is_grappled():
				_check(true, "grapple: player held after monster turns")
				_phase = 3
				return
			_wait_frames += 1
			if _wait_frames > 12:
				_check(false, "grapple: player never held",
					"phase=" + str(_foe.behavior_state.grapple_phase))
				_quit()
				return
			_main._monster_turn()
		3:
			# Movement while held must NOT move the player (struggle).
			var before: Vector2i = _player().grid_pos
			_main._try_step(DIRS[0])
			_check(_player().grid_pos == before,
				"grapple: _try_step does not move a held player")
			# Four more struggles (5 total) must break the hold. Each
			# _try_step also advances a monster turn (hold timer ticks),
			# but 5 struggles land before the 5s hold expires.
			for _i in 4:
				_main._try_step(DIRS[0])
			_check(not _main._player_is_grappled(),
				"grapple: 5 struggles break the hold")
			_despawn(_foe)
			_foe = null
			_phase = 4
		4:
			# --- Flyer reach: hovering bat unreachable, diving reachable ---
			var bat_cell := _open_cell_near(_player_cell, 1)
			if bat_cell == Vector2i(-999, -999):
				_check(false, "flyer setup: no adjacent open cell")
				_quit()
				return
			_foe = _main._spawn_enemy("bat", bat_cell, false)
			_check(not _foe.is_melee_reachable(), "flyer: hovering bat unreachable")
			_foe_hp = _foe.hp
			_main._player_attack(_foe)
			_check(absf(_foe.hp - _foe_hp) < 0.001,
				"flyer: bump-attack on hovering bat deals no damage")
			# Two 1.0s ticks: hover -> dive -> reachable altitude 0.2.
			_main._tick_enemy_behavior(_foe, 1.0)
			_main._tick_enemy_behavior(_foe, 1.0)
			_check(_foe.is_melee_reachable(), "flyer: diving bat reachable",
				"alt=%.2f phase=%s" % [_foe.behavior_state.altitude,
					_foe.behavior_state.flight_phase])
			_foe_hp = _foe.hp
			_main._player_attack(_foe)
			_wait_frames = 0
			_phase = 5
		5:
			if not _wait_busy_clear():
				return
			_check(_foe.hp < _foe_hp, "flyer: diving bat takes damage",
				"hp %.1f -> %.1f" % [_foe_hp, _foe.hp])
			_despawn(_foe)
			_foe = null
			_phase = 6
		6:
			# --- Venom DoT: scorpion sting stacks, tick deals damage ---
			var sc_cell := _open_cell_near(_player_cell, 1)
			if sc_cell == Vector2i(-999, -999):
				_check(false, "venom setup: no adjacent open cell")
				_quit()
				return
			_foe = _main._spawn_enemy("scorpion", sc_cell, false)
			_main._tick_enemy_behavior(_foe, 0.1)
			_check(_foe.behavior_attack_kind == "sting",
				"venom: scorpion intent kind = sting", _foe.behavior_attack_kind)
			_main._enemy_strike(_foe)
			_check(_foe.behavior_state.venom_stacks.size() == 1,
				"venom: sting applies 1 stack")
			_hp_mark = GameState.hp
			_main._tick_enemy_behavior(_foe, 1.0)
			_check(GameState.hp < _hp_mark, "venom: tick deals DoT to player",
				"hp %.1f -> %.1f" % [_hp_mark, GameState.hp])
			_check(absf((_hp_mark - GameState.hp) - 1.5) < 0.01,
				"venom: 1 stack x 0.30 x atk 5 = 1.5 damage",
				"got %.2f" % (_hp_mark - GameState.hp))
			_despawn(_foe)
			_foe = null
			_phase = 7
		7:
			# --- Ambush reveal on bump-attack ---
			var sp_cell := _open_cell_near(_player_cell, 1)
			if sp_cell == Vector2i(-999, -999):
				_check(false, "ambush setup: no adjacent open cell")
				_quit()
				return
			_foe = _main._spawn_enemy("spider", sp_cell, false)
			_check(_foe.behavior_state.hidden, "ambush: spider starts hidden")
			_main._player_attack(_foe)
			_wait_frames = 0
			_phase = 8
		8:
			if not _wait_busy_clear():
				return
			_check(not _foe.behavior_state.hidden,
				"ambush: bump-attack reveals the spider")
			_despawn(_foe)
			_foe = null
			_phase = 9
		9:
			# --- Pixie dazzle store + sidestep chance helper ---
			var px_cell := _open_cell_near(_player_cell, 1)
			if px_cell == Vector2i(-999, -999):
				_check(false, "dazzle setup: no adjacent open cell")
				_quit()
				return
			_foe = _main._spawn_enemy("pixie", px_cell, false)
			_main._enemy_strike(_foe)
			_check(absf(float(_main.get("_player_dazzle_timer")) - 4.0) < 0.001,
				"dazzle: pixie strike sets 4s player dazzle",
				"got %s" % str(_main.get("_player_dazzle_timer")))
			_despawn(_foe)
			var oni_cell := _open_cell_near(_player_cell, 1)
			if oni_cell == Vector2i(-999, -999):
				_check(false, "sidestep setup: no adjacent open cell")
				_quit()
				return
			_foe = _main._spawn_enemy("oni", oni_cell, false)
			_main._tick_enemy_behavior(_foe, 0.1)
			_check(_foe.behavior_telegraph == "club_raised",
				"sidestep: oni telegraphs club_raised", _foe.behavior_telegraph)
			_check(absf(_main.telegraph_sidstep_chance(_foe) - 0.25) < 0.001,
				"sidestep: chance 0.25 in telegraph window")
			var slime_cell := _open_cell_near(_player_cell, 2)
			var slime: Node = _main._spawn_enemy("slime", slime_cell, false)
			slime.update_behavior(0.1, {"player_pos": Vector2(
				float(_player_cell.x), float(_player_cell.y))})
			_check(absf(_main.telegraph_sidstep_chance(slime)) < 0.001,
				"sidestep: chance 0 outside telegraph window")
			_despawn(_foe)
			_despawn(slime)
			_foe = null
			_phase = 10
		10:
			# --- Kobold trap: placed at 2-7 tiles, triggers, roots ---
			var kb_cell := Vector2i(-999, -999)
			for d in DIRS:
				var c := _player_cell + d * 3
				if _main.cell_at(c) == DG.FLOOR and _main.enemy_at(c) == null \
						and _main.chest_at(c).is_empty():
					var dr: Dictionary = _main.door_at(c)
					if dr.is_empty() or str(dr["state"]) == "open":
						kb_cell = c
						break
			if kb_cell == Vector2i(-999, -999):
				_check(false, "trap setup: no kobold cell at dist 3")
				_quit()
				return
			_foe = _main._spawn_enemy("kobold", kb_cell, false)
			_main._tick_enemy_behavior(_foe, 1.0)
			_check(_foe.behavior_state.traps.size() == 1,
				"trapper: kobold places a trap at 3 tiles",
				"got %d" % _foe.behavior_state.traps.size())
			# Step the player onto the trap cell, arm it, trigger it.
			var trap_pos: Vector2 = _foe.behavior_state.traps[0].position
			var trap_cell := Vector2i(int(trap_pos.x), int(trap_pos.y))
			_player().place_at(trap_cell, 0)
			_main._tick_enemy_behavior(_foe, 2.5)
			_hp_mark = GameState.hp
			_main._tick_enemy_behavior(_foe, 0.1)
			_check(absf(float(_main.get("_player_root_timer")) - 2.0) < 0.001,
				"trapper: sprung trap roots player 2s",
				"got %s" % str(_main.get("_player_root_timer")))
			_check(GameState.hp < _hp_mark, "trapper: sprung trap deals damage")
			var rooted_cell: Vector2i = _player().grid_pos
			_main._try_step(DIRS[0])
			_check(_player().grid_pos == rooted_cell,
				"root: _try_step does not move a rooted player")
			_despawn(_foe)
			_foe = null
			_phase = 11
		11:
			# --- Behavior-directed retreat: frog at dist 2 steps AWAY ---
			var fr_cell := Vector2i(-999, -999)
			var retreat_cell := Vector2i(-999, -999)
			_player().place_at(_player_cell, 0)
			for d in DIRS:
				var c := _player_cell + d * 2
				var r := _player_cell + d * 3
				if _main.cell_at(c) == DG.FLOOR and _main.cell_at(r) == DG.FLOOR \
						and _main.enemy_at(c) == null and _main.enemy_at(r) == null \
						and _main.chest_at(c).is_empty() and _main.chest_at(r).is_empty():
					var dc: Dictionary = _main.door_at(c)
					var dr2: Dictionary = _main.door_at(r)
					if (dc.is_empty() or str(dc["state"]) == "open") \
							and (dr2.is_empty() or str(dr2["state"]) == "open"):
						fr_cell = c
						retreat_cell = r
						break
			if fr_cell == Vector2i(-999, -999):
				_check(false, "retreat setup: no frog geometry")
				_quit()
				return
			_foe = _main._spawn_enemy("frog", fr_cell, false)
			var d0: int = _main._manhattan(_foe.grid_pos, _player().grid_pos)
			_main._tick_enemy_behavior(_foe, 1.0)
			_check(_foe.behavior_action == "retreat",
				"retreat: frog dwell expires into retreat", _foe.behavior_action)
			_main._enemy_step_toward(_foe)
			var d1: int = _main._manhattan(_foe.grid_pos, _player().grid_pos)
			_check(d1 == d0 + 1, "retreat: frog steps away (dist %d -> %d)" % [d0, d1])
			_check(_foe.grid_pos == retreat_cell, "retreat: frog takes the away cell")
			_despawn(_foe)
			_foe = null
			_phase = 12
		12:
			# --- Traps persist after the trapper dies (floor store) ---
			var kb2_cell := _open_cell_near(_player_cell, 3)
			if kb2_cell == Vector2i(-999, -999):
				kb2_cell = _open_cell_near(_player_cell, 2)
			_foe = _main._spawn_enemy("kobold", kb2_cell, false)
			_main._tick_enemy_behavior(_foe, 1.0)
			var n_traps: int = _foe.behavior_state.traps.size()
			_check(n_traps == 1, "persist: kobold placed a trap before death")
			# Kill via the died signal path (take_damage emits died).
			_foe.take_damage(9999.0)
			_check(int((_main.get("_floor_traps") as Array).size()) == 1,
				"persist: trap harvested to floor store on death",
				"got %d" % int((_main.get("_floor_traps") as Array).size()))
			_foe = null
			_quit()
