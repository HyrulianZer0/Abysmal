extends Node
## Focused regression test: the v0.3.0 game-over flow.
## Grants gear, forces death, simulates the death-screen sort
## (pick best weapon + armor), confirms "Delve Again", and verifies the
## picks are equipped as heirlooms in the next run.
## Run: godot --headless --path . tests/death_sort_scene.tscn
## Exits 0 on success, 1 on failure.

const IT := preload("res://scripts/items.gd")

var _main: Node = null
var _phase := 0
var _frames := 0


func _ready() -> void:
	# Fresh boot: a stale save (e.g. a long suite's autosave) would restore
	# mid-run state instead of the fresh run this test drives.
	if FileAccess.file_exists("user://savegame.dat"):
		DirAccess.remove_absolute("user://savegame.dat")
	var packed: PackedScene = load("res://scenes/main.tscn")
	var main = packed.instantiate()
	_main = main
	get_tree().root.add_child.call_deferred(main)
	print("DEATHTEST: scene starting")


func _fail(msg: String) -> void:
	printerr("DEATHTEST FAIL: ", msg)
	get_tree().quit(1)


func _process(_delta: float) -> void:
	_frames += 1
	if _main == null or not is_instance_valid(_main):
		return
	match _phase:
		0:
			if _frames >= 10:
				_phase = 1
				var rng := RandomNumberGenerator.new()
				rng.seed = 5
				# _grant_gear logs each find into GameState.run_gear.
				_main._grant_gear(IT.make_weapon(3, rng))
				_main._grant_gear(IT.make_armor(3, rng))
				_main._grant_gear(IT.make_weapon(1, rng))
				print("DEATHTEST: granted gear, run_gear=", GameState.run_gear.size())
		1:
			if _frames >= 20:
				_phase = 2
				if GameState.damage_player(99999.0):
					_main._on_player_death("Test Doom")
		2:
			if _frames >= 30:
				_phase = 3
				if GameState.alive:
					_fail("player should be dead")
					return
				var hud = _main.get("hud")
				var wbtns: Array = hud.get("_death_weapon_buttons")
				var abtns: Array = hud.get("_death_armor_buttons")
				print("DEATHTEST: dead; panel visible=", hud.get("_death_panel").visible,
					" weapon buttons=", wbtns.size(), " armor buttons=", abtns.size())
				if wbtns.size() != 2 or abtns.size() != 1:
					_fail("expected 2 weapon + 1 armor buttons, got %d + %d" % [wbtns.size(), abtns.size()])
					return
				var best_w := {}
				var best_a := {}
				for item in GameState.run_gear:
					var slot := str(item.get("slot", ""))
					if slot == "weapon" and IT.better(item, best_w):
						best_w = item
					elif slot == "armor" and IT.better(item, best_a):
						best_a = item
				hud.death_test_pick(best_w, best_a)
				hud.death_test_confirm()  # set_heirlooms + restart (synchronous)
				var eq_w: Dictionary = GameState.equipment.get("weapon", {})
				var eq_a: Dictionary = GameState.equipment.get("armor", {})
				if str(eq_w.get("name", "")) != str(best_w.get("name", "")):
					_fail("heirloom weapon not equipped in new run")
					return
				if str(eq_a.get("name", "")) != str(best_a.get("name", "")):
					_fail("heirloom armor not equipped in new run")
					return
				if not GameState.alive or GameState.run_number != 2:
					_fail("new run did not start cleanly")
					return
				if GameState.run_gear.size() != 0:
					_fail("run_gear not cleared for new run")
					return
				print("DEATHTEST: heirloom PASS — weapon=", eq_w.get("name"),
					" armor=", eq_a.get("name"), " run=", GameState.run_number,
					" max_hp=", GameState.max_hp)
				print("DEATHTEST: ALL PASS")
				get_tree().quit(0)
