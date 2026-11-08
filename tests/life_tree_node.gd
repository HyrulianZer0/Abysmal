extends Node
## Headless test: v0.11.0 start slice — founder embodiment + Life Tree.
## Boots the real main scene headless and drives:
##   fresh boot (tree locked, no founders) -> depth 2/4/6/8/10 meetings
##   (unlock, auto-root, buffs, deed dialog + sign) -> Life Tree crown /
##   leaf / home navigation -> death (buffs survive, town shows founder
##   figures + deed status) -> save/load round-trip -> old-save compat
##   (save without the life_tree key loads clean defaults).
## Run: godot --headless --path . tests/life_tree_scene.tscn
## Exits 0 on success, 1 on any failure.

const FoundersScript := preload("res://scripts/founders.gd")

var _main: Node = null
var _phase := 0
var _frames := 0
var _failures := 0


func _check(cond: bool, name: String, detail: String = "") -> void:
	if cond:
		print("  PASS  %s" % name)
	else:
		_failures += 1
		printerr("  FAIL  %s  %s" % [name, detail])


func _ready() -> void:
	print("LIFE_TREE: starting")
	if FileAccess.file_exists("user://savegame.dat"):
		DirAccess.remove_absolute("user://savegame.dat")
	_spawn_main()


func _spawn_main() -> void:
	var packed: PackedScene = load("res://scenes/main.tscn")
	_main = packed.instantiate()
	get_tree().root.add_child.call_deferred(_main)


func _process(_delta: float) -> void:
	_frames += 1
	match _phase:
		0:
			_phase_boot()
		1:
			_phase_meetings()
		2:
			_phase_deed()
		3:
			_phase_view_nav()
		4:
			_phase_death()
		5:
			_phase_save_load()
		6:
			_phase_old_save()


func _enter_depth(d: int) -> void:
	GameState.depth = d
	_main._new_depth()


func _buttons_under(n: Node) -> Array:
	var out: Array = []
	var stack: Array = [n]
	while not stack.is_empty():
		var cur: Node = stack.pop_back()
		if cur is Button:
			out.append(cur)
		stack.append_array(cur.get_children())
	return out


func _label_texts_under(n: Node) -> Array:
	var out: Array = []
	var stack: Array = [n]
	while not stack.is_empty():
		var cur: Node = stack.pop_back()
		if cur is Label3D:
			out.append(str(cur.text))
		stack.append_array(cur.get_children())
	return out


# --- phase 0: fresh boot, tree locked --------------------------------------

func _phase_boot() -> void:
	if _frames < 30 or not is_instance_valid(_main) \
			or not _main.is_inside_tree() or _main.get("player") == null:
		return
	print("== boot: fresh, tree locked ==")
	_check(GameState.mode == GameMode.State.DUNGEON, "boot mode is DUNGEON")
	_check(GameState.depth == 1, "boot depth is 1")
	_check(not LifeTree.unlocked, "tree locked at depth 1")
	_check(LifeTree.met_ids().is_empty(), "no founders met at boot")
	_check(is_instance_valid(_main.get("life_tree_view")), "life tree view exists")
	_check(not _main.life_tree_view.is_open(), "life tree view hidden at boot")
	_check(_main.hud.get("_life_tree_button") != null, "HUD Life Tree button exists")
	# Founder data sanity (Oct 24 mapping, not the Oct 8 paper's).
	_check(FoundersScript.founder_at_depth(2)["id"] == "marla", "marla at depth 2")
	_check(FoundersScript.founder_at_depth(4)["id"] == "harlan", "harlan at depth 4")
	_check(FoundersScript.founder_at_depth(6)["id"] == "tovan", "tovan at depth 6")
	_check(FoundersScript.founder_at_depth(8)["id"] == "sarella", "sarella at depth 8")
	_check(FoundersScript.founder_at_depth(10)["id"] == "pello", "pello at depth 10")
	_check(FoundersScript.founder_at_depth(3).is_empty(), "no founder at depth 3")
	GameState.idle_mode = false
	_phase = 1
	_frames = 0


# --- phase 1: meetings at 2/4/6/8/10 ----------------------------------------

func _phase_meetings() -> void:
	if _frames < 2:
		return
	print("== founder meetings 2/4/6/8/10 ==")
	_enter_depth(2)
	_check(LifeTree.unlocked, "tree unlocked on entering depth 2")
	_check(LifeTree.is_met("marla"), "marla met at depth 2")
	_check(is_equal_approx(LifeTree.max_hp_bonus(), 10.0), "well fed +10 max HP")
	_check(is_equal_approx(GameState.max_hp, 60.0), "live max HP includes well fed")
	# Idempotent: re-entering depth 2 roots nothing twice.
	_enter_depth(2)
	_check(is_equal_approx(GameState.max_hp, 60.0), "re-meet is a no-op")
	_enter_depth(4)
	_check(LifeTree.is_met("harlan"), "harlan met at depth 4")
	_check(is_equal_approx(LifeTree.material_yield_mult(), 1.25),
		"well stocked x1.25 material yield")
	_check(is_equal_approx(GameState.material_yield_mult(), 1.25),
		"game state exposes material yield")
	_enter_depth(6)
	_check(LifeTree.is_met("tovan"), "tovan met at depth 6")
	_check(is_equal_approx(LifeTree.regen_bonus(), 0.5), "well rested +0.5 regen")
	_enter_depth(8)
	_check(LifeTree.is_met("sarella"), "sarella met at depth 8")
	_check(is_equal_approx(LifeTree.atk_bonus(), 2.0), "well armed +2 atk")
	_check(is_equal_approx(GameState.atk, 8.0), "live atk includes well armed")
	_enter_depth(10)
	_check(LifeTree.is_met("pello"), "pello met at depth 10")
	_check(is_equal_approx(LifeTree.gold_mult_bonus(), 1.10),
		"inspired x1.10 gold")
	_check(is_equal_approx(GameState.gold_mult(), 1.10),
		"game state gold mult includes inspired")
	_check(is_instance_valid(_main.get("_deed_dialog")),
		"deed dialog shown on pello meeting")
	_phase = 2
	_frames = 0


# --- phase 2: sign the deed -------------------------------------------------

func _phase_deed() -> void:
	if _frames < 2:
		return
	print("== deed dialog: sign ==")
	var dlg = _main.get("_deed_dialog")
	_check(is_instance_valid(dlg), "deed dialog still open")
	var signed := false
	for b in _buttons_under(dlg):
		if (b as Button).text == "Sign the deed":
			(b as Button).pressed.emit()
			signed = true
	_check(signed, "sign button found and pressed")
	_check(LifeTree.town_deed_signed, "deed signed flag set")
	_check(not is_instance_valid(_main.get("_deed_dialog")),
		"deed dialog closed after signing")
	_phase = 3
	_frames = 0


# --- phase 3: crown / leaf / home navigation --------------------------------

func _phase_view_nav() -> void:
	if _frames < 2:
		return
	print("== life tree view navigation ==")
	var v = _main.life_tree_view
	v.show_crown()
	_check(v.is_open(), "crown view opens")
	_check(v.current_leaf() == "", "crown view has no current leaf")
	v.show_leaf("marla")
	_check(v.current_leaf() == "marla", "leaf drill-in sets current leaf")
	_check(v.is_open(), "leaf view stays open")
	v.go_home()
	_check(v.current_leaf() == "", "home button returns to crown")
	_check(v.is_open(), "crown still open after home")
	# Vine page + unknown leaf fallback.
	v.show_leaf("vine")
	_check(v.current_leaf() == "vine", "vine page opens")
	v.show_leaf("bogus")
	_check(v.current_leaf() == "", "unknown leaf falls back to crown")
	# HUD button toggles the view.
	v.hide_tree()
	_check(not v.is_open(), "view closed")
	_main.hud.get("_life_tree_button").pressed.emit()
	_check(v.is_open(), "HUD button opens crown view")
	v.hide_tree()
	_phase = 4
	_frames = 0


# --- phase 4: buffs survive death; town shows founders + deed ---------------

func _phase_death() -> void:
	if _frames < 2:
		return
	print("== death: buffs survive, town embodiment ==")
	GameState.damage_player(1.0e9)
	_main._on_player_death("Test Slime")
	_main.request_restart()
	_check(GameState.mode == GameMode.State.TOWN, "death restart lands in town")
	_check(LifeTree.is_met("marla") and LifeTree.is_met("pello"),
		"founder flags survive death")
	_check(is_equal_approx(GameState.max_hp, 60.0),
		"reset run keeps well fed bonus")
	_check(is_equal_approx(GameState.atk, 8.0),
		"reset run keeps well armed bonus")
	var tv = _main.get("town_view")
	_check(is_instance_valid(tv), "town view built")
	var texts := _label_texts_under(tv)
	var found_marla := false
	var found_pello := false
	for t in texts:
		if str(t).contains("Marla Bramble"):
			found_marla = true
		if str(t).contains("Pello Quin"):
			found_pello = true
	_check(found_marla, "town shows marla silhouette sign")
	_check(found_pello, "town shows pello silhouette sign")
	_check(str(tv.info_label.text).contains("Deed: signed"),
		"town info shows deed signed")
	_phase = 5
	_frames = 0


# --- phase 5: save/load round-trip ------------------------------------------

func _phase_save_load() -> void:
	if _frames < 2:
		return
	print("== save/load round-trip (life_tree key) ==")
	_main.save_game()
	# Tamper, then load must restore.
	LifeTree.unlocked = false
	LifeTree.met = {}
	LifeTree.town_deed_signed = false
	_check(_main.load_game(), "load_game returns true in town")
	_check(LifeTree.unlocked, "tree unlocked restored")
	_check(LifeTree.met_ids().size() == 5, "all 5 founders restored")
	_check(LifeTree.town_deed_signed, "deed signed restored")
	_phase = 6
	_frames = 0


# --- phase 6: old save without the life_tree key ------------------------------

func _phase_old_save() -> void:
	if _frames < 2:
		return
	print("== old-save compat (no life_tree key) ==")
	_main.save_game()
	var f := FileAccess.open("user://savegame.dat", FileAccess.READ)
	var d = str_to_var(f.get_as_text())
	f.close()
	(d as Dictionary).erase("life_tree")
	var w := FileAccess.open("user://savegame.dat", FileAccess.WRITE)
	w.store_string(var_to_str(d))
	w.close()
	_check(_main.load_game(), "old save loads")
	_check(not LifeTree.unlocked, "old save: tree defaults locked")
	_check(LifeTree.met_ids().is_empty(), "old save: no founders met")
	_check(not LifeTree.town_deed_signed, "old save: deed unsigned")
	_finish()


func _finish() -> void:
	if FileAccess.file_exists("user://savegame.dat"):
		DirAccess.remove_absolute("user://savegame.dat")
	if _failures == 0:
		print("LIFE_TREE: ALL PASS")
	else:
		printerr("LIFE_TREE: %d FAILURES" % _failures)
	get_tree().quit(1 if _failures > 0 else 0)
