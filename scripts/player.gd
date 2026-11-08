class_name Player
extends Node3D
## First-person grid player. Moves in discrete steps with smooth tweens;
## the camera rides along at eye height. main.gd decides *where* to go.

const CELL := 2.0
const EYE_HEIGHT := 1.55
const STEP_TIME := 0.16
## Smooth yaw: turns glide instead of snapping (v0.2.0 — felt too snappy
## on device). Responsive but not sluggish; steps retarget mid-glide.
const YAW_SMOOTH_TIME := 0.3
## Walk bob: the camera dips this far (meters) mid-stride and rises back.
## Subtle — sells "walking" instead of "gliding chess piece".
const WALK_BOB := 0.055

## Facing: 0=N(-Z) 1=E(+X) 2=S(+Z) 3=W(-X)
const DIRS: Array[Vector2i] = [
	Vector2i(0, -1), Vector2i(1, 0), Vector2i(0, 1), Vector2i(-1, 0)
]

var grid_pos: Vector2i = Vector2i.ZERO
var facing: int = 0
var busy: bool = false  # a step/turn tween is running

var camera: Camera3D
const _FPRig := preload("res://scripts/first_person_rig.gd")
var fp_rig: _FPRig
var _step_tween: Tween
var _yaw_tween: Tween
var _bob_tween: Tween
## Stride bookkeeping: the tween's finish callback can land a frame after the
## stride actually elapsed (tween processing runs after the brain's tick), so
## `busy` is also cleared on wall-clock stride end — see _settle_stride().
var _pending_done: Callable = Callable()
var _stride_end_msec: int = 0
## Rescue count: strides the wall-clock backstop had to settle because the
## step tween was still running past its wall-clock end (see _settle_stride).
var debug_stride_backstops: int = 0


func _ready() -> void:
	camera = Camera3D.new()
	camera.position = Vector3(0, EYE_HEIGHT, 0)
	camera.fov = 75.0
	camera.current = true  # this view IS the game — make it explicit
	add_child(camera)
	# A little headlamp so the dungeon reads well.
	var lamp := OmniLight3D.new()
	lamp.position = Vector3(0, EYE_HEIGHT + 0.2, 0)
	lamp.light_energy = 1.1
	lamp.omni_range = 9.0
	lamp.omni_attenuation = 1.2
	add_child(lamp)
	# First-person hands: gloved mitt + weapon, riding the camera.
	fp_rig = _FPRig.new()
	camera.add_child(fp_rig)


func place_at(p: Vector2i, p_facing: int = 0) -> void:
	# Teleport: kill any in-flight tween and clear busy, or a stale tween
	# (e.g. death mid-step) would leave the brain frozen forever.
	# A teleport drops the pending stride callback (same as before — the old
	# tween was killed, so its callback never fired either).
	_kill_step_tween()
	_kill_yaw_tween()
	_relevel_camera()
	busy = false
	_pending_done = Callable()
	grid_pos = p
	facing = p_facing
	position = Vector3(p.x * CELL, 0.0, p.y * CELL)
	rotation.y = _facing_to_yaw(facing)


func _facing_to_yaw(f: int) -> float:
	# Facing 0 (north, -Z) = yaw 0; each step clockwise = -90°.
	return -float(f) * PI * 0.5


## Smoothly turn to look along a grid direction (no movement).
## Glides the yaw over YAW_SMOOTH_TIME with an ease-out so the first-person
## view follows the player without snapping. Safe to call while idle —
## it never touches `busy` or the step tween.
func face_direction(dir: Vector2i) -> void:
	var f := DIRS.find(dir)
	if f < 0:
		return
	facing = f
	_smooth_yaw_to(_facing_to_yaw(facing), YAW_SMOOTH_TIME)


## Glide rotation.y to a target yaw along the shortest arc.
func _smooth_yaw_to(target_yaw: float, duration: float) -> void:
	_kill_yaw_tween()
	var start_yaw := rotation.y
	var delta := wrapf(target_yaw - start_yaw, -PI, PI)
	if absf(delta) < 0.001:
		return
	_yaw_tween = create_tween()
	_yaw_tween.tween_property(self, "rotation:y", start_yaw + delta, duration) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


## Dev-only speed multiplier for stress/beta tests (not a game feature).
## Every animation the crawler owns scales with it: stride, turns, yaw.
func _spd() -> float:
	return maxf(GameState.speed_mult, 0.01)


## Depth walk speed (game feature): deeper delves stride faster so big
## deep maps don't slog. Composes with the dev speed cheat above.
func _depth_spd() -> float:
	return GameState.depth_walk_mult()


## Player-chosen delve pace (Settings): leisurely 0.7 / normal 1.0 /
## swift 1.3. Presentation only — same rule as the depth multiplier.
func _pace() -> float:
	return GameState.delve_pace_mult()


## Yaw glide duration: quickens gently with depth instead of whipping.
## A straight 1/_depth_spd() division made deep-delve turns snap (v0.8.0
## device report at depth 10). sqrt scaling keeps the glide smooth while
## the stride still flies; clamped to a readable band. The dev speed cheat
## still divides straight — it's a test tool, not game feel.
func _yaw_time() -> float:
	return clampf(YAW_SMOOTH_TIME / _spd() / sqrt(_depth_spd()) / _pace(), 0.12, YAW_SMOOTH_TIME)


## Tween one grid step in `dir` (grid-space). The camera yaws smoothly in
## parallel with the position glide, retargeting mid-turn if the next step
## starts before the glide finishes. Calls back when done.
##
## `stride_time` overrides the glide duration: the idle brain passes its tick
## interval so consecutive steps chain at constant velocity — no stop-start
## "bot" stepping. The position glide is linear (walking pace, not a hop)
## and the camera dips once per stride (walk bob). Manual mode passes -1
## for the classic snappy STEP_TIME stride.
func move_step(dir: Vector2i, on_done: Callable = Callable(), stride_time: float = -1.0) -> void:
	_settle_stride()
	if busy:
		return
	# Player speed shortens the stride: a faster crawler crosses cells quicker.
	# Depth speed composes in too — deep delves stride faster.
	var stride := stride_time if stride_time > 0.0 else STEP_TIME / _spd() / _depth_spd()
	_begin_stride(stride, on_done)
	# Hands ride the same stride: one source of truth for the walk dip.
	if fp_rig:
		fp_rig.on_stride(stride)
	_kill_step_tween()
	_kill_yaw_tween()  # the step tween owns yaw from here
	_stop_bob()  # new bob starts from the current height — no pop
	var f := DIRS.find(dir)
	if f >= 0:
		facing = f
	grid_pos += dir
	var target := Vector3(grid_pos.x * CELL, 0.0, grid_pos.y * CELL)
	_step_tween = create_tween()
	if f >= 0:
		var target_yaw := _facing_to_yaw(facing)
		var delta := wrapf(target_yaw - rotation.y, -PI, PI)
		_step_tween.tween_property(self, "rotation:y", rotation.y + delta, _yaw_time()) \
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	# Constant-velocity glide: walking, not stepping. The old SINE in-out
	# accelerated and braked every single cell — the "big step" robot feel.
	# Runs in PARALLEL with the yaw turn (not after it): the stride owns the
	# full busy window so chained steps keep constant velocity.
	_step_tween.parallel().tween_property(self, "position", target, stride).set_trans(Tween.TRANS_LINEAR)
	# Walk bob: one gentle dip-and-rise per stride, on its own tween so it
	# never fights the position glide. No per-frame code, no allocations.
	# Symmetric halves (0.5/0.5): the old 0.45/0.55 dipped 18% faster than it
	# rose — a baked-in limp.
	_bob_tween = create_tween()
	_bob_tween.tween_property(camera, "position:y", EYE_HEIGHT - WALK_BOB, stride * 0.5) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_bob_tween.tween_property(camera, "position:y", EYE_HEIGHT, stride * 0.5) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_step_tween.tween_callback(_finish_stride)


## Glide a 90° turn. `clockwise` true = turn right.
func turn(clockwise: bool, on_done: Callable = Callable()) -> void:
	_settle_stride()
	if busy:
		return
	var dur := _yaw_time()
	_begin_stride(dur, on_done)
	facing = posmod(facing + (1 if clockwise else -1), 4)
	_kill_step_tween()
	_kill_yaw_tween()
	_step_tween = create_tween()
	var start_yaw := rotation.y
	var delta := wrapf(_facing_to_yaw(facing) - start_yaw, -PI, PI)
	_step_tween.tween_property(self, "rotation:y", start_yaw + delta, dur) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_step_tween.tween_callback(_finish_stride)


## Start a busy window of `duration` seconds: records the wall-clock stride
## end and stashes the completion callback.
func _begin_stride(duration: float, on_done: Callable) -> void:
	busy = true
	_pending_done = on_done
	_stride_end_msec = Time.get_ticks_msec() + int(duration * 1000.0)


## If the stride's wall-time is up but the tween's finish callback hasn't
## fired yet this frame, settle it now so the next step chains with no gap.
## A 2ms grace covers sub-millisecond jitter between the brain's accumulated
## deltas and the wall clock (firing a finished stride's callback 2ms early
## is harmless — grid state is final from step start).
func _settle_stride() -> void:
	if busy and Time.get_ticks_msec() + 2 >= _stride_end_msec:
		# Backstop rescue: the stride's tween is still running past its
		# wall-clock end. A lost tween callback would otherwise leave the
		# brain gated on `busy` forever — nothing else calls this.
		if _step_tween != null and _step_tween.is_valid() and _step_tween.is_running():
			debug_stride_backstops += 1
		_finish_stride()


## Idempotent stride completion — safe from the tween callback or from
## _settle_stride, whichever lands first. Fires the pending callback once.
func _finish_stride() -> void:
	if not busy:
		return
	busy = false
	if _step_tween and _step_tween.is_valid() and _step_tween.is_running():
		_step_tween.kill()
	_step_tween = null
	var cb := _pending_done
	_pending_done = Callable()
	if cb.is_valid():
		cb.call()


func _kill_step_tween() -> void:
	if _step_tween and _step_tween.is_valid():
		_step_tween.kill()
	_step_tween = null


func _kill_yaw_tween() -> void:
	if _yaw_tween and _yaw_tween.is_valid():
		_yaw_tween.kill()
	_yaw_tween = null


## Stop the bob tween without touching the camera (for chaining steps:
## the next bob starts from the current height — no pop).
func _stop_bob() -> void:
	if _bob_tween and _bob_tween.is_valid():
		_bob_tween.kill()
	_bob_tween = null


## Ease the camera back to eye height instead of snapping (for teleports:
## a killed bob mid-dip used to pop the camera up in one frame).
func _relevel_camera() -> void:
	_stop_bob()
	if camera == null or is_equal_approx(camera.position.y, EYE_HEIGHT):
		return
	_bob_tween = create_tween()
	_bob_tween.tween_property(camera, "position:y", EYE_HEIGHT, 0.12) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
