extends Node
## Headless test: v0.12.0 laurel UI (push step 2).
## Boots the real main scene headless and drives:
##   crown view (layer 30, opaque backdrop, 6 leaves, bottom vine strip
##   in right-to-left order, dark Deep leaf, HOME hidden) -> marla
##   drill-in (profile + nodes, HOME visible) -> home -> vine / deep /
##   unknown-leaf fallback -> narrow-screen vine scroll-to-start.
## Run: godot --headless --path . tests/laurel_ui_scene.tscn
## Exits 0 on success, 1 on any failure.

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
	print("LAUREL_UI: starting")
	if FileAccess.file_exists("user://savegame.dat"):
		DirAccess.remove_absolute("user://savegame.dat")
	var packed: PackedScene = load("res://scenes/main.tscn")
	_main = packed.instantiate()
	get_tree().root.add_child.call_deferred(_main)


func _process(_delta: float) -> void:
	_frames += 1
	match _phase:
		0:
			_phase_boot()
		1:
			_phase_crown()
		2:
			_phase_drill_in()
		3:
			_phase_home()
		4:
			_phase_vine_deep_unknown()
		5:
			_phase_narrow_scroll()


func _label_texts_under(n: Node) -> Array:
	var out: Array = []
	var stack: Array = [n]
	while not stack.is_empty():
		var cur: Node = stack.pop_back()
		if cur is Label:
			out.append(str((cur as Label).text))
		stack.append_array(cur.get_children())
	return out


func _leaf_buttons(v: Node) -> Array:
	var out: Array = []
	for c in (v.get("_vine_leaves") as HBoxContainer).get_children():
		if c is Button:
			out.append(c)
	return out


func _phase_boot() -> void:
	if _frames < 30 or not is_instance_valid(_main) \
			or not _main.is_inside_tree() or _main.get("player") == null:
		return
	print("== boot ok ==")
	_phase = 1
	_frames = 0
	_main.life_tree_view.show_crown()


func _phase_crown() -> void:
	if _frames < 5:
		return
	print("== crown view ==")
	var v = _main.life_tree_view
	_check(v.is_open(), "crown view opens")
	_check(v.current_leaf() == "", "crown view has no current leaf")
	_check(v.layer == 30, "tree layer is 30", "layer %d" % v.layer)
	var bg: ColorRect = (v.get("_root") as Control).get_child(0)
	_check(is_equal_approx(bg.color.a, 1.0), "backdrop fully opaque",
		"alpha %.2f" % bg.color.a)
	var leaves := _leaf_buttons(v)
	_check(leaves.size() == 6, "6 leaves on the vine",
		"found %d" % leaves.size())
	if leaves.size() == 6:
		_check(str((leaves[0] as Button).text).contains("Deep Leaf"),
			"vine tip (left end) is the Deep leaf",
			"leftmost: %s" % (leaves[0] as Button).text)
		_check(str((leaves[5] as Button).text).contains("Marla Bramble"),
			"vine start (right end) is Marla",
			"rightmost: %s" % (leaves[5] as Button).text)
		var sb := (leaves[0] as Button).get_theme_stylebox("normal") as StyleBoxFlat
		var lum := 0.0
		if sb != null:
			lum = (sb.bg_color.r + sb.bg_color.g + sb.bg_color.b) / 3.0
		_check(sb != null and lum < 0.08, "Deep leaf is a simple dark leaf",
			"avg luminance %.3f" % lum)
	# Vine strip sits along the bottom and fully on screen.
	var vp := get_viewport().get_visible_rect().size
	var strip: Control = v.get("_vine_row")
	var r: Rect2 = strip.get_global_rect()
	_check(r.position.y >= vp.y * 0.5, "vine strip in bottom half",
		"strip y %.1f of viewport %.1f" % [r.position.y, vp.y])
	_check(r.position.y + r.size.y <= vp.y + 1.0, "vine strip fully on-screen",
		"strip bottom %.1f vs viewport %.1f" % [r.position.y + r.size.y, vp.y])
	_check(not (v.get("_home_cluster") as Control).visible,
		"HOME hidden in crown view")
	_phase = 2
	_frames = 0
	v.show_leaf("marla")


func _phase_drill_in() -> void:
	if _frames < 3:
		return
	print("== marla drill-in ==")
	var v = _main.life_tree_view
	_check(v.current_leaf() == "marla", "marla drill-in sets current leaf")
	_check(v.is_open(), "leaf view stays open")
	var texts := _label_texts_under(v)
	var joined := "\n".join(texts)
	_check(joined.contains("Marla Bramble"), "drill-in shows marla profile")
	_check(joined.contains("Well Fed"), "drill-in shows marla gift")
	_check(joined.contains("depth 2"), "drill-in shows marla depth")
	_check((v.get("_home_cluster") as Control).visible,
		"HOME visible in drill-in")
	_phase = 3
	_frames = 0
	v.go_home()


func _phase_home() -> void:
	if _frames < 3:
		return
	print("== home ==")
	var v = _main.life_tree_view
	_check(v.current_leaf() == "", "home returns to crown")
	_check(v.is_open(), "crown still open after home")
	_check((v.get("_vine_row") as Control).visible, "vine strip back in crown")
	_phase = 4
	_frames = 0
	v.show_leaf("vine")


func _phase_vine_deep_unknown() -> void:
	if _frames < 3:
		return
	print("== vine / deep / unknown ==")
	var v = _main.life_tree_view
	_check(v.current_leaf() == "vine", "vine page opens")
	var texts := _label_texts_under(v)
	_check("\n".join(texts).contains("Ouroboros"), "vine page shows ouroboros")
	v.show_leaf("deep")
	_check(v.current_leaf() == "deep", "deep leaf opens")
	texts = _label_texts_under(v)
	_check("\n".join(texts).contains("Deep Leaf"), "deep page shows deep leaf")
	v.show_leaf("bogus")
	_check(v.current_leaf() == "", "unknown leaf falls back to crown")
	_phase = 5
	_frames = 0
	get_tree().root.size = Vector2i(390, 844)
	v.show_crown()


func _phase_narrow_scroll() -> void:
	if _frames < 10:
		return
	print("== narrow screen vine scroll ==")
	var v = _main.life_tree_view
	var scroll: ScrollContainer = v.get("_vine_scroll")
	var bar := scroll.get_h_scroll_bar()
	_check(bar.max_value > 0, "vine overflows at 390px width",
		"max %.1f" % bar.max_value)
	_check(scroll.scroll_horizontal >= bar.max_value - bar.page - 1.0,
		"vine scrolled to its start (right end)",
		"scroll %d of max %.1f page %.1f"
		% [scroll.scroll_horizontal, bar.max_value, bar.page])
	v.hide_tree()
	_check(not v.is_open(), "view closed")
	_finish()


func _finish() -> void:
	if FileAccess.file_exists("user://savegame.dat"):
		DirAccess.remove_absolute("user://savegame.dat")
	if _failures == 0:
		print("LAUREL_UI: ALL PASS")
	else:
		printerr("LAUREL_UI: %d FAILURES" % _failures)
	get_tree().quit(1 if _failures > 0 else 0)
