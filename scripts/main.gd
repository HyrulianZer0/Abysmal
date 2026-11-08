extends Node
## Main orchestrator: builds the world, runs the game loop, idle auto-explore,
## combat resolution, and the roguelike run/death/restart cycle.
##
## Smoke test: run with `-- --smoke` (headless) to auto-play with idle mode
## on a fixed seed and quit after ~30s or 2 deaths.

const DungeonGenScript := preload("res://scripts/dungeon_gen.gd")
const CombatScript := preload("res://scripts/combat.gd")
const EnemyScript := preload("res://scripts/enemy.gd")
const PlayerScript := preload("res://scripts/player.gd")
const DungeonViewScript := preload("res://scripts/dungeon_view.gd")
const HUDScript := preload("res://scripts/hud.gd")
const PopupScript := preload("res://scripts/damage_popup.gd")
const TouchControlsScript := preload("res://scripts/touch_controls.gd")
const ItemsScript := preload("res://scripts/items.gd")
const ShopScript := preload("res://scripts/shop.gd")
const TownScript := preload("res://scripts/town_view.gd")
const OverworldScript := preload("res://scripts/overworld_view.gd")
const FoundersScript := preload("res://scripts/founders.gd")
const LifeTreeViewScript := preload("res://scripts/life_tree_view.gd")

const DIRS: Array[Vector2i] = [
	Vector2i(0, -1), Vector2i(1, 0), Vector2i(0, 1), Vector2i(-1, 0)
]

# Fallback input map (project.godot already defines these; belt & suspenders).
const FALLBACK_INPUT := {
	"move_forward": [KEY_W, KEY_UP],
	"move_back": [KEY_S, KEY_DOWN],
	"strafe_left": [KEY_A],
	"strafe_right": [KEY_D],
	"turn_left": [KEY_Q, KEY_LEFT],
	"turn_right": [KEY_E, KEY_RIGHT],
	"toggle_idle": [KEY_SPACE, KEY_I],
	"drink_potion": [KEY_H],
	"restart_run": [KEY_R],
}

var rng := RandomNumberGenerator.new()
var gen: Dictionary = {}
var view: DungeonView
var player: Player
var hud: HUD
var touch_controls: TouchControls
## Phase 3: hub views. At most one exists at a time, and only outside
## DUNGEON mode — the state machine (GameMode) owns the legal moves.
var town_view: TownView = null
var overworld_view: OverworldView = null
var life_tree_view: LifeTreeView = null
var _deed_dialog: Node = null
var enemies: Array[Enemy] = []
var explored := {}
## Loot pickups: Array of {pos: Vector2i, kind: String, taken: bool}.
var loot: Array = []
## Chests: Array of {pos: Vector2i, opened: bool, sealed: bool,
##   lock_tier: int, tumblers: int, room_idx: int}.
var chests: Array = []
## Doors: Array of {pos: Vector2i, state: String ("closed"/"locked"/"open"),
##   axis: String, tier: int, tumblers: int, bash_hp: int}.
var doors: Array = []
## Room rects for the current floor (seal/ward checks).
var floor_rooms: Array = []
var _stairs_room := -1
var _hp_mult := 1.0
var _atk_mult := 1.0
## Floor-clear shop open: the world pauses while the player shops.
var _shop_open := false
## Beta-test hook: skip the floor-clear shop so long runs never stall.
var debug_no_shop := false
## Idle-brain telemetry for beta tests: what the brain targeted last.
var debug_last_target := ""
## Beta-test hook: when true, every floor generates as a monster floor.
var debug_force_monster_floor := false
## Beta-test hook: when > 0, every floor generates at this fixed size
## instead of the depth-scaled size (A/B control for depth scaling).
var debug_fixed_map := 0
## Soak-test event counters (reset per run in _ready): doors opened by push,
## by pick, and by bash; seals broken; chests opened; sleepers woken (any
## cause); patrol spawns from bashing.
var debug_doors_pushed := 0
var debug_doors_picked := 0
var debug_doors_bashed := 0
var debug_seals_broken := 0
var debug_chests_opened := 0
var debug_sleepers_woken := 0
var debug_patrol_spawns := 0
## Wave 3 behavior wiring state (transient — never saved; traps are
## floor-transient too, so a save/load legitimately drops them).
## _player_dazzle_timer: seconds the PLAYER stays dazzled (pixie flash):
## player attacks miss 50% while it runs. This is the player-side store
## Wave 2 flagged as missing — the enemy's own dazzle_miss_chance is
## only for dazzled ENEMIES, never the player.
## _player_root_timer: seconds the player cannot move (sprung trap).
## _floor_traps: live traps harvested from dead trappers — traps PERSIST
## after the trapper dies (Behaviors rule), so death moves them here
## instead of freeing them with the enemy node. Entries: {trap, atk}.
## TELEGRAPH_SIDESTEP_CHANCE: the Wave 3 dodge/block decision (see
## _enemy_strike): NO new dodge/block input exists, so the minimal
## honest mechanic is a windowed BONUS to dodging — a flat sidestep
## roll during telegraph windows, on top of the existing generic
## Agility dodge_chance() inside damage_player(). It is never presented
## as a windowed action; it is a passive tell-reward.
const TELEGRAPH_SIDESTEP_CHANCE := 0.25
const TELEGRAPH_DAZZLE_MISS := 0.5
var _player_dazzle_timer := 0.0
var _player_root_timer := 0.0
var _floor_traps: Array = []
## Soak-test counters for the room-sweep brain: depth-shop patch-ups bought,
## and unfinished business (living foes + unopened chests + unclaimed loot)
## left behind on non-retreat descends.
var debug_shop_heals := 0
var debug_unfinished_at_descend := 0
var debug_unfinished_foes := 0
var debug_unfinished_chests := 0
var debug_unfinished_loot := 0
var debug_unfinished_chests_locked := 0
var debug_retreat_descends := 0

## Room-by-room idle brain state (reset per floor in _new_depth).
var _brain_room := -1
## The exit, once seen, is "mentally marked" — remembered while the floor
## keeps being swept. Descending still waits for a clear floor.
var _stairs_marked := false
## Critical HP (<=25%): push for the stairs and the depth shop's patch-up.
const CRITICAL_HP_FRAC := 0.25
## Backstab: striking an enemy from behind (or while it sleeps) deals bonus.
const BACKSTAB_MULT := 1.5
var _critical_retreat := false
## Rooms whose targets proved unreachable: skipped for a while so the brain
## can't ping-pong on them instead of finishing the floor (msec timestamps).
var _room_cooldown := {}

## Fresh-loot barks: the idle companion reacts after combat, on the way to
## loot. [popup text, log text] pairs. Fires once per room's loot phase at
## ~60% — flavor only, never mid-fight, never spammy.
const FRESH_LOOT_BARKS := [
	["Oh, that's fresh loot!", "Oh, that's fresh loot!"],
	["Oh, finally I can get that chest after defeating those group of monsters.",
		"Finally — that chest, after that whole pack of monsters."],
	["*sigh of relief*", "You let out a deep sigh of relief and walk over to the chest."],
	["That one's mine.", "That one's mine."],
	["Let's see what you were hiding.", "Let's see what you were hiding."],
]
const BARK_CHANCE := 0.60
var _bark_room := -1

## SFX throttle: key -> last played time (msec). Idle mode fires many events;
## this keeps the pool from churning and the mix from turning to mush.
var _sfx_last := {}

## Throttled SFX helper. min_interval_ms = 0 means no throttle.
func _sfx(key: String, min_interval_ms := 0, pitch := 1.0) -> void:
	if min_interval_ms > 0:
		var now := Time.get_ticks_msec()
		var last: int = int(_sfx_last.get(key, -1000000))
		if now - last < min_interval_ms:
			return
		_sfx_last[key] = now
	AudioManager.play_sfx(key, pitch)

var _idle_timer := 0.0
var _idle_interval := 0.28
var _smoke := false
var _smoke_time := 0.0
var _smoke_deaths := 0
## Dev-only: play N seconds, save, print state, quit. Tests save/load
## across two processes: run once with --savequit=N, then boot normally
## and confirm the run resumes. Never player-facing.
var _savequit := 0.0
var _savequit_time := 0.0
var _smoke_logged := 0.0


func _ready() -> void:
	_ensure_input()
	_smoke = "--smoke" in OS.get_cmdline_args() or "--smoke" in OS.get_cmdline_user_args()
	if _smoke:
		rng.seed = 12345
		_idle_interval = 0.05
		GameState.idle_mode = true
	else:
		# Fixed seed for reproducing a beta run exactly: -- --seed=12345
		# (negative seeds work too — the log prints them for replay).
		var fixed := 0
		var have_fixed := false
		for a in OS.get_cmdline_user_args():
			if a.begins_with("--seed="):
				var n := a.trim_prefix("--seed=")
				if n.is_valid_int():
					fixed = int(n)
					have_fixed = true
		if have_fixed:
			rng.seed = fixed
		else:
			rng.randomize()
		print("RNG seed: %d (replay with -- --seed=%d)" % [rng.seed, rng.seed])
		# Dev cheat: player speed multiplier, e.g. -- --speed=2
		for a in OS.get_cmdline_user_args():
			if a.begins_with("--speed="):
				var n := a.trim_prefix("--speed=")
				if n.is_valid_float() and float(n) > 0.0:
					GameState.speed_mult = float(n)
					print("DEV CHEAT: player speed x%s" % n)
		# Dev-only save/load test: -- --savequit=20 plays 20s, saves, quits.
		for a in OS.get_cmdline_user_args():
			if a.begins_with("--savequit="):
				var n := a.trim_prefix("--savequit=")
				if n.is_valid_float() and float(n) > 0.0:
					_savequit = float(n)

	_build_environment()
	view = DungeonViewScript.new()
	add_child(view)
	player = PlayerScript.new()
	add_child(player)
	hud = HUDScript.new()
	add_child(hud)
	hud.restart_requested.connect(request_restart)
	hud.drink_requested.connect(_on_drink_requested)
	hud.shop_closed.connect(_on_shop_closed)
	hud.life_tree_requested.connect(_toggle_life_tree)
	touch_controls = TouchControlsScript.new()
	add_child(touch_controls)
	# D-pad feeds the same action pipeline as the keyboard.
	touch_controls.pad_action.connect(_handle_action)
	# Life Tree crown view (v0.11.0): hidden until the HUD button opens it.
	life_tree_view = LifeTreeViewScript.new()
	add_child(life_tree_view)
	# v0.12.0 fix 1: while the laurel view is open the HUD hides so
	# nothing stacks under it; closing the tree restores the HUD.
	life_tree_view.opened.connect(func() -> void: hud.visible = false)
	life_tree_view.closed.connect(func() -> void: hud.visible = true)
	# Display/dev settings (quality, hidden cheat speed).
	Settings.load_all()
	Settings.apply_quality(get_viewport())
	GameState.speed_mult = Settings.cheat_speed
	# App backgrounded (Android) / window focus lost: save immediately.
	get_tree().root.focus_exited.connect(_on_app_backgrounded)

	# Resume a saved run if there is one; otherwise start fresh.
	# A save from a dead run restores the meta progression, then the
	# run counter ticks over — the dead run stays dead.
	# Phase 3: a hub save (town/overworld) carries no live floor — the
	# boot path routes to the saved mode instead of the dungeon.
	var had_save := FileAccess.file_exists(SAVE_PATH)
	if load_game():
		_apply_saved_mode()
		if GameState.mode == GameMode.State.DUNGEON:
			print("RESTORED: depth=%d kills=%d level=%d hp=%.0f gold=%.0f pos=%s foes=%d" % [
				GameState.depth, GameState.run_kills, GameState.level,
				GameState.hp, GameState.gold, str(player.grid_pos), enemies.size()])
		else:
			print("RESTORED: mode=%s run=%d gold=%.0f level=%d (hub save, no live floor)" % [
				GameMode.state_name(GameState.mode), GameState.run_number,
				GameState.gold, GameState.level])
	else:
		if had_save and not GameState.alive:
			GameState.run_number += 1
		# Fresh boot default: straight into the dungeon, as always.
		GameState.set_mode(GameMode.State.DUNGEON)
		new_run()
		# Floor-1 onboarding: paused popups, once ever. Skipped in tests
		# (scene harnesses boot main.tscn without it being the current
		# scene — the paused tree would freeze the harness) and in _smoke.
		var is_main_scene := get_tree().current_scene != null \
			and str(get_tree().current_scene.scene_file_path).ends_with("scenes/main.tscn")
		if not had_save and not _smoke and is_main_scene and not GameState.tutorial_done:
			_show_tutorial()
	if _smoke:
		GameState.idle_mode = true
		hud.refresh()
		print("SMOKE: started (seed 12345, idle ON)")


# ------------------------------------------------------------------ setup ---

func _ensure_input() -> void:
	for action in FALLBACK_INPUT:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
		for key in FALLBACK_INPUT[action]:
			var exists := false
			for ev in InputMap.action_get_events(action):
				if ev is InputEventKey and ev.physical_keycode == key:
					exists = true
					break
			if not exists:
				var ev := InputEventKey.new()
				ev.physical_keycode = key
				InputMap.action_add_event(action, ev)


func _build_environment() -> void:
	var we := WorldEnvironment.new()
	var e := Environment.new()
	e.background_mode = Environment.BG_COLOR
	e.background_color = Color(0.008, 0.008, 0.02)
	e.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	e.ambient_light_color = Color(0.38, 0.42, 0.55)
	e.ambient_light_energy = 0.75
	e.fog_enabled = true
	e.fog_mode = Environment.FOG_MODE_EXPONENTIAL
	e.fog_density = 0.02
	e.fog_light_color = Color(0.02, 0.02, 0.05)
	we.environment = e
	add_child(we)


func new_run() -> void:
	GameState.reset_run()
	hud.hide_death()
	_new_depth()
	GameState.add_log("Run #%d begins — auto-delving engaged. Toggle Idle OFF to take control." % GameState.run_number)


## Floor-1 onboarding: pause the game over popup tutorial cards.
func _show_tutorial() -> void:
	hud.tutorial_finished.connect(_on_tutorial_finished)
	hud.show_tutorial()
	get_tree().paused = true


func _on_tutorial_finished() -> void:
	get_tree().paused = false
	GameState.tutorial_done = true
	save_game()


## Dungeon size grows with depth: 40x40 on depth 1 (onboarding), +4 per
## depth, capped at 120x120 so saves and the room-sweep brain stay sane.
## debug_fixed_map overrides (test hook: 0 = depth scaling).
func _floor_map_size() -> int:
	if debug_fixed_map > 0:
		return debug_fixed_map
	return mini(40 + 4 * (GameState.depth - 1), 120)


func _new_depth() -> void:
	# Clear old floor.
	for en in enemies:
		if is_instance_valid(en):
			en.queue_free()
	enemies.clear()
	_floor_traps.clear()
	_player_dazzle_timer = 0.0
	_player_root_timer = 0.0
	explored.clear()
	# Fresh floor, fresh plan: the room-by-room brain starts over.
	_brain_room = -1
	_bark_room = -1
	_stairs_marked = false
	_critical_retreat = false
	_room_cooldown.clear()

	var map_size := _floor_map_size()
	# DEV one-shot (hidden dev corner button): force THIS floor to be a
	# monster floor via the generator's existing force flag, then clear
	# the flag — it fires exactly once and is never persisted.
	var force_horde := debug_force_monster_floor or GameState.dev_force_next_monster_floor
	gen = DungeonGenScript.generate(map_size, map_size, GameState.depth, rng, force_horde)
	GameState.dev_force_next_monster_floor = false
	view.build_floor(gen)
	var start: Vector2i = gen["player_start"]
	# Face the first open neighboring cell so we never spawn staring at a wall.
	var spawn_face := 0
	for i in DIRS.size():
		if cell_at(start + DIRS[i]) != DungeonGenScript.WALL:
			spawn_face = i
			break
	player.place_at(start, spawn_face)
	_reveal_around(player.grid_pos)

	# Loot + chests + doors for this floor (deep copies — gen is discarded).
	loot = (gen["loot"] as Array).duplicate(true)
	chests = (gen["chests"] as Array).duplicate(true)
	doors = (gen["doors"] as Array).duplicate(true)
	floor_rooms = (gen["rooms"] as Array).duplicate()
	_stairs_room = _room_of(gen["stairs"])
	view.build_loot(loot, chests)
	view.build_doors(doors)

	# The dungeon hungers, but only up to a point: the per-death ramp caps at
	# +50% so a bad streak can never spiral into an unbeatable game. +2%/run
	# normally, +5%/run in Hardcore (very-hidden opt-in). Death should cost
	# the run, never future power — the comeback comes from dungeon gear and
	# the death shop, not from out-scaling a runaway ramp.
	var hunger_mult := GameState.hunger_mult()
	var hp_mult := pow(float(GameState.depth), 1.2) * hunger_mult
	var atk_mult := pow(float(GameState.depth), 1.05) * hunger_mult
	_hp_mult = hp_mult
	_atk_mult = atk_mult
	# Monster floor: the horde overwhelms through numbers, not one-shot
	# power — soften individual attack so the floor stays survivable.
	var monster_floor := bool(gen.get("monster_floor", false))
	if monster_floor:
		atk_mult *= 0.6
		_atk_mult = atk_mult
	for e in gen["enemies"]:
		_spawn_enemy(e["type"], e["pos"], bool(e.get("asleep", false)))

	if monster_floor:
		GameState.add_log("The air grows thick… MONSTER FLOOR! They come in waves!")
	else:
		GameState.add_log("Depth %d — %d hostiles detected." % [GameState.depth, enemies.size()])
	# Rooms that start empty never had a ward to hold them — break those seals
	# now, or their chests would sit unopenable forever.
	for i in floor_rooms.size():
		_break_seals(i, true)
	_refresh_minimap()
	_update_music()
	_check_founder_encounter()


## Founder encounters (v0.11.0): the Life Tree wakes on completing
## depth 1 (entering depth 2+), and each founder's gift roots on meeting.
## Catch-up: founders at or above the entered depth root in depth order.
## In normal play depths are visited sequentially, so this behaves as an
## exact-depth meeting; it also heals old saves that passed a founder
## depth before v0.11.0. Pello's deed dialog reappears on later floors
## until signed — dismissing it only postpones it.
func _check_founder_encounter() -> void:
	if GameState.depth < 2:
		return
	LifeTree.unlock()
	for fid in FoundersScript.all_ids():
		var f := FoundersScript.founder_by_id(fid)
		if GameState.depth >= int(f["depth"]) and not LifeTree.is_met(fid):
			LifeTree.meet_founder(fid)
	if LifeTree.is_met("pello") and not LifeTree.town_deed_signed:
		_show_deed_dialog()


## Pello's deed scene (v0.11.0, start slice): a simple dialog + unlock
## flag. Non-pausing — the delve continues behind it until signed or
## dismissed. Signing unlocks the town (see town_view deed status).
func _show_deed_dialog() -> void:
	if is_instance_valid(_deed_dialog):
		return
	var layer := CanvasLayer.new()
	layer.layer = 10
	add_child(layer)
	_deed_dialog = layer
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(center)
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(520, 300)
	center.add_child(panel)
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 12)
	panel.add_child(vbox)
	var title := Label.new()
	title.text = "Pello Quin offers you a deed"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 22)
	vbox.add_child(title)
	var body := Label.new()
	body.text = "Word of your delves has spread, and Pello the trader\n" \
		+ "has a proposition: an old tavern, a deed, and a town\n" \
		+ "waiting to be rebuilt. Sign, and the town is yours."
	body.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	body.add_theme_font_size_override("font_size", 16)
	vbox.add_child(body)
	var sign := Button.new()
	sign.text = "Sign the deed"
	sign.custom_minimum_size = Vector2(220, 52)
	sign.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	sign.pressed.connect(func() -> void:
		LifeTree.sign_deed()
		_deed_dialog.queue_free()
		_deed_dialog = null)
	vbox.add_child(sign)
	var later := Button.new()
	later.text = "Not yet"
	later.custom_minimum_size = Vector2(220, 52)
	later.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	later.pressed.connect(func() -> void:
		_deed_dialog.queue_free()
		_deed_dialog = null)
	vbox.add_child(later)


## HUD Life Tree button: toggle the laurel crown view.
func _toggle_life_tree() -> void:
	if life_tree_view == null:
		return
	if life_tree_view.is_open():
		life_tree_view.hide_tree()
	else:
		life_tree_view.show_crown()


## Music director: boss floors get the boss theme, deep floors (5+) the dark
## theme, everything else the main dungeon theme. play_music is a no-op when
## the track is already playing, so descends never restart the music.
func _update_music() -> void:
	if not GameState.alive:
		return
	if bool(gen.get("monster_floor", false)):
		AudioManager.play_music("theme_boss")
	elif GameState.depth >= 5:
		AudioManager.play_music("theme_deep")
	else:
		AudioManager.play_music("theme_dungeon")


## Fog of war: mark every cell within radius 4 (Chebyshev) of the player
## as explored. The minimap lights this radius; explored-but-unseen is dim.
func _reveal_around(gp: Vector2i) -> void:
	var width: int = gen["width"]
	var height: int = gen["height"]
	# Perception skill widens the fog-of-war reveal radius (base 4).
	var r := int(round(4.0 * GameState.sight_mult()))
	for dy in range(-r, r + 1):
		for dx in range(-r, r + 1):
			var p := gp + Vector2i(dx, dy)
			if p.x < 0 or p.y < 0 or p.x >= width or p.y >= height:
				continue
			explored[p] = true


# ------------------------------------------------------------------- input ---

## Every player action, no matter the source: keyboard, touch D-pad, HUD.
const MANUAL_ACTIONS: Array[StringName] = [
	&"toggle_idle", &"drink_potion",
	&"move_forward", &"move_back", &"strafe_left", &"strafe_right",
	&"turn_left", &"turn_right", &"restart_run",
]


func _unhandled_input(event: InputEvent) -> void:
	# Phase 3: dungeon keys do nothing in town/overworld — the hub views
	# bring their own UI.
	if GameState.mode != GameMode.State.DUNGEON:
		return
	# Keyboard feeds the same action pipeline as the touch D-pad.
	for action in MANUAL_ACTIONS:
		if event.is_action_pressed(action):
			_handle_action(action)
			return


## Single entry point for player actions — keyboard (_unhandled_input),
## touch D-pad (pad_action signal), HUD buttons.
## In manual mode the game is turn-based: every action grants each living
## monster exactly one turn (see _monster_turn), except quaffing a potion,
## which is a free action. Idle mode stays real-time.
func _handle_action(action: StringName) -> void:
	# Phase 3: the touch D-pad feeds this pipeline directly — belt and
	# suspenders with the _unhandled_input gate above.
	if GameState.mode != GameMode.State.DUNGEON:
		return
	if not GameState.alive:
		if action == &"restart_run":
			request_restart()
		return
	if GameState.idle_mode:
		# Idle owns movement; input can only toggle it off.
		if action == &"toggle_idle":
			GameState.idle_mode = false
			hud.refresh()
		return
	if player.busy:
		return
	match action:
		&"toggle_idle":
			GameState.idle_mode = true
			GameState.add_log("Idle mode ON — auto-explore engaged.")
			hud.refresh()
		&"drink_potion":
			if GameState.drink_health_potion():
				AudioManager.play_sfx("potion")
				hud.refresh()
				# Quaffing is a free action — the world stays frozen.
		&"move_forward":
			_try_step(DIRS[player.facing])
		&"move_back":
			_try_step(DIRS[(player.facing + 2) % 4])
		&"strafe_left":
			_try_step(DIRS[(player.facing + 3) % 4])
		&"strafe_right":
			_try_step(DIRS[(player.facing + 1) % 4])
		&"turn_left":
			player.turn(false, _on_manual_turn_done)
		&"turn_right":
			player.turn(true, _on_manual_turn_done)


## Turn tweens finish async — the world advances when the turn lands.
func _on_manual_turn_done() -> void:
	if GameState.alive and not GameState.idle_mode:
		_monster_turn()


## HUD potion button: same rules as the H key. Quaffing is always a free
## action — in idle mode it's a real-time top-up; in manual mode the world
## stays frozen.
func _on_drink_requested() -> void:
	if GameState.idle_mode:
		if GameState.drink_health_potion():
			AudioManager.play_sfx("potion")
			hud.refresh()
	else:
		_handle_action(&"drink_potion")


## In manual (turn-based) mode, every resolved player action advances the
## world exactly one turn. Idle mode runs real-time and skips this.
func _after_manual_step() -> void:
	if GameState.alive and not GameState.idle_mode:
		_monster_turn()


## Turn-based manual mode: the world only advances when the player acts.
## Each living monster takes exactly one turn, nearest-first: adjacent foes
## strike, others inside aggro range step one cell closer, and anything
## beyond aggro range stays dormant until approached.
## Wave 3: every monster turn first ticks its behavior with a TURN delta
## of 1.0s (one turn = one second of behavior time — so a 0.8s charge
## telegraph lasts one turn, a 5s grapple hold lasts five turns, and a
## 4s dazzle lasts four turns). The tick applies venom/grapple DoT,
## advances traps, resolves telegraphed specials, and places kobold
## traps; the strike/step below then uses the tick's intent. A monster
## that fired a telegraphed special this turn does NOT also strike.
## Ranged/bolt intents strike from their band (4-7 tiles); a cornered
## ranged foe (no step-back room) strikes instead of stepping.
func _monster_turn() -> void:
	if not GameState.alive or GameState.idle_mode:
		return
	var order: Array[Enemy] = []
	for e in enemies:
		if is_instance_valid(e) and not e.dead and not e.asleep:
			order.append(e)
	order.sort_custom(func(a: Enemy, b: Enemy) -> bool:
		return _manhattan(a.grid_pos, player.grid_pos) < _manhattan(b.grid_pos, player.grid_pos))
	for e in order:
		if not is_instance_valid(e) or e.dead:
			continue
		if not GameState.alive:
			break
		var tick := _tick_enemy_behavior(e, 1.0)
		if not GameState.alive:
			break
		if tick.get("special_fired", false):
			continue
		var dist := _manhattan(e.grid_pos, player.grid_pos)
		if dist == 1:
			_enemy_strike(e)
		elif e.behavior_attack_kind in ["arrow", "bolt"] and dist <= 7:
			_enemy_strike(e)
		elif e.behavior_action == "cornered":
			_enemy_strike(e)
		elif dist <= int(round(6.0 * GameState.aggro_mult())):
			_enemy_step_toward(e)
	_tick_floor_traps(1.0)
	if not GameState.alive:
		return
	_player_root_timer = maxf(0.0, _player_root_timer - 1.0)
	_player_dazzle_timer = maxf(0.0, _player_dazzle_timer - 1.0)
	_refresh_minimap()


# ------------------------------------------------- Wave 3 behavior wiring ---
## One behavior tick for one enemy, shared by the idle loop (real delta)
## and _monster_turn (delta 1.0). Returns {"special_fired": bool}.
## Order inside the tick matters and is fixed here:
##  1. update_behavior() with real context (player_pos, allies within
##     6 tiles, in_combat within aggro, step-back room, charge/dive
##     requests). Charger want_charge fires at 2-6 tiles; flyer
##     want_dive fires from hover within 3 tiles.
##  2. Grapple initiation: a grappler adjacent to the player starts a
##     grab (telegraph 0.5s, then hold). A telegraph->held transition
##     is the sidestep moment: a flat TELEGRAPH_SIDESTEP_CHANCE roll
##     breaks the grab before the hold lands (the windowed-dodge
##     decision — no new input, just the tell rewarding a sidestep).
##  3. Telegraphed specials with a main-side windup (the behavior
##     module tracks no caster/drake windup timer, so behavior_state's
##     otherwise-unused windup_timer carries it): banshee wail
##     (CASTER_WINDUP 1.2s, then AoE scream with falloff) and drake
##     inhale (BREATH_WINDUP 0.8s, then breath-cone damage). Both get
##     the same sidestep roll at resolution, and both set the behavior
##     cooldown (3.0s) so they cannot chain every tick. Firing a
##     special sets special_fired — the caller skips the normal strike.
##  4. Kobold trap placement: a trapper at 2-7 tiles drops a trap on
##     its own cell as it flees (the lure: the player chases through
##     it). Cooldown (8s) and the 3-live cap live in Behaviors.
##  5. DoT: behavior_venom_damage + behavior_grapple_damage are dealt
##     to the player through damage_player() (the single choke point —
##     Agility dodge and defense skill apply, exactly as for strikes).
##  6. This enemy's live traps advance against the player's cell;
##     a trigger deals its damage and roots the player 2s.
## What this does NOT do: move the enemy (the caller's step logic
## reads behavior_move_dir), touch drops, or double-lift flyer visuals
## — behavior_altitude is a combat-reach number only; flyers already
## hover visually via registry y_offset / procedural hover, and adding
## 1.5m on top would double-lift them.
func _tick_enemy_behavior(e: Enemy, delta: float) -> Dictionary:
	var out := {"special_fired": false}
	if not is_instance_valid(e) or e.dead or e.asleep:
		return out
	var dist := _manhattan(e.grid_pos, player.grid_pos)
	var canon := Behaviors.canonical_archetype(
		str(e.behavior_state.archetype).split("/")[0]) \
		if e.behavior_state != null else "brawler"
	var ctx := {
		"player_pos": Vector2(float(player.grid_pos.x), float(player.grid_pos.y)),
		"allies": _count_allies_near(e, 6),
		"in_combat": dist <= 6,
		"can_step_back": _can_step_back(e),
	}
	if canon == "charger" and dist >= 2 and dist <= 6:
		ctx["want_charge"] = true
	if e.behavior_state != null and e.behavior_state.flight_phase == "hover" \
			and dist <= 3 and bool(Behaviors.profile_for(
				e.behavior_state.archetype).get("flies", false)):
		ctx["want_dive"] = true
	var prev_grapple := "" if e.behavior_state == null \
		else str(e.behavior_state.grapple_phase)
	e.update_behavior(delta, ctx)
	# Grapple initiation + sidestep on the telegraph->held transition.
	if canon == "grappler" and e.behavior_state != null \
			and e.behavior_state.grapple_phase == "none" and dist == 1:
		Behaviors.try_grab(e.behavior_state, 1.0)
	if prev_grapple == "telegraph" and e.behavior_state != null \
			and e.behavior_state.grapple_phase == "held":
		if rng.randf() < TELEGRAPH_SIDESTEP_CHANCE:
			Behaviors.break_grapple(e.behavior_state, "sidestep")
			e.behavior_grapple_phase = "recover"
			e.behavior_telegraph = ""
			e.player_grappled = false
			e.player_can_move = true
			e.player_attack_mult = 1.0
			e._refresh_behavior_hints()
			_spawn_popup(player.position + Vector3(0, 2.0, 0),
				"Sidestepped the grab!", Color(0.6, 1.0, 0.6))
			GameState.add_log("Sidestepped the grab!")
	# Telegraphed specials (banshee wail / drake breath).
	if _resolve_telegraphed_special(e, delta, dist):
		out["special_fired"] = true
	# Kobold trap placement (trapper first half, fleeing at 2-7 tiles).
	if canon == "trapper" and dist >= 2 and dist <= 7:
		if e.place_behavior_trap(Vector2(float(e.grid_pos.x), float(e.grid_pos.y))):
			GameState.add_log("%s sets a trap…" % e.display_name)
	# DoT to the player.
	var dot := e.behavior_venom_damage + e.behavior_grapple_damage
	if dot > 0.0:
		_apply_behavior_damage(e, dot)
		if not GameState.alive:
			return out
	# This enemy's traps vs the player's cell.
	for res in e.update_behavior_traps(delta, Vector2(
			float(player.grid_pos.x), float(player.grid_pos.y))):
		_trigger_trap_damage(e, float(res.get("damage", 0.0)),
			float(res.get("root_time", 0.0)))
		if not GameState.alive:
			return out
	return out


## Banshee wail + drake breath resolution. Returns true if a special
## fired this tick (caller skips the normal strike). Windup lives on
## behavior_state.windup_timer (unused by Behaviors.update); the
## behavior cooldown gates re-firing. Sidestep roll at resolution.
func _resolve_telegraphed_special(e: Enemy, delta: float, dist: int) -> bool:
	if e.behavior_state == null:
		return false
	var st := e.behavior_state
	# Banshee (the only caster in the roster): wail windup -> AoE scream.
	if e.type_id == "banshee" and e.behavior_telegraph == "wail_windup" \
			and dist <= 7:
		if st.windup_timer <= 0.0:
			st.windup_timer = Behaviors.CASTER_WINDUP
			return false
		st.windup_timer -= delta
		if st.windup_timer > 0.0:
			return false
		st.windup_timer = 0.0
		st.attack_cooldown_timer = Behaviors.CASTER_COOLDOWN
		if rng.randf() < TELEGRAPH_SIDESTEP_CHANCE:
			_spawn_popup(player.position + Vector3(0, 2.0, 0),
				"Sidestepped the wail!", Color(0.6, 1.0, 0.6))
			GameState.add_log("Sidestepped the banshee's wail!")
			return true
		var res := CombatScript.calc_damage(e.atk, GameState.eff_def(), rng)
		var amount := Behaviors.aoe_damage_at(float(dist),
			Behaviors.SCREAM_RADIUS, float(res["amount"]))
		_spawn_popup(player.position + Vector3(0, 2.0, 0),
			"WAIL! " + BigNumbers.format(amount), Color(0.8, 0.6, 1.0))
		GameState.add_log("The banshee wails!")
		_apply_behavior_damage(e, amount)
		return true
	# Drake: inhale windup -> breath cone, only when the cone would hit.
	if e.type_id == "drake" and dist <= int(Behaviors.BREATH_RANGE) \
			and st.attack_cooldown_timer <= 0.0:
		var origin := Vector2(float(e.grid_pos.x), float(e.grid_pos.y))
		var facing := Vector2(float(e.facing.x), float(e.facing.y))
		var target := Vector2(float(player.grid_pos.x), float(player.grid_pos.y))
		if not Behaviors.breath_cone_hit(origin, facing, target):
			return false
		if st.windup_timer <= 0.0:
			st.windup_timer = Behaviors.BREATH_WINDUP_TIME
			e.behavior_telegraph = "inhale"
			e._refresh_behavior_hints()
			GameState.add_log("The drake inhales…")
			return false
		st.windup_timer -= delta
		e.behavior_telegraph = "inhale"
		e._refresh_behavior_hints()
		if st.windup_timer > 0.0:
			return false
		st.windup_timer = 0.0
		st.attack_cooldown_timer = Behaviors.CASTER_COOLDOWN
		e.behavior_telegraph = ""
		e._refresh_behavior_hints()
		if rng.randf() < TELEGRAPH_SIDESTEP_CHANCE:
			_spawn_popup(player.position + Vector3(0, 2.0, 0),
				"Sidestepped the breath!", Color(0.6, 1.0, 0.6))
			GameState.add_log("Sidestepped the drake's breath!")
			return true
		var res2 := CombatScript.calc_damage(e.atk, GameState.eff_def(), rng)
		_spawn_popup(player.position + Vector3(0, 2.0, 0),
			"BREATH! " + BigNumbers.format(float(res2["amount"])),
			Color(1.0, 0.55, 0.2))
		GameState.add_log("The drake breathes fire!")
		_apply_behavior_damage(e, float(res2["amount"]))
		return true
	return false


## Living, awake allies of `e` within `radius` tiles (Manhattan),
## excluding `e` itself. Feeds pack burst, swarm bonus, goblin courage.
func _count_allies_near(e: Enemy, radius: int) -> int:
	var n := 0
	for other in enemies:
		if not is_instance_valid(other) or other == e or other.dead or other.asleep:
			continue
		if _manhattan(other.grid_pos, e.grid_pos) <= radius:
			n += 1
	return n


## Step-back room for a ranged foe: the cell directly away from the
## player (dominant axis) must be enterable.
func _can_step_back(e: Enemy) -> bool:
	var away := e.grid_pos - player.grid_pos
	var step := Vector2i.ZERO
	if absi(away.x) >= absi(away.y) and away.x != 0:
		step = Vector2i(1 if away.x > 0 else -1, 0)
	elif away.y != 0:
		step = Vector2i(0, 1 if away.y > 0 else -1)
	else:
		return false
	return _enemy_can_enter(e, e.grid_pos + step)


## Shared enterability check for enemy steps (behavior-directed and
## greedy alike): floor (stairs count as floor, as before), not the
## player, no other living enemy, no unopened chest, no shut door.
func _enemy_can_enter(e: Enemy, cand: Vector2i) -> bool:
	if cell_at(cand) == DungeonGenScript.WALL:
		return false
	if cand == player.grid_pos:
		return false
	if enemy_at(cand) != null:
		return false
	var chd := chest_at(cand)
	if not chd.is_empty() and not bool(chd["opened"]):
		return false
	var dr := door_at(cand)
	if not dr.is_empty() and str(dr["state"]) != "open":
		return false
	return true


## Dominant-axis grid step from a behavior move_dir (Vector2).
func _behavior_step_dir(e: Enemy) -> Vector2i:
	var mv := e.behavior_move_dir
	if mv.length() < 0.1:
		return Vector2i.ZERO
	if absf(mv.x) >= absf(mv.y):
		return Vector2i(1 if mv.x > 0 else -1, 0)
	return Vector2i(0, 1 if mv.y > 0 else -1)


## True while any living enemy currently holds the player in a grapple.
## Reads behavior_state.grapple_phase directly — the enemy's cached
## fields go stale the moment a struggle/damage break lands, but the
## state is always current. An enemy node cannot block player movement
## by itself; main.gd consults this in _try_step()/_player_attack().
func _player_is_grappled() -> bool:
	for other in enemies:
		if is_instance_valid(other) and not other.dead \
				and other.behavior_state != null \
				and other.behavior_state.grapple_phase == "held":
			return true
	return false


## Windowed-dodge chance for a strike: the flat sidestep bonus while
## the attacker telegraphs, else 0. The roll itself lives in
## _enemy_strike(); this helper exists so tests can pin the chance
## without fighting the RNG.
func telegraph_sidstep_chance(e: Enemy) -> float:
	if e != null and e.in_telegraph_window():
		return TELEGRAPH_SIDESTEP_CHANCE
	return 0.0


## Behavior/DoT/trap/special damage to the player, through the single
## choke point (Agility dodge + defense skill inside damage_player).
func _apply_behavior_damage(e: Enemy, amount: float) -> void:
	if amount <= 0.0 or not GameState.alive:
		return
	if GameState.damage_player(amount):
		_on_player_death(e.display_name)


## A sprung trap: damage (already computed by the trap) + root timer.
func _trigger_trap_damage(e: Enemy, damage: float, root_time: float) -> void:
	_trigger_trap_damage_named(damage, root_time, e.display_name)


## Traps harvested from dead trappers, ticked against the player's cell.
## Uses a throwaway BehaviorState only to carry the trapper's ATK into
## Behaviors.update_trap() (its only use of the state) — the trap logic
## itself stays in behaviors.gd, not duplicated here.
func _tick_floor_traps(delta: float) -> void:
	if _floor_traps.is_empty():
		return
	var victim := Vector2(float(player.grid_pos.x), float(player.grid_pos.y))
	var kept: Array = []
	for entry in _floor_traps:
		var trap := entry.get("trap") as Behaviors.TrapState
		if trap == null or trap.triggered or trap.disarmed:
			continue
		var st := Behaviors.new_state("trapper", 1.0, float(entry.get("atk", 0.0)), 0.0)
		var res: Dictionary = Behaviors.update_trap(st, trap, delta, victim)
		if bool(res.get("triggered", false)):
			_trigger_trap_damage_named(float(res.get("damage", 0.0)),
				float(res.get("root_time", 0.0)))
			if not GameState.alive:
				return
			continue
		kept.append(entry)
	_floor_traps = kept


func _trigger_trap_damage_named(damage: float, root_time: float, killer: String = "a trap") -> void:
	if root_time > 0.0:
		_player_root_timer = maxf(_player_root_timer, root_time)
	_spawn_popup(player.position + Vector3(0, 2.0, 0),
		"Trap springs!", Color(1.0, 0.6, 0.2))
	GameState.add_log("A trap springs!")
	if damage > 0.0 and GameState.alive:
		if GameState.damage_player(damage):
			_on_player_death(killer)


## One struggle input against the grappler holding the player (the
## first holder found). Movement keys ARE the struggle while held —
## see _try_step(): no new input, no new action, no new subsystem.
## Returns true if this input broke the hold.
func _struggle_held() -> bool:
	for other in enemies:
		if not is_instance_valid(other) or other.dead \
				or other.behavior_state == null \
				or other.behavior_state.grapple_phase != "held":
			continue
		var broke := other.struggle_grapple()
		if broke:
			GameState.add_log("Broke free from the %s!" % other.display_name)
			_spawn_popup(player.position + Vector3(0, 2.0, 0),
				"Broke free!", Color(0.6, 1.0, 0.6))
		else:
			GameState.add_log("Struggling against the %s… (%d/5)" \
				% [other.display_name, other.behavior_state.struggle_points])
		return broke
	return false


# -------------------------------------------------------------------- loop ---

func _process(delta: float) -> void:
	if _smoke:
		_smoke_time += delta
		_smoke_logged += delta
		if _smoke_logged >= 5.0:
			_smoke_logged = 0.0
			print("SMOKE t=%.0fs depth=%d kills=%d level=%d hp=%s" % [
				_smoke_time, GameState.depth, GameState.run_kills,
				GameState.level, BigNumbers.format(GameState.hp)])
		if _smoke_time >= 30.0:
			print("SMOKE: timeout reached — depth=%d kills=%d level=%d gold=%s — QUIT OK"
				% [GameState.depth, GameState.run_kills, GameState.level, BigNumbers.format(GameState.gold)])
			get_tree().quit()
			return

	if _savequit > 0.0:
		_savequit_time += delta
		if _savequit_time >= _savequit:
			save_game()
			print("SAVEQUIT: saved at t=%.0f depth=%d kills=%d level=%d hp=%.0f gold=%.0f pos=%s foes=%d" % [
				_savequit_time, GameState.depth, GameState.run_kills,
				GameState.level, GameState.hp, GameState.gold,
				str(player.grid_pos), enemies.size()])
			get_tree().quit()
			return

	if not GameState.alive:
		return

	# Phase 3: the dungeon simulation only ticks in DUNGEON mode. In town
	# or on the overworld the run is parked — no brain, no regen, no ticks.
	if GameState.mode != GameMode.State.DUNGEON:
		return

	# Autosave: the run persists every 30s so a background kill or crash
	# never costs more than half a minute of progress.
	_autosave_timer += delta
	if _autosave_timer >= AUTOSAVE_INTERVAL:
		_autosave_timer = 0.0
		save_game()

	# Stride backstop: settle a finished stride every frame. The brain
	# gates on `player.busy`, and _settle_stride otherwise only runs from
	# move_step/turn — so a stride whose tween callback is lost would gate
	# the brain forever, with nothing left to call the settle. (Depth-12
	# stall, Nov 8: a live step tween never finished; busy stayed true.)
	if is_instance_valid(player):
		player._settle_stride()

	# Floor-clear shop open: the world holds its breath while you shop.
	if _shop_open:
		return

	# Regeneration skill + Troll Salve charm: passive HP trickle.
	var regen := GameState.regen_rate()
	if regen > 0.0 and GameState.hp < GameState.max_hp:
		GameState.hp = minf(GameState.max_hp, GameState.hp + regen * delta)

	# Idle auto-explore. Player speed scales the brain's action rate;
	# Dungeoneering skill makes the idle brain itself faster.
	# The timer runs even mid-stride so the next tick fires the moment the
	# current stride lands — steps chain at constant velocity instead of
	# pausing a full beat between cells.
	if GameState.idle_mode:
		_idle_timer += delta
		var interval: float = _idle_interval / maxf(GameState.speed_mult, 0.01) \
			/ GameState.delve_speed_mult() / GameState.depth_walk_mult() / GameState.delve_pace_mult()
		if _idle_timer >= interval and not player.busy:
			_idle_timer = 0.0
			_auto_step()

	# Enemy ticks — idle mode only. Manual mode is turn-based: the world
	# freezes until the player acts (see _monster_turn()).
	# Wave 3: every idle tick first runs the behavior tick (real delta,
	# real player_pos/allies/in_combat), which applies venom/grapple
	# DoT, advances traps, resolves specials, and places kobold traps.
	# The strike/step below then uses that intent. A special fired this
	# tick suppresses the normal strike (no double damage).
	if GameState.idle_mode:
		_player_root_timer = maxf(0.0, _player_root_timer - delta)
		_player_dazzle_timer = maxf(0.0, _player_dazzle_timer - delta)
		_tick_floor_traps(delta)
		for enemy in enemies:
			if not is_instance_valid(enemy) or enemy.dead or enemy.asleep:
				continue
			if not GameState.alive:
				break
			var tick := _tick_enemy_behavior(enemy, delta)
			if not GameState.alive:
				break
			enemy.attack_cooldown -= delta
			enemy.wander_cooldown -= delta
			var dist := _manhattan(enemy.grid_pos, player.grid_pos)
			if tick.get("special_fired", false):
				enemy.attack_cooldown = 1.1 if not _smoke else 0.3
			elif dist == 1 and enemy.attack_cooldown <= 0.0:
				enemy.attack_cooldown = 1.1 if not _smoke else 0.3
				_enemy_strike(enemy)
			elif enemy.behavior_attack_kind in ["arrow", "bolt"] \
					and dist <= 7 and enemy.attack_cooldown <= 0.0:
				enemy.attack_cooldown = 1.1 if not _smoke else 0.3
				_enemy_strike(enemy)
			elif enemy.behavior_action == "cornered" \
					and enemy.attack_cooldown <= 0.0:
				enemy.attack_cooldown = 1.1 if not _smoke else 0.3
				_enemy_strike(enemy)
			# Stealth skill shrinks the detection radius (base 6).
			# Step rate scales with the behavior's move_speed_mult, so
			# skirmishers step faster and tanks slower (clamped so a
			# telegraph/stun speed of 0 never divides by zero — those
			# actions don't step at all, see _enemy_step_toward).
			elif dist > 1 and dist <= int(round(6.0 * GameState.aggro_mult())) and enemy.wander_cooldown <= 0.0:
				enemy.wander_cooldown = (0.9 if not _smoke else 0.2) \
					/ clampf(enemy.behavior_move_speed_mult, 0.5, 3.0)
				_enemy_step_toward(enemy)


func _manhattan(a: Vector2i, b: Vector2i) -> int:
	return absi(a.x - b.x) + absi(a.y - b.y)


# ---------------------------------------------------------------- movement ---

## Idle stride: each step glides for exactly one brain tick so consecutive
## steps chain at constant velocity (buttery, no stop-start). Manual mode
## keeps the classic snappy stride (turn-based — no chaining there).
func _stride_time() -> float:
	if GameState.idle_mode:
		return _idle_interval / maxf(GameState.speed_mult, 0.01) \
			/ GameState.delve_speed_mult() / GameState.depth_walk_mult() / GameState.delve_pace_mult()
	return -1.0


func cell_at(gp: Vector2i) -> int:
	var width: int = gen["width"]
	var height: int = gen["height"]
	if gp.x < 0 or gp.y < 0 or gp.x >= width or gp.y >= height:
		return DungeonGenScript.WALL
	return (gen["grid"][gp.y] as Array)[gp.x]


func enemy_at(gp: Vector2i) -> Enemy:
	for enemy in enemies:
		if is_instance_valid(enemy) and not enemy.dead and enemy.grid_pos == gp:
			return enemy
	return null


## Resolve one grid step: walls block, doors open/pick/bash on bump,
## sealed or locked chests refuse on bump, enemies get bump-attacked,
## stairs descend (once their room is clear), open floor moves (loot).
func _try_step(dir: Vector2i) -> void:
	# Wave 3 grapple/root gates (an enemy node cannot block movement by
	# itself — main.gd consults the grapple surface here). While held,
	# a movement key IS a struggle input: no new input, no new action
	# (see _struggle_held). A struggle counts as the turn's action, so
	# the turn advances in manual mode; a root just blocks the step.
	if _player_is_grappled():
		_struggle_held()
		_after_manual_step()
		return
	if _player_root_timer > 0.0:
		_spawn_popup(player.position + Vector3(0, 2.0, 0),
			"Rooted — can't move!", Color(1.0, 0.6, 0.2))
		GameState.add_log("Rooted by a trap — can't move!")
		_after_manual_step()
		return
	var target := player.grid_pos + dir
	var cell := cell_at(target)
	if cell == DungeonGenScript.WALL:
		return
	# Bump an unopened door: closed doors swing open, locked doors get
	# picked (Lockpicking skill) or bashed (loud — consequences).
	var dr := door_at(target)
	if not dr.is_empty() and str(dr["state"]) != "open":
		if not _bump_door(dr, dir):
			_after_manual_step()
		return
	# Bump an unopened chest: sealed wards and padlocks refuse first.
	var chd := chest_at(target)
	if not chd.is_empty() and not bool(chd["opened"]):
		_bump_chest(chd)
		_after_manual_step()
		return
	var foe := enemy_at(target)
	if foe != null:
		_player_attack(foe)
		_after_manual_step()
		return
	if cell == DungeonGenScript.STAIRS:
		# The exit is warded: no leaving until the stairs room is clear.
		# (Can't make the exit rush that easy.)
		if _hostiles_in_room(_stairs_room) > 0:
			_spawn_popup(player.position + Vector3(0, 2.0, 0),
				"The exit is barred — clear this room!", Color(1.0, 0.4, 0.4))
			GameState.add_log("A ward bars the exit — clear this room first.")
			_after_manual_step()
			return
		player.move_step(dir, _on_reached_stairs, _stride_time())
		return
	_step_onto(dir)


## Plain move onto an open cell: reveal, collect loot, advance the turn.
func _step_onto(dir: Vector2i) -> void:
	var l := loot_at(player.grid_pos + dir)
	player.move_step(dir, func() -> void:
		_reveal_around(player.grid_pos)
		_disturb_sleepers()
		if not l.is_empty() and not bool(l["taken"]):
			_collect_loot(l)
		_refresh_minimap()
		_after_manual_step()
	, _stride_time())


func _on_reached_stairs() -> void:
	# The ward bars the exit while hostiles remain in the stairs room — this
	# is checked at the moment of descent (not just at path time) because a
	# foe can wander in after the brain starts its final approach. If warded,
	# stay on the stairs; the next brain tick will hunt the intruder.
	if not _critical_retreat and _hostiles_in_room(_stairs_room) > 0:
		GameState.add_log("The stair ward flares — hostiles remain!")
		return
	# Soak telemetry: what did the sweep leave behind on this floor?
	# Retreat descends are escape moves — unfinished business is expected.
	if not _critical_retreat:
		debug_unfinished_at_descend += _unfinished_count()
		for e in enemies:
			if is_instance_valid(e) and not e.dead:
				debug_unfinished_foes += 1
		for ch in chests:
			if not bool(ch["opened"]):
				debug_unfinished_chests += 1
				if int(ch.get("tumblers", 0)) > 0:
					debug_unfinished_chests_locked += 1
		for l in loot:
			if not bool(l["taken"]):
				debug_unfinished_loot += 1
	else:
		debug_retreat_descends += 1
	GameState.next_depth()
	_new_depth()
	_open_floor_shop()


## Floor-clear shop (Brotato beat): every descended floor ends with a
## resupply — the shop beckons, one tap to close, the delve resumes.
func _open_floor_shop() -> void:
	if debug_no_shop or not GameState.alive:
		return
	_shop_open = true
	# Critical retreat: the shopkeeper patches you up — 50% max HP, but only
	# if you can afford it. Triage, not a full heal; never spends gold the
	# player doesn't have.
	if _critical_retreat:
		_critical_retreat = false
		if GameState.idle_mode:
			_buy_shop_heal(true)
	hud.show_shop("Floor cleared — resupply before you descend further.")


## HUD shop closed: the delve resumes.
func _on_shop_closed() -> void:
	_shop_open = false
	hud.refresh()


# --------------------------------------------- rooms, doors and locks ---

## Door dict at a grid cell, or {} if none.
func door_at(gp: Vector2i) -> Dictionary:
	for d in doors:
		if d["pos"] == gp:
			return d
	return {}


## Room index containing `p`, or -1 for corridors/void.
func _room_of(p: Vector2i) -> int:
	for i in floor_rooms.size():
		if (floor_rooms[i] as Rect2i).has_point(p):
			return i
	return -1


## Living hostiles inside a room. Sleepers count — they're alive, and
## their room's chests stay sealed until they die.
func _hostiles_in_room(room_idx: int) -> int:
	if room_idx < 0 or room_idx >= floor_rooms.size():
		return 0
	var room: Rect2i = floor_rooms[room_idx]
	var n := 0
	for e in enemies:
		if is_instance_valid(e) and not e.dead and room.has_point(e.grid_pos):
			n += 1
	return n


## Spawn one enemy with the current floor's stat multipliers.
func _spawn_enemy(type_id: String, pos: Vector2i, asleep: bool = false) -> Enemy:
	var enemy: Enemy = EnemyScript.new()
	enemy.setup(type_id, _hp_mult, _atk_mult, pos)
	enemy.asleep = asleep
	# Face the player at spawn (they've noticed you); travel updates it after.
	if player != null:
		var to_p: Vector2i = player.grid_pos - pos
		if absi(to_p.x) >= absi(to_p.y):
			enemy.facing = Vector2i(1 if to_p.x > 0 else -1, 0)
		elif to_p.y != 0:
			enemy.facing = Vector2i(0, 1 if to_p.y > 0 else -1)
	enemy.position = view.world_pos(pos)
	enemy.died.connect(_on_enemy_died_signal)
	add_child(enemy)
	enemies.append(enemy)
	return enemy


## A room cleared of hostiles breaks the seals on its chests. Quiet mode is
## for floor start (rooms that began empty) — no fanfare for those.
func _break_seals(room_idx: int, quiet: bool = false) -> void:
	if room_idx < 0 or _hostiles_in_room(room_idx) > 0:
		return
	var broke := false
	for ch in chests:
		if not bool(ch["opened"]) and bool(ch["sealed"]) \
				and int(ch["room_idx"]) == room_idx:
			ch["sealed"] = false
			debug_seals_broken += 1
			view.update_chest(ch)
			broke = true
	if broke and not quiet:
		GameState.add_log("A ward breaks — a chest clicks unlocked!")
		AudioManager.play_sfx("seal_break")
		_spawn_popup(player.position + Vector3(0, 2.2, 0),
			"A seal breaks!", Color(0.75, 0.55, 1.0))


## Bump a chest: wards refuse until the room is clear, padlocks get picked,
## then it opens. (The brain skips sealed chests — it kills first.)
func _bump_chest(chd: Dictionary) -> void:
	var to_chest: Vector2i = (chd["pos"] as Vector2i) - player.grid_pos
	if to_chest != Vector2i.ZERO:
		player.face_direction(to_chest)
	if bool(chd["sealed"]):
		_spawn_popup(player.position + Vector3(0, 2.1, 0),
			"Sealed — clear this room first.", Color(0.7, 0.5, 1.0))
		GameState.add_log("A ward seals the chest — clear the room of monsters.")
		return
	if int(chd.get("tumblers", 0)) > 0:
		var lp := GameState.skill_level("lockpicking")
		var tier := int(chd.get("lock_tier", 1))
		if lp >= tier:
			chd["tumblers"] = 0
			GameState.add_log("The lock clicks open effortlessly.")
		else:
			var left: int = maxi(0, int(chd["tumblers"]) - (1 + lp))
			chd["tumblers"] = left
			if left > 0:
				_spawn_popup(player.position + Vector3(0, 2.1, 0),
					"Click… (%d tumblers left)" % left, Color(1.0, 0.7, 0.5))
				GameState.add_log("You work the lock… %d tumblers left." % left)
				return
			GameState.add_log("The lock clicks open!")
		view.update_chest(chd)
	# PERCEPTION/TRAP HOOK: the "double check" before opening. The coming
	# traps & hidden enemies system (tangled vines, spiders, webs) plugs in
	# here — _perception_double_check will spot or spring them first.
	_perception_double_check(chd)
	AudioManager.play_sfx("chest")  # lid creak as the ward/lock gives way
	_open_chest(chd)


## Trap/perception hook point: called right before a chest opens.
## Currently a no-op — the traps system implements the double-check here.
func _perception_double_check(_chd: Dictionary) -> void:
	pass


## Bump a door. Returns true if the crawler stepped through (the step owns
## the turn); false if it was just a knock (the caller advances the turn).
func _bump_door(dr: Dictionary, dir: Vector2i) -> bool:
	if str(dr["state"]) == "closed":
		dr["state"] = "open"
		debug_doors_pushed += 1
		view.update_door(dr)
		GameState.add_log("You push the door open.")
		AudioManager.play_sfx("door")
		_step_onto(dir)
		return true
	# Locked: pick it quiet with Lockpicking, or bash it loud without.
	var lp := GameState.skill_level("lockpicking")
	var tier := int(dr.get("tier", 1))
	if tier > 0 and lp >= tier:
		dr["state"] = "open"
		dr["tumblers"] = 0
		debug_doors_picked += 1
		view.update_door(dr)
		GameState.add_log("The lock clicks open — silent as a whisper.")
		AudioManager.play_sfx("door")
		_step_onto(dir)
		return true
	if lp > 0:
		var left: int = maxi(0, int(dr.get("tumblers", 3)) - (1 + lp))
		dr["tumblers"] = left
		if left > 0:
			_spawn_popup(player.position + Vector3(0, 2.0, 0),
				"Click… (%d left)" % left, Color(1.0, 0.7, 0.5))
			return false
		dr["state"] = "open"
		debug_doors_picked += 1
		view.update_door(dr)
		GameState.add_log("The lock clicks open!")
		AudioManager.play_sfx("door")
		_step_onto(dir)
		return true
	# No Lockpicking: BASH. Fast — but loud, with consequences.
	var hp_left: int = int(dr.get("bash_hp", 3)) - 1
	dr["bash_hp"] = hp_left
	_spawn_popup(player.position + Vector3(0, 2.0, 0),
		"WHAM! (%d)" % maxi(hp_left, 0), Color(1.0, 0.5, 0.3))
	_sfx("hit_heavy", 200, 0.85)
	GameState.add_log("You slam the door! (%d)" % maxi(hp_left, 0))
	# 35%: the crash alerts the area — sleepers within 8 cells wake.
	if rng.randf() < 0.35:
		var woke := _alert_nearby(dr["pos"], 8)
		GameState.add_log("The crash echoes — things stir in the dark!")
		if woke > 0:
			_spawn_popup(player.position + Vector3(0, 2.3, 0),
				"%d sleeper(s) wake!" % woke, Color(1.0, 0.6, 0.3))
	# <10%: the noise draws a patrol — 1-3 extra monsters.
	if rng.randf() < 0.08:
		_bash_spawn(dr["pos"])
		GameState.add_log("The noise draws a patrol!")
	if hp_left <= 0:
		dr["state"] = "open"
		debug_doors_bashed += 1
		view.update_door(dr)
		GameState.add_log("The door splinters open!")
		_step_onto(dir)
		return true
	return false


## Wake every sleeper within `radius` of a cell. Returns how many woke.
func _alert_nearby(pos: Vector2i, radius: int) -> int:
	var woke := 0
	for e in enemies:
		if is_instance_valid(e) and not e.dead and e.asleep \
				and _manhattan(e.grid_pos, pos) <= radius:
			_wake(e)
			woke += 1
	return woke


## The <10% bash consequence: 1-3 extra monsters join the fray near the door.
func _bash_spawn(door_pos: Vector2i) -> void:
	debug_patrol_spawns += 1
	var n := rng.randi_range(1, 3)
	for i in n:
		if enemies.size() >= 80:
			break
		var p := _random_open_cell_near(door_pos, 6)
		if p == Vector2i(-999, -999):
			break
		var e := _spawn_enemy(
			DungeonGenScript._pick_type(GameState.depth, rng,
				bool(gen.get("monster_floor", false))),
			p, false)
		GameState.add_log("A %s joins the fray!" % e.display_name)
	_refresh_minimap()


## Random open cell near `pos`: floor, unoccupied, not the player.
func _random_open_cell_near(pos: Vector2i, radius: int) -> Vector2i:
	for attempt in 24:
		var p := pos + Vector2i(rng.randi_range(-radius, radius),
			rng.randi_range(-radius, radius))
		if cell_at(p) == DungeonGenScript.WALL:
			continue
		if p == player.grid_pos:
			continue
		if enemy_at(p) != null:
			continue
		if not chest_at(p).is_empty():
			continue
		if not door_at(p).is_empty():
			continue
		if not loot_at(p).is_empty():
			continue
		return p
	return Vector2i(-999, -999)


## Wake one sleeper.
func _wake(e: Enemy) -> void:
	if not e.asleep:
		return
	e.wake_up()
	debug_sleepers_woken += 1
	GameState.add_log("%s stirs awake!" % e.display_name)


## After every player step: sleepers within 2 cells stir. Stealth gives a
## chance per level to slip by unnoticed (15%/level, cap 75%).
func _disturb_sleepers() -> void:
	var keep := minf(0.15 * float(GameState.skill_level("stealth")), 0.75)
	for e in enemies:
		if not is_instance_valid(e) or e.dead or not e.asleep:
			continue
		if _manhattan(e.grid_pos, player.grid_pos) <= 2:
			if rng.randf() < keep:
				continue
			_wake(e)


# -------------------------------------------------------------------- loot ---

## Chest dict at a grid cell, or {} if none.
func chest_at(gp: Vector2i) -> Dictionary:
	for ch in chests:
		if ch["pos"] == gp:
			return ch
	return {}


## Loot dict at a grid cell, or {} if none.
func loot_at(gp: Vector2i) -> Dictionary:
	for l in loot:
		if l["pos"] == gp:
			return l
	return {}


## Bump-to-open: face the chest, pop its contents (gear auto-equips if
## better, else auto-sells; potions go to inventory).
func _open_chest(chd: Dictionary) -> void:
	chd["opened"] = true
	GameState.chests_opened += 1
	var to_chest: Vector2i = (chd["pos"] as Vector2i) - player.grid_pos
	if to_chest != Vector2i.ZERO:
		player.face_direction(to_chest)  # smooth turn toward the prize
	view.mark_chest_opened(chd["pos"])
	debug_chests_opened += 1
	AudioManager.play_sfx("chest_open")
	# Both hands reach in — the player's window into what the brain just did.
	if is_instance_valid(player.fp_rig):
		player.fp_rig.play_chest_open()
	_spawn_popup(player.position + Vector3(0, 2.1, 0),
		"Chest opened!", Color(1.0, 0.85, 0.4))
	GameState.add_log("You pry open a chest…")
	# Locked chests earned it: +1 drop per 2 lock tiers, luckier rolls.
	var tier := int(chd.get("lock_tier", 0))
	var rolls := rng.randi_range(1, 2) + tier / 2
	var bonus := 0.05 * float(tier)
	for i in rolls:
		_roll_chest_drop(bonus)
	hud.refresh()
	_refresh_minimap()


func _roll_chest_drop(extra_luck: float = 0.0) -> void:
	var luck := GameState.rarity_luck() + extra_luck
	var r := rng.randf()
	if r < 0.40:
		_grant_gear(ItemsScript.make_weapon(GameState.depth, rng, luck))
	elif r < 0.65:
		_grant_gear(ItemsScript.make_armor(GameState.depth, rng, luck))
	elif r < 0.85:
		GameState.add_potion("health_potion")
		_spawn_popup(player.position + Vector3(0, 1.8, 0),
			"+1 HP potion", Color(1.0, 0.45, 0.45))
	else:
		GameState.add_potion("mana_potion")
		_spawn_popup(player.position + Vector3(0, 1.8, 0),
			"+1 MP potion", Color(0.45, 0.6, 1.0))


## Step onto a pickup to collect it.
func _collect_loot(l: Dictionary) -> void:
	if bool(l["taken"]):
		return
	l["taken"] = true
	GameState.loot_collected += 1
	view.remove_loot_at(l["pos"])
	match str(l["kind"]):
		"weapon":
			_grant_gear(ItemsScript.make_weapon(GameState.depth, rng, GameState.rarity_luck()))
		"armor":
			_grant_gear(ItemsScript.make_armor(GameState.depth, rng, GameState.rarity_luck()))
		"health_potion":
			GameState.add_potion("health_potion")
			_spawn_popup(player.position + Vector3(0, 1.8, 0),
				"+1 HP potion", Color(1.0, 0.45, 0.45))
		"mana_potion":
			GameState.add_potion("mana_potion")
			_spawn_popup(player.position + Vector3(0, 1.8, 0),
				"+1 MP potion", Color(0.45, 0.6, 1.0))
	hud.refresh()
	_refresh_minimap()


## Auto-equip if better than what's worn, else auto-sell for gold.
## (The player's job is gear — the crawler handles the rest.)
## Every find is logged to GameState.run_gear for the game-over sort screen.
func _grant_gear(item: Dictionary) -> void:
	var slot := str(item["slot"])
	GameState.run_gear.append(item)
	var cur: Dictionary = GameState.equipment.get(slot, {})
	var stat := "atk" if slot == "weapon" else "def"
	if ItemsScript.better(item, cur):
		var old_bonus := 0.0
		if not cur.is_empty():
			old_bonus = float(cur.get("max_hp", 0.0))
		GameState.equip(slot, item)
		GameState.gear_equipped += 1
		# Hands learn the new steel: animated grip swap on the FP rig.
		if slot == "weapon" and is_instance_valid(player.fp_rig):
			player.fp_rig.set_grip(_grip_for_weapon(item))
		var dhp := float(item.get("max_hp", 0.0)) - old_bonus
		if dhp != 0.0:
			GameState.max_hp += dhp
			GameState.hp = clampf(GameState.hp + maxf(dhp, 0.0), 0.0, GameState.max_hp)
			GameState.stats_changed.emit()
		_spawn_popup(player.position + Vector3(0, 2.0, 0),
			"Equipped %s (+%s %s)" % [str(item["name"]),
				BigNumbers.format(float(item.get(stat, 0.0))), stat.to_upper()],
			Color(0.55, 1.0, 0.6))
		GameState.add_log("Equipped %s." % str(item["name"]))
	else:
		var val := ItemsScript.sell_value(item)
		GameState.add_gold(val)
		_sfx("coin", 150, rng.randf_range(0.95, 1.08))
		_spawn_popup(player.position + Vector3(0, 2.0, 0),
			"Sold %s (+%s G)" % [str(item["name"]), BigNumbers.format(val)],
			Color(0.75, 0.75, 0.8))
		GameState.add_log("Sold %s for %s gold (weaker than current gear)."
			% [str(item["name"]), BigNumbers.format(val)])


## Push fresh world state to the HUD minimap.
func _refresh_minimap() -> void:
	if not is_instance_valid(hud) or gen.is_empty():
		return
	var enemy_cells: Array[Vector2i] = []
	for enemy in enemies:
		if is_instance_valid(enemy) and not enemy.dead:
			enemy_cells.append(enemy.grid_pos)
	hud.update_minimap(gen["grid"], int(gen["width"]), int(gen["height"]), explored,
		enemy_cells, chests, loot, player.grid_pos, player.facing, gen["stairs"],
		doors)


## Idle brain: room-by-room sweep (director's priority order, scoped per room).
##  0. quaff a health potion when hurting (below 30% HP); at <=25% HP fall
##     back to the stairs — the depth shop's patch-up is the backup plan.
##  1. bump adjacent foes, unopened doors, and unsealed chests (no dallying
##     on chests while retreating — survival first).
##  2. critical retreat: clear the stairs room, then descend to the shop.
##  3. sweep the current room (monsters -> chests/loot -> fog), then the next
##     nearest unfinished room; corridors get mopped up after the rooms.
##  4. stairs LAST — only when the floor is picked clean. The exit was
##     "mentally marked" the moment it was first seen; the sweep continues.
##  5. wander (paranoia fallback).
func _auto_step() -> void:
	GameState.brain_steps += 1
	# 0. Stay alive: auto-drink below 30% HP.
	if GameState.hp < GameState.max_hp * 0.30 and GameState.health_potions > 0:
		if GameState.drink_health_potion():
			_spawn_popup(player.position + Vector3(0, 2.2, 0),
				"Auto-potion!", Color(0.5, 1.0, 0.5))
	# Out of answers at <=25% HP: fall back to the depth shop's patch-up.
	if GameState.hp <= GameState.max_hp * CRITICAL_HP_FRAC and not _critical_retreat:
		_critical_retreat = true
		GameState.add_log("Critically wounded — falling back to the depth shop!")
		_spawn_popup(player.position + Vector3(0, 2.4, 0),
			"Retreat!", Color(1.0, 0.5, 0.3))
	# Mentally mark the exit the moment it's seen — descending still waits
	# for a clear floor (or a critical retreat).
	if not _stairs_marked and explored.has(gen["stairs"]):
		_stairs_marked = true
		GameState.add_log("Exit located — marked. Clearing the floor.")
	# 1. Adjacent threats first: sweep ALL four directions for foes before
	# touching anything else. (The old per-direction loop let a chest to the
	# north beat a foe to the east, and multi-tick lockpicking let the brain
	# fiddle while a foe hit it free.) Finish the fight first — always.
	for d in DIRS:
		var c := player.grid_pos + d
		var foe := enemy_at(c)
		if foe != null:
			debug_last_target = "attack"
			_player_attack(foe)
			_refresh_minimap()
			return
	# 1b. Doors next.
	for d in DIRS:
		var c := player.grid_pos + d
		var dr := door_at(c)
		if not dr.is_empty() and str(dr["state"]) != "open":
			debug_last_target = "door"
			_bump_door(dr, d)
			_refresh_minimap()
			return
	# 1c. Chests last — and never while critically retreating.
	if not _critical_retreat:
		for d in DIRS:
			var c := player.grid_pos + d
			var chd := chest_at(c)
			if not chd.is_empty() and not bool(chd["opened"]) \
					and not bool(chd["sealed"]):
				debug_last_target = "chest"
				_bump_chest(chd)
				return
	# 2. Critical retreat: fight through to the stairs room and descend.
	if _critical_retreat:
		if _retreat_step():
			return
		# Stairs unreachable — stand and fight instead of looping forever.
		_critical_retreat = false
		GameState.add_log("No way through — standing ground!")
	# 3. Room-by-room sweep.
	if _sweep_step():
		return
	# 3b. Corridor mop-up: explored chests/loot the rooms didn't cover
	# (loot spawns in corridors too — chests never do).
	var ltargets: Array[Vector2i] = []
	for ch in chests:
		if not bool(ch["opened"]) and not bool(ch["sealed"]) \
				and explored.has(ch["pos"]):
			ltargets.append(ch["pos"])
	for l in loot:
		if not bool(l["taken"]) and explored.has(l["pos"]):
			ltargets.append(l["pos"])
	var step := _bfs_first_step(ltargets)
	if step != Vector2i.ZERO:
		debug_last_target = "loot"
		_try_step(step)
		return
	# 3c. Corridor fog: drift toward the nearest unseen walkable cell so
	# stragglers hiding in dark corridors get found. Only while the floor
	# still has unfinished business (foes, chests, loot) — on a cleared
	# floor the fog is just fog, and sweeping it burns minutes before the
	# stairs for nothing. (Depth-9/12 stalls, Nov 8: the brain swept a big
	# empty floor until the watchdog fired, never descending.)
	if _unfinished_count() > 0:
		step = _bfs_first_step(_unseen_cells())
		if step != Vector2i.ZERO:
			debug_last_target = "sweep"
			_try_step(step)
			return
	# 4. Stairs last.
	var stairs: Vector2i = gen["stairs"]
	step = _bfs_first_step([stairs] as Array[Vector2i])
	if step != Vector2i.ZERO:
		debug_last_target = "stairs"
		_try_step(step)
		return
	# 5. Fully explored but stairs unreachable (paranoia): wander.
	debug_last_target = "wander"
	var options: Array[Vector2i] = []
	for d in DIRS:
		var c2 := player.grid_pos + d
		if cell_at(c2) != DungeonGenScript.WALL and enemy_at(c2) == null:
			var chd2 := chest_at(c2)
			if chd2.is_empty() or bool(chd2["opened"]):
				options.append(d)
	if not options.is_empty():
		_try_step(options[rng.randi_range(0, options.size() - 1)])


## One room-by-room sweep tick. Returns true if it acted (stepped).
func _sweep_step() -> bool:
	# Current room still has unfinished business: stay on it.
	if _brain_room >= 0 and not _room_has_work(_brain_room):
		_brain_room = -1
		_bark_room = -1
	if _brain_room < 0:
		_brain_room = _pick_room()
		if _brain_room < 0:
			return false
	var ri := _brain_room
	# Hunt the room's objective directly — BFS routes in from wherever the
	# player stands. (Pathing to the nearest room *edge* instead backtracks:
	# the edge behind you is nearer than the objective ahead, so the brain
	# ping-pongs forever. This was a real 6-minute stall.)
	var s2 := _bfs_first_step(_room_monster_cells(ri))
	if s2 != Vector2i.ZERO:
		debug_last_target = "monster"
		_try_step(s2)
		return true
	# No hostiles left: any lingering ward with nothing anchoring it breaks
	# now (paranoia self-heal — _break_seals is a no-op while foes remain).
	_break_seals(ri)
	# Then chests and loot.
	var s3 := _bfs_first_step(_room_good_cells(ri))
	if s3 != Vector2i.ZERO:
		# Monster -> loot transition: s2 was ZERO, so combat just ended.
		# Bark once per room's loot phase (never mid-fight).
		if _bark_room != ri:
			_bark_room = ri
			_maybe_bark_loot()
		debug_last_target = "loot"
		_try_step(s3)
		return true
	# Then sweep the room's fog — stragglers hide in dark corners.
	var s4 := _bfs_first_step(_room_unseen_cells(ri))
	if s4 != Vector2i.ZERO:
		debug_last_target = "sweep"
		_try_step(s4)
		return true
	# Nothing reachable in here: park it and move on (no ping-pong).
	_cooldown_room(ri)
	_brain_room = -1
	_bark_room = -1
	return false


## Fresh-loot bark: fires once per room's loot phase at BARK_CHANCE.
## Called only on the monster -> loot transition (combat already over),
## so barks never interrupt a fight.
func _maybe_bark_loot() -> void:
	if rng.randf() >= BARK_CHANCE:
		return
	var pair: Array = FRESH_LOOT_BARKS[rng.randi_range(0, FRESH_LOOT_BARKS.size() - 1)]
	_spawn_popup(player.position + Vector3(0, 2.2, 0), str(pair[0]), Color(1.0, 0.9, 0.5))
	GameState.add_log(str(pair[1]))


## Critical-HP fallback: push for the stairs room, clear it, descend to the
## depth shop. Returns false if the stairs can't be reached — the brain
## stands and fights instead of looping on an impossible path.
func _retreat_step() -> bool:
	var ri := _stairs_room
	var stairs: Vector2i = gen["stairs"]
	if ri < 0:
		var s := _bfs_first_step([stairs] as Array[Vector2i])
		if s == Vector2i.ZERO:
			return false
		debug_last_target = "retreat"
		_try_step(s)
		return true
	# Push straight at the stairs room's remaining hostiles (the ward bars
	# the exit while they live); when clear, take the stairs. BFS routes in
	# from wherever the player stands — no edge-pathing backtrack.
	var s3 := _bfs_first_step(_room_monster_cells(ri))
	if s3 != Vector2i.ZERO:
		debug_last_target = "retreat"
		_try_step(s3)
		return true
	var s4 := _bfs_first_step([stairs] as Array[Vector2i])
	if s4 == Vector2i.ZERO:
		return false
	debug_last_target = "retreat"
	_try_step(s4)
	return true


## Unfinished business in a room: living monsters, unopened chests
## (sealed ones count — their seals break as the room clears), unclaimed loot.
func _room_has_work(ri: int) -> bool:
	if ri < 0 or ri >= floor_rooms.size():
		return false
	var room: Rect2i = floor_rooms[ri]
	for e in enemies:
		if is_instance_valid(e) and not e.dead and room.has_point(e.grid_pos):
			return true
	for ch in chests:
		if not bool(ch["opened"]) and int(ch["room_idx"]) == ri:
			return true
	for l in loot:
		if not bool(l["taken"]) and room.has_point(l["pos"]):
			return true
	return false


## Nearest room (Manhattan to center) with unfinished business, skipping
## rooms parked on cooldown after unreachable targets.
func _pick_room() -> int:
	var now := Time.get_ticks_msec()
	var best := -1
	var best_d := 1 << 30
	var pc := player.grid_pos
	for i in floor_rooms.size():
		if int(_room_cooldown.get(i, 0)) > now:
			continue
		if not _room_has_work(i):
			continue
		var c: Vector2i = (floor_rooms[i] as Rect2i).get_center()
		var d := absi(c.x - pc.x) + absi(c.y - pc.y)
		if d < best_d:
			best_d = d
			best = i
	return best


## Park a room for 20s so the brain finishes the floor instead of
## ping-ponging on a target it can't reach.
func _cooldown_room(ri: int) -> void:
	_room_cooldown[ri] = Time.get_ticks_msec() + 20000


## Living-monster cells inside a room.
func _room_monster_cells(ri: int) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	var room: Rect2i = floor_rooms[ri]
	for e in enemies:
		if is_instance_valid(e) and not e.dead and room.has_point(e.grid_pos):
			out.append(e.grid_pos)
	return out


## Openable goods inside a room: unsealed unopened chests + unclaimed loot.
## Sealed chests are never targets — the brain kills first, seals break after.
func _room_good_cells(ri: int) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	for ch in chests:
		if not bool(ch["opened"]) and not bool(ch["sealed"]) \
				and int(ch["room_idx"]) == ri:
			out.append(ch["pos"])
	var room: Rect2i = floor_rooms[ri]
	for l in loot:
		if not bool(l["taken"]) and room.has_point(l["pos"]):
			out.append(l["pos"])
	return out


## Unseen walkable cells of a room — the fog sweep.
func _room_unseen_cells(ri: int) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	var room: Rect2i = floor_rooms[ri]
	for y in range(room.position.y, room.end.y):
		for x in range(room.position.x, room.end.x):
			var p := Vector2i(x, y)
			if cell_at(p) != DungeonGenScript.WALL and not explored.has(p):
				out.append(p)
	return out


## Every unseen walkable cell on the floor (corridor mop-up phase).
func _unseen_cells() -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	var width: int = gen["width"]
	var height: int = gen["height"]
	for y in height:
		for x in width:
			var p := Vector2i(x, y)
			var cell := cell_at(p)
			if cell != DungeonGenScript.WALL and cell != DungeonGenScript.STAIRS \
					and not explored.has(p):
				out.append(p)
	return out


## Unfinished business on the whole floor: living foes + unopened chests +
## unclaimed loot. Descend telemetry — what the sweep left behind.
func _unfinished_count() -> int:
	var n := 0
	for e in enemies:
		if is_instance_valid(e) and not e.dead:
			n += 1
	for ch in chests:
		if not bool(ch["opened"]):
			n += 1
	for l in loot:
		if not bool(l["taken"]):
			n += 1
	return n


## Buy the depth shop's field dressing: +50% max HP for gold. Returns true
## if the patch-up happened. Never spends gold the player doesn't have —
## the brain won't strand itself.
func _buy_shop_heal(auto: bool = false) -> bool:
	if not GameState.alive or GameState.hp >= GameState.max_hp:
		return false
	var price := ShopScript.field_heal_price(GameState.depth)
	if GameState.gold < price:
		if auto:
			GameState.add_log("Not enough gold for the shopkeeper's patch-up.")
		return false
	GameState.gold -= price
	GameState.hp = minf(GameState.max_hp,
		GameState.hp + GameState.max_hp * ShopScript.FIELD_HEAL_FRAC)
	debug_shop_heals += 1
	GameState.add_log("The shopkeeper patches you up (+%d%% HP, -%s G)."
		% [int(ShopScript.FIELD_HEAL_FRAC * 100.0), BigNumbers.format(price)])
	_spawn_popup(player.position + Vector3(0, 2.2, 0),
		"Patched up!", Color(0.5, 1.0, 0.6))
	hud.refresh()
	return true


## BFS from the player; returns the first-step direction toward the nearest
## cell in `targets`, or Vector2i.ZERO if unreachable. Targets themselves are
## walkable destinations; walls block the search. Enemies and unsealed chests
## do NOT block — the crawler bump-attacks / bump-opens them on the way
## through (_try_step), so a dormant foe or a chest sitting in a 1-wide
## corridor can never soft-lock the idle brain into wandering forever.
## Sealed chests DO block: bumping a ward is a no-op, so pathing through one
## would loop the brain on the same cell forever.
func _bfs_first_step(targets: Array[Vector2i]) -> Vector2i:
	if targets.is_empty():
		return Vector2i.ZERO
	var target_set := {}
	for t in targets:
		target_set[t] = true
	var start := player.grid_pos
	if target_set.has(start):
		return Vector2i.ZERO
	# The exit stairs are warded until their room is clear — stepping (or
	# pathing) onto them is refused, so they are solid to BFS while hostiles
	# remain. Otherwise the brain loops forever trying to walk through the
	# stairs toward a foe beyond them.
	var ward_active := _hostiles_in_room(_stairs_room) > 0
	# The stairs are also solid unless they are the explicit target: without
	# this the brain accidentally *descends* while pathing through the stairs
	# toward work beyond them, leaving the floor unfinished. (This caused
	# real descends with 16+ unseen cells and uncollected loot.)
	var stairs_targeted := target_set.has(gen["stairs"])
	var parent := {start: start}
	var queue: Array[Vector2i] = [start]
	while not queue.is_empty():
		var cur: Vector2i = queue.pop_front()
		for d in DIRS:
			var nxt := cur + d
			if parent.has(nxt):
				continue
			var cell := cell_at(nxt)
			if cell == DungeonGenScript.WALL:
				continue
			var chd := chest_at(nxt)
			if not chd.is_empty() and not bool(chd["opened"]) \
					and bool(chd.get("sealed", false)):
				continue
			if cell == DungeonGenScript.STAIRS and (ward_active or not stairs_targeted):
				continue
			parent[nxt] = cur
			if target_set.has(nxt):
				# Backtrack to the first step from start.
				var node := nxt
				while parent[node] != start:
					node = parent[node]
				return node - start
			queue.push_back(nxt)
	return Vector2i.ZERO


# ------------------------------------------------------------------ combat ---

## First-person rig grip for a weapon dict. Current loot (dagger/swords/
## blades) all read as "blade"; future crusher/piercer/fist names map to
## their heavier presets. Unknown/empty gear falls back to blade.
func _grip_for_weapon(w: Dictionary) -> String:
	var n := str(w.get("name", "")).to_lower()
	if "mace" in n or "hammer" in n or "crusher" in n or "maul" in n:
		return "crusher"
	if "spear" in n or "pike" in n or "staff" in n or "piercer" in n:
		return "piercer"
	if "fist" in n or "claw" in n or "knuckle" in n:
		return "fists"
	return "blade"


func _player_attack(enemy: Enemy) -> void:
	# Look at what you're hitting — keeps combat on-camera.
	var to_foe: Vector2i = enemy.grid_pos - player.grid_pos
	if to_foe != Vector2i.ZERO:
		var dir := Vector2i(0, -1)
		if absi(to_foe.x) >= absi(to_foe.y):
			dir = Vector2i(1 if to_foe.x > 0 else -1, 0)
		else:
			dir = Vector2i(0, 1 if to_foe.y > 0 else -1)
		player.face_direction(dir)
	# Wave 3 miss gates, before the swing (a whiff neither wakes a
	# sleeper nor spends the hit). Dazzle: the PLAYER-side store
	# (pixie flash) plus the enemy-side dazzle_miss_chance read for
	# completeness — a dazzled attacker misses outright. Reach: ground
	# melee cannot touch a flyer at altitude >= 0.5 (hovering bat,
	# harpy, imp, pixie, drake); dive to 0.2 and it becomes reachable.
	if _player_dazzle_timer > 0.0 and rng.randf() < TELEGRAPH_DAZZLE_MISS:
		_spawn_popup(player.position + Vector3(0, 2.0, 0),
			"Dazzled — swing misses!", Color(1.0, 0.85, 0.4))
		GameState.add_log("Dazzled — the swing goes wide!")
		return
	if enemy.behavior_dazzle_miss_chance > 0.0 \
			and rng.randf() < enemy.behavior_dazzle_miss_chance:
		_spawn_popup(player.position + Vector3(0, 2.0, 0),
			"Dazzled — swing misses!", Color(1.0, 0.85, 0.4))
		GameState.add_log("Dazzled — the swing goes wide!")
		return
	# Striking a sleeper wakes it — but the first hit is free (no retaliation).
	# The wake runs BEFORE the reach gate: a sleeping flyer hovers too high
	# to hit, and a whiff must not leave it asleep forever. An asleep flyer
	# never dives (its behavior tick is skipped while asleep), so reach-first
	# was a permanent soft-lock — the brain kept swinging at it and never
	# moved on. Woken, its tick runs, it dives to strike, and the next swing
	# connects.
	var was_asleep := enemy.asleep
	if was_asleep:
		_wake(enemy)
		GameState.add_log("You strike the sleeping %s!" % enemy.display_name)
	if not enemy.is_melee_reachable():
		_spawn_popup(player.position + Vector3(0, 2.0, 0),
			"Too high to reach!", Color(0.7, 0.85, 1.0))
		GameState.add_log("Too high to reach — wait for it to dive.")
		return
	# Bumping a hidden ambusher reveals it (the faint "?" hint was the
	# only warning; contact spends the ambush, no bonus either way).
	if enemy.behavior_state != null and enemy.behavior_state.hidden:
		enemy.reveal_ambush()
		GameState.add_log("You spot the ambusher!")
	var res: Dictionary = CombatScript.calc_damage(GameState.eff_atk(), enemy.def, rng)
	# Death-shop skills/charms: Attack, Strength, Hunter's Mark.
	var amount: float = float(res["amount"]) * GameState.dmg_dealt_mult()
	var crit: bool = res["crit"]
	# Backstab: the strike lands from behind the enemy's facing — or the foe
	# never saw it coming (asleep). atk_dir == facing means the player is in
	# the direction the enemy is walking away from: right in its blind spot.
	var atk_dir := Vector2i(signi(to_foe.x), signi(to_foe.y))
	var backstab := was_asleep \
		or (enemy.facing != Vector2i.ZERO and atk_dir == enemy.facing)
	if backstab:
		amount *= BACKSTAB_MULT
		GameState.add_log("Backstab!")
	# Grappled players attack at 0.5x (the grapple surface, consulted
	# here — the enemy node cannot enforce this by itself).
	if _player_is_grappled():
		amount *= Behaviors.GRAPPLE_HELD_ATTACK_MULT
	# The swing carries the hit: SFX/damage/popup land on the downswing via
	# the rig's impact callback, so the blade visibly connects first.
	var grip := _grip_for_weapon(GameState.equipment.get("weapon", {}))
	if is_instance_valid(player.fp_rig):
		player.fp_rig.play_swing(grip, _apply_player_hit.bind(enemy, amount, crit, was_asleep))
	else:
		_apply_player_hit(enemy, amount, crit, was_asleep)


## Impact half of _player_attack: runs on the swing's downswing.
func _apply_player_hit(enemy: Enemy, amount: float, crit: bool, was_asleep: bool) -> void:
	if not is_instance_valid(enemy):
		return
	# Drifting phase enemies (wraith) are hittable but take half damage
	# (Behaviors phase rule — the catalog never says untargetable).
	if enemy.behavior_state != null:
		amount *= Behaviors.phase_damage_taken_mult(enemy.behavior_state)
	_spawn_popup(enemy.position + Vector3(0, 1.4, 0),
		BigNumbers.format(amount), Color(1.0, 0.85, 0.3) if crit else Color(1, 1, 1))
	_sfx("hit_heavy" if crit else "hit", 80, rng.randf_range(0.94, 1.06))
	var killed: bool = enemy.take_damage(amount)
	if killed:
		# _on_enemy_died_signal handles rewards via the died signal.
		pass
	elif GameState.idle_mode and not was_asleep:
		_enemy_strike(enemy)
	# Manual mode: no instant retaliation — the foe strikes in _monster_turn().


func _on_enemy_died_signal(enemy: Enemy) -> void:
	# Wave 3: traps persist after the trapper dies — harvest live traps
	# onto the floor store before the node is freed.
	if enemy.behavior_state != null:
		for trap in enemy.behavior_state.traps:
			if not trap.triggered and not trap.disarmed:
				_floor_traps.append({"trap": trap, "atk": enemy.atk})
	GameState.add_kill()
	var xp_got := enemy.xp_reward * GameState.xp_mult()
	var gold_got := enemy.gold_reward * GameState.gold_mult()
	var lvl_before := GameState.level
	GameState.gain_xp(xp_got)
	if GameState.level > lvl_before:
		AudioManager.play_sfx("levelup")
	GameState.add_gold(gold_got)
	_sfx("coin", 150, rng.randf_range(0.95, 1.08))
	enemies.erase(enemy)
	_spawn_popup(enemy.position + Vector3(0, 1.9, 0),
		"+%s XP  +%s G" % [BigNumbers.format(xp_got), BigNumbers.format(gold_got)],
		Color(0.5, 1.0, 0.6))
	GameState.add_log("Slew %s (+%s XP, +%s gold)." % [
		enemy.display_name, BigNumbers.format(enemy.xp_reward), BigNumbers.format(enemy.gold_reward)])
	# Squash-and-vanish death animation.
	if is_instance_valid(enemy):
		var tw := enemy.create_tween()
		tw.tween_property(enemy, "scale", Vector3(0.01, 0.01, 0.01), 0.22)
		tw.tween_callback(enemy.queue_free)
	# Ward check: a cleared room breaks the seals on its chests.
	_break_seals(_room_of(enemy.grid_pos))
	_refresh_minimap()


## Wave 3 strike resolution: the behavior intent shapes the hit.
## - Hidden ambusher: revealed, first-strike 1.5x on THIS hit.
## - behavior_attack_kind selects the strike flavor; behavior_damage_mult
##   scales it (brute windup payoff 1.5x, pack burst 1.5x, swarm aggregate,
##   charge 1.2x, ambush 1.5x — the intent default is 1.0x).
## - "sting" applies venom (stacks tick through update_behavior, dealt
##   as DoT by the tick — the strike itself is still just the claw/sting hit).
## - Pixie strikes dazzle the PLAYER (player-side store, 4s, 50% miss).
## - Telegraph window: a flat sidestep roll (the dodge/block decision —
##   a passive windowed bonus, NOT a new input/action) before damage.
## - "scream"/"breath" kinds never land here: their windup owns the
##   damage in _resolve_telegraphed_special(); if a strike call arrives
##   mid-windup, the windup absorbs it (no double damage).
## - A held grappler never lands here either: hold DoT is its damage.
## - Sidestep resolves BEFORE sting/dazzle: a dodged blow applies neither.
## - Attack vocal: called here (the retaliation path has no tick) and
##   deduped against update_behavior's auto-vocal in enemy.gd.
func _enemy_strike(enemy: Enemy) -> void:
	if not GameState.alive or enemy.dead:
		return
	var kind := enemy.behavior_attack_kind
	if kind in ["scream", "breath"]:
		return
	# A grappler already holding the player deals its damage as hold
	# DoT in the tick — a normal strike on top would double-dip.
	if enemy.behavior_state != null \
			and enemy.behavior_state.grapple_phase == "held":
		return
	var mult := enemy.behavior_damage_mult
	if enemy.behavior_state != null and enemy.behavior_state.hidden:
		mult = maxf(mult, Behaviors.ambush_first_strike_mult(enemy.behavior_state))
		enemy.reveal_ambush()
		GameState.add_log("Ambushed by the %s!" % enemy.display_name)
	# Sidestep first: a dodged blow applies no sting venom and no dazzle.
	enemy.play_attack_vocal()
	if telegraph_sidstep_chance(enemy) > 0.0 \
			and rng.randf() < TELEGRAPH_SIDESTEP_CHANCE:
		_spawn_popup(player.position + Vector3(0, 1.7, 0),
			"Sidestepped!", Color(0.6, 1.0, 0.6))
		GameState.add_log("Sidestepped the telegraphed blow!")
		_set_behavior_strike_cooldown(enemy)
		return
	if kind == "sting":
		enemy.apply_venom()
	if enemy.type_id == "pixie":
		_player_dazzle_timer = Behaviors.DAZZLE_DURATION
		GameState.add_log("The pixie dazzles you!")
	var res: Dictionary = CombatScript.calc_damage(enemy.atk, GameState.eff_def(), rng)
	var amount: float = float(res["amount"]) * mult
	_spawn_popup(player.position + Vector3(0, 1.7, 0),
		BigNumbers.format(amount), Color(1.0, 0.35, 0.35))
	_sfx("hit", 80, 0.72)  # enemy hits land softer / lower
	_set_behavior_strike_cooldown(enemy)
	var died: bool = GameState.damage_player(amount)
	if died:
		_on_player_death(enemy.display_name)


## After a strike lands (or is sidestepped), the behavior cooldown
## gates the next telegraph: caster re-wail and charger re-charge both
## read attack_cooldown_timer. Other archetypes never read it, so this
## is a no-op for them. Specials set their own cooldown on firing.
func _set_behavior_strike_cooldown(enemy: Enemy) -> void:
	if enemy.behavior_state == null:
		return
	var prof := Behaviors.profile_for(enemy.behavior_state.archetype)
	enemy.behavior_state.attack_cooldown_timer = float(prof.get("attack_cooldown", 1.5))


## Wave 3 behavior-aware stepping. Rooted in place (never steps):
## telegraphing, stunned, recovering, holding a grapple, hidden
## (ambushers wait), or perched. Otherwise the behavior's move_dir
## picks the step (dominant axis): chargers run their charge line,
## skirmishers retreat, ranged foes step back, flyers dive toward the
## player. A behavior step blocked by a wall while charging reports
## the wall hit (next tick stuns the charger); a blocked retreat /
## step-back stays put (it does NOT fall through to the greedy step —
## retreating into the player would invert the mechanic). Advance
## intents with a blocked behavior step fall through to the old greedy
## closest-cell step. Manual mode still moves exactly one cell per
## turn regardless of move_speed_mult (speed scales the idle step
## RATE, not the per-turn distance — see the idle loop).
func _enemy_step_toward(enemy: Enemy) -> void:
	if enemy.behavior_action in ["telegraph", "stunned", "recover", "hold", "hidden", "climb", "perch"]:
		return
	if enemy.behavior_state != null \
			and enemy.behavior_state.grapple_phase in ["telegraph", "held"]:
		return
	var bdir := _behavior_step_dir(enemy)
	if bdir != Vector2i.ZERO:
		var cand := enemy.grid_pos + bdir
		if cand == player.grid_pos:
			return
		if _enemy_can_enter(enemy, cand):
			_step_enemy_to(enemy, cand)
			return
		# Blocked behavior step: charger wall impact stuns next tick.
		if enemy.behavior_charge_phase == "charging" \
				and cell_at(cand) == DungeonGenScript.WALL:
			enemy.report_wall_hit()
			return
		if enemy.behavior_action in ["retreat", "step_back", "climb"]:
			return
		# Advance intents fall through to the greedy step below.
	var best := enemy.grid_pos
	var best_dist := _manhattan(enemy.grid_pos, player.grid_pos)
	for d in DIRS:
		var cand := enemy.grid_pos + d
		if not _enemy_can_enter(enemy, cand):
			continue
		var dist := _manhattan(cand, player.grid_pos)
		if dist < best_dist:
			best_dist = dist
			best = cand
	if best != enemy.grid_pos:
		_step_enemy_to(enemy, best)


func _step_enemy_to(enemy: Enemy, cell: Vector2i) -> void:
	enemy.facing = cell - enemy.grid_pos
	enemy.grid_pos = cell
	var tw := enemy.create_tween()
	tw.tween_property(enemy, "position", view.world_pos(cell), 0.35)


func _on_player_death(killer_name: String) -> void:
	GameState.add_log("Slain by %s on depth %d…" % [killer_name, GameState.depth])
	if Settings.hardcore:
		# Hardcore: death forfeits ALL carried gold. The death shop still
		# opens (heirlooms are kept, skills can be browsed) but the purse
		# is empty — the save below persists the forfeiture.
		var lost := GameState.gold
		GameState.gold = 0.0
		GameState.run_gold = 0.0
		GameState.stats_changed.emit()
		GameState.add_log("HARDCORE — the dungeon claims your purse: %s gold lost."
			% BigNumbers.format(lost))
	# v0.12.0 fix 1: never leave the laurel view open over the death
	# screen — closing it restores the HUD before the panel shows.
	if life_tree_view != null and life_tree_view.is_open():
		life_tree_view.hide_tree()
	hud.show_death()
	AudioManager.stop_music()
	AudioManager.play_sfx("death")
	save_game()  # persist the meta progression; the run itself is over
	if _smoke:
		_smoke_deaths += 1
		if _smoke_deaths >= 2:
			print("SMOKE: 2 deaths done (restart path exercised) — depth=%d run=%d — QUIT OK"
				% [GameState.depth, GameState.run_number])
			get_tree().quit()
		else:
			print("SMOKE: death #%d — auto-restarting" % _smoke_deaths)
			await get_tree().create_timer(0.5).timeout
			request_restart()


# ------------------------------------------------- Phase 3 transitions ---
## The state machine (GameMode) owns the legal moves; these apply them.
## Town is the between-runs hub: dungeon -> town on run end, town ->
## dungeon on delve, town <-> overworld stub. No direct dungeon <->
## overworld, no mid-run town visits in this phase.

## Boot routing: honor the mode a save restored. Hub saves carry no live
## floor, so the dungeon roots stay parked until the next delve.
func _apply_saved_mode() -> void:
	match GameState.mode:
		GameMode.State.TOWN:
			enter_town()
		GameMode.State.OVERWORLD:
			enter_overworld()
		_:
			_show_dungeon()


## Run ended (or back from the overworld): park the dungeon, show town.
func enter_town() -> bool:
	if not GameState.set_mode(GameMode.State.TOWN):
		return false
	_clear_floor_entities()
	_set_dungeon_roots_visible(false)
	_free_hub_views()
	town_view = TownScript.new()
	add_child(town_view)
	town_view.delve_requested.connect(start_delve)
	town_view.overworld_requested.connect(enter_overworld)
	AudioManager.stop_music()
	save_game()  # persist the hub state; no live floor in town (Phase 3)
	return true


## Town -> overworld stub. The map-size decision is explicitly open:
## see OverworldView.OVERWORLD_MAP_SIZE (TODO_JAMES).
func enter_overworld() -> bool:
	if not GameState.set_mode(GameMode.State.OVERWORLD):
		return false
	_set_dungeon_roots_visible(false)
	_free_hub_views()
	overworld_view = OverworldScript.new()
	add_child(overworld_view)
	overworld_view.return_requested.connect(enter_town)
	AudioManager.stop_music()
	save_game()
	return true


## Town -> dungeon: generate a fresh floor and delve.
func start_delve() -> bool:
	if not GameState.set_mode(GameMode.State.DUNGEON):
		return false
	_free_hub_views()
	_show_dungeon()
	# Hands pick up whatever the heirlooms left us (no swap animation —
	# the delve is just starting).
	if is_instance_valid(player.fp_rig):
		player.fp_rig.sync_grip(_grip_for_weapon(GameState.equipment.get("weapon", {})))
	_new_depth()
	hud.refresh()
	GameState.add_log("You delve once more…")
	return true


func _show_dungeon() -> void:
	_set_dungeon_roots_visible(true)
	if is_instance_valid(player) and is_instance_valid(player.camera):
		player.camera.make_current()


func _free_hub_views() -> void:
	if is_instance_valid(town_view):
		town_view.queue_free()
	town_view = null
	if is_instance_valid(overworld_view):
		overworld_view.queue_free()
	overworld_view = null


## Park the dungeon roots while a hub view is up: hidden and unprocessed
## so the parked run costs nothing and takes no input.
func _set_dungeon_roots_visible(v: bool) -> void:
	for r in [view, player, hud, touch_controls]:
		if is_instance_valid(r):
			r.visible = v
			r.process_mode = Node.PROCESS_MODE_INHERIT if v \
				else Node.PROCESS_MODE_DISABLED


## Hub states carry no live floor in Phase 3: drop the dead run's
## entities so a hub save can never resurrect stale floor data.
func _clear_floor_entities() -> void:
	for en in enemies:
		if is_instance_valid(en):
			en.queue_free()
	enemies.clear()
	_floor_traps.clear()
	_player_dazzle_timer = 0.0
	_player_root_timer = 0.0
	loot.clear()
	chests.clear()
	doors.clear()
	explored.clear()
	floor_rooms.clear()
	gen = {}


func request_restart() -> void:
	if GameState.alive:
		return
	GameState.run_number += 1
	GameState.reset_run()
	hud.hide_death()
	# Phase 3: the dead run ends in town, not straight back down.
	# The next delve starts from the town's Delve button.
	enter_town()
	GameState.add_log("Run #%d mustered — delve from town when ready." % GameState.run_number)
	if _smoke:
		# Smoke exercises the restart path; keep auto-delving so the run
		# completes instead of idling in town.
		start_delve()


# ------------------------------------------------------------ save/load ---
## Save system: the game autosaves every AUTOSAVE_INTERVAL seconds and
## whenever the app loses focus (Android backgrounding). The meta
## progression (gold, skills, charms, heirlooms) is always saved; the live
## run + floor state is saved only while the player is alive. On boot the
## run resumes where it left off — no more lost progress when Android
## reclaims the app in the background.
const SAVE_PATH := "user://savegame.dat"
const SAVE_VERSION := 3
const AUTOSAVE_INTERVAL := 30.0
var _autosave_timer := 0.0


## Write the save file. Safe to call any time; no-op in smoke/test mode.
func save_game() -> void:
	if _smoke:
		return
	var d := {
		"version": SAVE_VERSION,
		"game_state": GameState.to_dict(),
		"prestige": Prestige.to_dict(),
		"life_tree": LifeTree.to_dict(),
	}
	# Offline earnings: wall-clock stamp on EVERY save.
	d["last_seen_unix"] = int(Time.get_unix_time_from_system())
	# Phase 3: hub states (town/overworld) carry no live floor — meta only.
	# The offline-earnings medians ride along only while a live delve is
	# actually in progress — a dead hero or a town hub earns nothing while
	# away.
	if GameState.alive and GameState.mode == GameMode.State.DUNGEON and is_inside_tree():
		d["delve_snapshot"] = GameState.offline_snapshot()
		d["rng_seed"] = rng.seed
		d["rng_state"] = rng.state
		d["gen"] = gen
		d["chests"] = chests
		d["doors"] = doors
		d["loot"] = loot
		d["explored"] = explored.keys()
		d["floor_rooms"] = floor_rooms
		d["stairs_room"] = _stairs_room
		d["hp_mult"] = _hp_mult
		d["atk_mult"] = _atk_mult
		d["shop_open"] = _shop_open
		d["player_pos"] = player.grid_pos
		d["player_facing"] = player.facing
		var foe_states: Array = []
		for e in enemies:
			if is_instance_valid(e) and not e.dead:
				foe_states.append({
					"type": e.type_id, "pos": e.grid_pos,
					"hp": e.hp, "asleep": e.asleep, "facing": e.facing,
				})
		d["enemies"] = foe_states
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if f == null:
		push_warning("save_game: could not open %s" % SAVE_PATH)
		return
	f.store_string(var_to_str(d))
	f.close()


## Load the save file. Returns true if a live run was restored.
## Always restores the meta progression; a dead run starts fresh.
## Side effect: may fill pending_offline_report (shown by the HUD when the
## player was away >= 60s — see _apply_offline_earnings).
func load_game() -> bool:
	if _smoke or not FileAccess.file_exists(SAVE_PATH):
		return false
	pending_offline_report = {}
	var f := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if f == null:
		return false
	var d = str_to_var(f.get_as_text())
	f.close()
	if not (d is Dictionary):
		push_warning("load_game: corrupt save, starting fresh")
		return false
	var save_v := int(d.get("version", 0))
	if save_v < 1 or save_v > SAVE_VERSION:
		push_warning("load_game: unsupported save version %d, starting fresh" % save_v)
		return false
	if save_v < SAVE_VERSION:
		d = _migrate_save(d, save_v)
		GameState.add_log("Save migrated v%d -> v%d." % [save_v, SAVE_VERSION])
	GameState.from_dict(d.get("game_state", {}) as Dictionary)
	Prestige.from_dict(d.get("prestige", {}) as Dictionary)
	LifeTree.from_dict(d.get("life_tree", {}) as Dictionary)
	# Pre-prestige saves have no cycle record — seed it from the live depth.
	Prestige.note_depth(GameState.depth)
	if not GameState.alive:
		return false
	if GameState.mode != GameMode.State.DUNGEON:
		# Phase 3: hub save — meta restored, no floor to rebuild.
		# The boot path routes to the saved hub view.
		hud.refresh()
		GameState.add_log("Welcome back — %s." % GameMode.state_name(GameState.mode).to_lower())
		return true
	var saved_gen := d.get("gen", {}) as Dictionary
	if saved_gen.is_empty():
		push_warning("load_game: dungeon save with no floor data, starting fresh")
		return false
	rng.seed = int(d.get("rng_seed", 0))
	rng.state = int(d.get("rng_state", 0))
	gen = saved_gen
	# Clear any live floor first: load_game can run mid-session (tests,
	# hub resume), and restored foes must not double up on old ones.
	for en in enemies:
		if is_instance_valid(en):
			en.queue_free()
	enemies.clear()
	view.build_floor(gen)
	chests = (d["chests"] as Array).duplicate(true)
	doors = (d["doors"] as Array).duplicate(true)
	loot = (d["loot"] as Array).duplicate(true)
	floor_rooms = (d["floor_rooms"] as Array).duplicate()
	_stairs_room = int(d.get("stairs_room", -1))
	_hp_mult = float(d.get("hp_mult", 1.0))
	_atk_mult = float(d.get("atk_mult", 1.0))
	view.build_loot(loot, chests)
	view.build_doors(doors)
	explored.clear()
	for k in d.get("explored", []):
		explored[k] = true
	for es in d.get("enemies", []):
		var ed := es as Dictionary
		var en := _spawn_enemy(str(ed.get("type", "slime")),
			ed.get("pos", Vector2i.ZERO), bool(ed.get("asleep", false)))
		en.hp = float(ed.get("hp", en.max_hp))
		en.facing = ed.get("facing", Vector2i(0, 1))
	player.place_at(d.get("player_pos", Vector2i.ZERO),
		int(d.get("player_facing", 0)))
	_reveal_around(player.grid_pos)
	hud.refresh()
	if bool(d.get("shop_open", false)):
		_open_floor_shop()
	GameState.add_log("Welcome back — delve resumed at depth %d." % GameState.depth)
	_apply_offline_earnings(d)
	return true


## Pending "While You Were Away…" report, filled by load_game when a live
## delve resumes after >= 60s away. Shown by the HUD; shorter gaps are
## session noise — no credit, no report.
var pending_offline_report := {}


## Offline earnings: wall-clock in, measured math out. James's Oct 10 call:
## FULL speed, NO cap. Depth is HELD (never descended while away), the hero
## never dies while away, and backward clock jumps credit zero with no
## punishment. The clock is trusted for this delta and nothing else.
func _apply_offline_earnings(d: Dictionary) -> void:
	pending_offline_report = {}
	if not GameState.alive or GameState.mode != GameMode.State.DUNGEON:
		return
	var last_seen := int(d.get("last_seen_unix", 0))
	if last_seen <= 0:
		# Pre-feature save: no timestamp, so no backpay for time before the
		# feature existed. (The v2->v3 migration stamps "now" for the same
		# reason — first migrated load earns nothing phantom.)
		return
	var delta_sec := int(Time.get_unix_time_from_system()) - last_seen
	if delta_sec <= 0:
		# Clock moved backwards (travel, DST, manual fix): credit zero,
		# punish nothing. Debug-logged only — never shown to the player.
		push_warning("offline_earnings: backward clock jump (%ds), crediting zero" % delta_sec)
		return
	if delta_sec < 60:
		# Sub-minute gaps are session noise, not away time: no credit, no
		# report. Deliberate deviation from the design paper's "credit
		# silently": crediting here would break the save/load round-trip
		# invariant (a load seconds after a save must restore exact state),
		# which the test suite enforces. Real absences (>= 60s) credit in
		# full below.
		return
	var snap := d.get("delve_snapshot", {}) as Dictionary
	var kpm := float(snap.get("kills_per_min", OfflineEarnings.DEFAULT_KILLS_PER_MIN))
	var gpk := float(snap.get("gold_per_kill", OfflineEarnings.DEFAULT_GOLD_PER_KILL))
	var mult := GameState.gold_mult()
	var earned := OfflineEarnings.compute_earnings(delta_sec / 60.0, kpm, gpk, mult)
	if earned > 0.0:
		# Untracked: offline gold must not feed the measurement window.
		GameState.add_gold(earned, false)
	pending_offline_report = {
		"seconds": delta_sec,
		"away_text": _format_duration(delta_sec),
		"gold": earned,
		"kills_per_min": kpm,
		"gold_per_kill": gpk,
		"gold_mult": mult,
		"depth": GameState.depth,
	}
	GameState.add_log("While you were away (%s): the hero held depth %d and banked %s gold — fought safe, lived to tell it."
		% [_format_duration(delta_sec), GameState.depth, BigNumbers.format(earned)])
	# delta_sec >= 60 here (shorter gaps return early above): the report
	# screen only ever appears for real absences.
	if hud != null:
		hud.show_offline_report(pending_offline_report)


static func _format_duration(total_sec: int) -> String:
	var m := total_sec / 60
	var h := m / 60
	var d := h / 24
	if d > 0:
		return "%dd %dh" % [d, h % 24]
	if h > 0:
		return "%dh %dm" % [h, m % 60]
	if m > 0:
		return "%dm" % m
	return "%ds" % total_sec


## Migrate an older save dict forward to SAVE_VERSION. Additive only: fills
## missing keys with defaults, never deletes or reshapes player data.
func _migrate_save(d: Dictionary, from_v: int) -> Dictionary:
	var v := from_v
	while v < SAVE_VERSION:
		match v:
			1:
				# v1 -> v2: enemy "facing" (backstab) and the "tutorial_done"
				# flag are new. Both restore via .get() defaults, so v1
				# saves need no rewriting — accept as-is.
				pass
			2:
				# v2 -> v3: offline earnings. Stamp NOW as last_seen so the
				# migrated save earns nothing for the pre-feature gap —
				# no phantom backpay on first load after the update.
				# The medians restore via .get() defaults.
				d["last_seen_unix"] = int(Time.get_unix_time_from_system())
		v += 1
	d["version"] = SAVE_VERSION
	return d


## App backgrounded (or window focus lost): persist immediately.
func _on_app_backgrounded() -> void:
	save_game()


## Test/dev helper: remove all live enemies within `radius` (Manhattan) of a
## cell. Used by persist-mode stress tests to give a field revive breathing
## room instead of an instant re-death loop. No kill credit, no loot.
func clear_enemies_near(cell: Vector2i, radius: int) -> void:
	var kept: Array[Enemy] = []
	for en in enemies:
		if not is_instance_valid(en):
			continue
		var d: int = absi(en.grid_pos.x - cell.x) + absi(en.grid_pos.y - cell.y)
		if d <= radius:
			en.queue_free()
		else:
			kept.append(en)
	enemies = kept


# ------------------------------------------------------------------ effects ---

func _spawn_popup(at: Vector3, text: String, color: Color) -> void:
	var popup: DamagePopup = PopupScript.new()
	popup.position = at
	add_child(popup)
	popup.setup(text, color)
