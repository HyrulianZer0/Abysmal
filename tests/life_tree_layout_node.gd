extends Node
## DIAGNOSTIC layout test (v0.11.0 on-device reports, groundwork only).
## Prior suites verified LOGIC, never on-screen layout. This one does:
##   Bug 1: HUD (health status etc.) overlaps the Life Tree view when open.
##   Bug 2: HUD Life Tree button clipped / barely on screen at phone ratios.
## Boots the real main scene headless, measures global rects + CanvasLayer
## order at 1080x2400, 720x1600, 1440x3200, 390x844 (portrait).
## Run: godot --headless --path . tests/life_tree_layout_scene.tscn
## Exits 0 only if BOTH bugs are absent; exits 1 with REPRODUCED lines
## while either bug is present (a future push flips these checks green).

var _main: Node = null
var _phase := 0
var _frames := 0
var _failures := 0
var _sizes := [Vector2i(1080, 2400), Vector2i(720, 1600),
	Vector2i(1440, 3200), Vector2i(390, 844)]
var _size_idx := 0


func _check(cond: bool, name: String, detail: String = "") -> void:
	if cond:
		print("  PASS  %s" % name)
	else:
		_failures += 1
		printerr("  FAIL  %s  %s" % [name, detail])


func _ready() -> void:
	print("LIFE_TREE_LAYOUT: starting")
	if FileAccess.file_exists("user://savegame.dat"):
		DirAccess.remove_absolute("user://savegame.dat")
	# Boot at the first phone ratio so the HUD builds at that size.
	get_tree().root.size = _sizes[0]
	var packed: PackedScene = load("res://scenes/main.tscn")
	_main = packed.instantiate()
	get_tree().root.add_child.call_deferred(_main)


func _process(_delta: float) -> void:
	_frames += 1
	match _phase:
		0:
			_phase_boot()
		1:
			_phase_button_rect()
		2:
			_phase_overlap()


func _phase_boot() -> void:
	if _frames < 30 or not is_instance_valid(_main) \
			or not _main.is_inside_tree() or _main.get("player") == null:
		return
	print("== boot ok, measuring at phone ratios ==")
	_phase = 1
	_frames = 0


## Bug 2: Life Tree button rect vs viewport bounds, per ratio.
func _phase_button_rect() -> void:
	if _frames < 5:
		return
	_frames = 0
	var vp := get_viewport().get_visible_rect().size
	var btn: Control = _main.hud.get("_life_tree_button")
	var r: Rect2 = btn.get_global_rect()
	var overflow := r.position.y + r.size.y - vp.y
	print("  size %s -> viewport %s button rect %s (bottom overflow %.1fpx)"
		% [_sizes[_size_idx], vp, r, overflow])
	_check(r.position.x >= 0 and r.position.y >= 0,
		"button on-screen top-left at %s" % _sizes[_size_idx],
		"rect %s" % r)
	_check(r.position.y + r.size.y <= vp.y,
		"button fully on-screen bottom at %s" % _sizes[_size_idx],
		"REPRODUCED bug 2: bottom %.1fpx past viewport bottom %.1f"
		% [r.position.y + r.size.y, vp.y])
	_check(r.position.x + r.size.x <= vp.x,
		"button fully on-screen right at %s" % _sizes[_size_idx],
		"rect %s vs viewport %s" % [r, vp])
	# Root cause probe: the PINNED rect (from anchors+offsets) vs content.
	# The container auto-grows to its content minimum, but it grows
	# DOWNWARD from its pinned top edge, pushing the last row off-screen.
	var grid: Control = btn.get_parent()
	var vbox: Control = grid.get_parent()
	var content_h := 0.0
	for c in vbox.get_children():
		content_h += (c as Control).size.y
	content_h += 8.0 * float(vbox.get_child_count() - 1)  # separation
	var pinned_h := vbox.offset_bottom - vbox.offset_top  # anchors (1,1)
	print("  button column pinned height %.1f, grown size %.1f, content %.1f"
		% [pinned_h, vbox.size.y, content_h])
	_check(pinned_h >= content_h,
		"button column pinned tall enough at %s" % _sizes[_size_idx],
		"REPRODUCED root cause: pinned %.1f < content %.1f, so the column grows down past the viewport"
		% [pinned_h, content_h])
	_size_idx += 1
	if _size_idx < _sizes.size():
		get_tree().root.size = _sizes[_size_idx]
	else:
		# Back to 1080x2400 for the overlap phase.
		get_tree().root.size = _sizes[0]
		_phase = 2
		_frames = 0


## Bug 1: HUD vs Life Tree view layering + visibility while open.
func _phase_overlap() -> void:
	if _frames < 5:
		return
	print("== life tree open: HUD overlap ==")
	var hud: CanvasLayer = _main.hud
	var tree: CanvasLayer = _main.life_tree_view
	var touch: CanvasLayer = _main.touch_controls
	print("  layers: HUD=%d tree=%d touch=%d" % [hud.layer, tree.layer, touch.layer])
	tree.show_crown()
	_check(tree.is_open(), "tree view opens")
	# Either fix alone would end the overlap: tree above HUD, or HUD hidden.
	_check(tree.layer > hud.layer,
		"tree renders above HUD",
		"REPRODUCED bug 1: tree layer %d < HUD layer %d"
		% [tree.layer, hud.layer])
	_check(not hud.visible,
		"HUD hidden while tree open",
		"REPRODUCED bug 1: HUD stays visible under/over the tree")
	# Geometric overlap: HP panel rect vs tree root rect (both full-screen
	# canvas coords). Even with correct layering this shows what the
	# player sees stacked.
	var hp_bar: Control = hud.get("_hp_bar")
	var hp_panel: Control = hp_bar.get_parent().get_parent()
	var tree_root: Control = tree.get("_root")
	var hp_rect: Rect2 = hp_panel.get_global_rect()
	var tree_rect: Rect2 = tree_root.get_global_rect()
	print("  HP panel rect %s tree rect %s" % [hp_rect, tree_rect])
	_check(not hp_rect.intersects(tree_rect) or tree.layer > hud.layer,
		"no visible HP/tree stacking",
		"REPRODUCED bug 1: HP panel %s sits inside tree view %s on lower layer"
		% [hp_rect, tree_rect])
	# Tree backdrop translucency: anything beneath shows through.
	var bg: ColorRect = tree_root.get_child(0)
	print("  tree backdrop alpha %.2f" % bg.color.a)
	_finish()


func _finish() -> void:
	if FileAccess.file_exists("user://savegame.dat"):
		DirAccess.remove_absolute("user://savegame.dat")
	if _failures == 0:
		print("LIFE_TREE_LAYOUT: ALL PASS")
	else:
		printerr("LIFE_TREE_LAYOUT: %d FAILURES (bugs reproduced)" % _failures)
	get_tree().quit(1 if _failures > 0 else 0)
