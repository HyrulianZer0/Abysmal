class_name LifeTreeView
extends CanvasLayer
## Life Tree laurel UI (v0.12.0 push, step 2: laurel).
##
## The Life Tree's form is the laurel. Crown view (home) layout, top to
## bottom: laurel emblem + title + status; the ouroboros vine center
## (gold ring, no crown jewel — tapping it opens the ascension page);
## the vine strip along the BOTTOM, running RIGHT to LEFT, holding the
## 6 leaves (5 founders + Deep). Tapping a leaf drills into that leaf's
## profile + vein-tree (its stats and nodes); the laurel HOME control
## returns to the crown and recenters at the START of the vine (the
## right end). New leaves join at the tip (the left end) in growth order.
## The vine scrolls horizontally when it overflows; paging arrows flank
## it. No new art assets: the laurel emblem is drawn with primitives
## (gold ring + green leaf marks); true icon art is a later-push item.
##
## Step-1 fixes preserved (do not regress): layer 30, backdrop alpha
## 1.0, HUD hides while open (via opened/closed signals in main.gd),
## death path closes the tree (main.gd), HUD button column computed.
##
## The view is hidden by default; main.gd owns it and toggles it from
## the HUD's Life Tree button. It rebuilds on every show so met/unlocked
## states are always current.

signal closed
## Emitted when the view opens (crown or leaf): main hides the HUD so
## nothing stacks under the full-screen laurel view (v0.12.0 fix 1).
signal opened

const FoundersScript := preload("res://scripts/founders.gd")

var _root: Control
var _center: Control
var _vine_row: Control
var _vine_scroll: ScrollContainer
var _vine_leaves: HBoxContainer
var _leaf_view: VBoxContainer
var _leaf_title: Label
var _leaf_profile: Label
var _leaf_nodes: Label
var _home_cluster: HBoxContainer
var _status_label: Label
var _current_leaf := ""
var _start_scroll_attempts := 0
var _last_scroll_max := -1.0


func _ready() -> void:
	# v0.12.0 fix 1: render above the HUD (layer 10) and the D-pad (20).
	layer = 30
	_root = Control.new()
	_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	_root.visible = false
	add_child(_root)
	# Child 0 MUST stay the backdrop: the layout suite reads it for alpha.
	var bg := ColorRect.new()
	bg.color = Color(0.02, 0.05, 0.03, 1.0)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	_root.add_child(bg)

	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 24)
	margin.add_theme_constant_override("margin_right", 24)
	margin.add_theme_constant_override("margin_top", 24)
	margin.add_theme_constant_override("margin_bottom", 24)
	_root.add_child(margin)
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	margin.add_child(vbox)

	# Header: laurel emblem (the Life Tree entry icon) + title + status.
	var icon_row := HBoxContainer.new()
	icon_row.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_child(icon_row)
	icon_row.add_child(_make_laurel_icon(48))
	var title := Label.new()
	title.text = "THE LIFE TREE — Laurel"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 28)
	vbox.add_child(title)

	_status_label = Label.new()
	_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_status_label.add_theme_font_size_override("font_size", 15)
	_status_label.modulate = Color(1, 1, 1, 0.75)
	vbox.add_child(_status_label)

	# Center: the ouroboros vine (gold ring, no crown jewel) + its button.
	_center = CenterContainer.new()
	_center.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(_center)
	var center_col := VBoxContainer.new()
	center_col.add_theme_constant_override("separation", 12)
	_center.add_child(center_col)
	var ouro := _make_laurel_icon(160)
	ouro.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	center_col.add_child(ouro)
	var vine := Button.new()
	vine.text = "Ouroboros Vine — Ascension"
	vine.custom_minimum_size = Vector2(0, 56)
	vine.add_theme_stylebox_override("normal", _leaf_style(
		Color(0.06, 0.16, 0.10), Color(0.85, 0.70, 0.20), 2))
	vine.add_theme_color_override("font_color", Color(1.0, 0.9, 0.6))
	vine.pressed.connect(show_leaf.bind("vine"))
	center_col.add_child(vine)

	# Leaf drill-in: profile (stats) + vein-tree (nodes). Hidden in crown.
	_leaf_view = VBoxContainer.new()
	_leaf_view.add_theme_constant_override("separation", 8)
	_leaf_view.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_leaf_view.visible = false
	vbox.add_child(_leaf_view)
	_leaf_title = Label.new()
	_leaf_title.add_theme_font_size_override("font_size", 22)
	_leaf_view.add_child(_leaf_title)
	_leaf_profile = Label.new()
	_leaf_profile.add_theme_font_size_override("font_size", 16)
	_leaf_view.add_child(_leaf_profile)
	_leaf_nodes = Label.new()
	_leaf_nodes.add_theme_font_size_override("font_size", 16)
	_leaf_view.add_child(_leaf_nodes)

	# Vine strip along the BOTTOM: paging arrows flank a horizontal
	# scroll of leaf buttons. Children are added in reverse growth order
	# so the vine reads RIGHT to LEFT: Marla (start, right end) through
	# Deep (tip, left end); new growth extends the left tip.
	_vine_row = HBoxContainer.new()
	_vine_row.add_theme_constant_override("separation", 8)
	vbox.add_child(_vine_row)
	var page_left := Button.new()
	page_left.text = "<"
	page_left.custom_minimum_size = Vector2(56, 84)
	page_left.focus_mode = Control.FOCUS_NONE
	page_left.pressed.connect(_page_vine.bind(-1))
	_vine_row.add_child(page_left)
	_vine_scroll = ScrollContainer.new()
	_vine_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_vine_scroll.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_vine_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_vine_scroll.custom_minimum_size = Vector2(0, 84)
	_vine_row.add_child(_vine_scroll)
	_vine_leaves = HBoxContainer.new()
	_vine_leaves.add_theme_constant_override("separation", 8)
	_vine_scroll.add_child(_vine_leaves)
	var page_right := Button.new()
	page_right.text = ">"
	page_right.custom_minimum_size = Vector2(56, 84)
	page_right.focus_mode = Control.FOCUS_NONE
	page_right.pressed.connect(_page_vine.bind(1))
	_vine_row.add_child(page_right)

	# Bottom row: laurel HOME cluster (drill-ins only) + Close.
	var bottom := HBoxContainer.new()
	bottom.alignment = BoxContainer.ALIGNMENT_CENTER
	bottom.add_theme_constant_override("separation", 12)
	vbox.add_child(bottom)
	_home_cluster = HBoxContainer.new()
	_home_cluster.add_theme_constant_override("separation", 6)
	_home_cluster.visible = false
	bottom.add_child(_home_cluster)
	var home_icon := _make_laurel_icon(40)
	home_icon.gui_input.connect(func(ev: InputEvent) -> void:
		if ev is InputEventMouseButton and ev.pressed:
			go_home())
	_home_cluster.add_child(home_icon)
	var home_button := Button.new()
	home_button.text = "Laurel Home"
	home_button.custom_minimum_size = Vector2(180, 52)
	home_button.pressed.connect(go_home)
	_home_cluster.add_child(home_button)
	var close_button := Button.new()
	close_button.text = "Close"
	close_button.custom_minimum_size = Vector2(220, 52)
	close_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	close_button.pressed.connect(hide_tree)
	bottom.add_child(close_button)


## Primitive laurel emblem: a gold ring with green leaf marks around it.
## No textures — the drawn icon art arrives in a later push.
func _make_laurel_icon(px: int) -> Control:
	var icon := Control.new()
	icon.custom_minimum_size = Vector2(px, px)
	var ring := PanelContainer.new()
	ring.set_anchors_preset(Control.PRESET_FULL_RECT)
	var ring_style := StyleBoxFlat.new()
	ring_style.bg_color = Color(0, 0, 0, 0)
	ring_style.border_color = Color(0.85, 0.70, 0.20, 1.0)
	ring_style.set_border_width_all(maxi(2, px / 24))
	ring_style.set_corner_radius_all(px / 2)
	ring.add_theme_stylebox_override("panel", ring_style)
	icon.add_child(ring)
	var leaf_px := maxi(6, px / 8)
	for i in 6:
		var a := (float(i) / 6.0) * TAU - PI / 2.0
		var leaf := ColorRect.new()
		leaf.color = Color(0.15, 0.45, 0.25, 1.0)
		leaf.size = Vector2(leaf_px, leaf_px * 2)
		var r := float(px) / 2.0
		leaf.position = Vector2(
			r + cos(a) * (r - leaf_px) - leaf_px / 2.0,
			r + sin(a) * (r - leaf_px) - leaf_px)
		leaf.rotation = a + PI / 2.0
		icon.add_child(leaf)
	return icon


func _leaf_style(bg: Color, border: Color, width: int) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.border_color = border
	sb.set_border_width_all(width)
	sb.set_corner_radius_all(10)
	return sb


## Show the crown view (home). Rebuilds so states are current, and
## recenters the vine at its START (the right end, Marla's leaf).
func show_crown() -> void:
	_build_vine()
	_center.visible = true
	_vine_row.visible = true
	_leaf_view.visible = false
	_home_cluster.visible = false
	_current_leaf = ""
	_root.visible = true
	opened.emit()
	_start_scroll_attempts = 0
	_last_scroll_max = -1.0
	call_deferred("_scroll_vine_to_start")


## HOME: back to the crown view from any drill-in, vine at its start.
func go_home() -> void:
	show_crown()


## Show a leaf's drill-in view (profile + vein-tree). Falls back to
## crown for unknown leaves.
func show_leaf(leaf_id: String) -> void:
	if leaf_id == "vine":
		_leaf_title.text = "Ouroboros Vine — Ascension"
		_leaf_profile.text = "The vine that binds the laurel — one singular timeline. Every branching timeline is a leaf off the vine, holding that skill's stats and buffs."
		_leaf_nodes.text = "Ascension nodes grow along the serpent-circle in a later push."
	elif LifeTree.leaf_ids().has(leaf_id):
		var f := FoundersScript.founder_by_id(leaf_id)
		if leaf_id == "deep":
			_leaf_title.text = "Deep Leaf"
			_leaf_profile.text = "A simple dark leaf, for now. Future growth roots here in a later push."
		else:
			_leaf_title.text = str(f["name"])
			if LifeTree.is_met(leaf_id):
				_leaf_profile.text = "%s — met at depth %d.\nGift: %s — %s" % [
					str(f["role"]).capitalize(), int(f["depth"]),
					str(f["buff_name"]), str(f["buff_text"])]
			else:
				_leaf_profile.text = "%s — not yet met. Meet %s at depth %d; the gift roots automatically." % [
					str(f["role"]).capitalize(), str(f["name"]), int(f["depth"])]
		var lines: Array = []
		for n in LifeTree.leaf_nodes(leaf_id):
			var node: Array = n
			var extra := " — grows with the soul, no MAX" if int(node[2]) > 0 \
				else " — not yet rooted"
			lines.append("◆ %s — Lv %d — %s%s" % [
				node[0], int(node[2]), node[1], extra])
		_leaf_nodes.text = "\n".join(lines)
	else:
		show_crown()
		return
	_center.visible = false
	_vine_row.visible = false
	_leaf_view.visible = true
	_home_cluster.visible = true
	_current_leaf = leaf_id
	_root.visible = true
	opened.emit()


func hide_tree() -> void:
	_root.visible = false
	closed.emit()


func is_open() -> bool:
	return _root.visible


func current_leaf() -> String:
	return _current_leaf


## Rebuild the bottom vine strip: 6 leaves, right-to-left vine order.
## Children are added tip-first (Deep leftmost) so the start of the vine
## (Marla) sits at the right end; HOME scrolls back to that end.
func _build_vine() -> void:
	for c in _vine_leaves.get_children():
		c.queue_free()
	if LifeTree.unlocked:
		_status_label.text = "The laurel is awake. Tap a leaf to see its gifts."
	else:
		_status_label.text = "The Life Tree wakes when you complete depth 1."
	var ids: Array = LifeTree.leaf_ids()
	ids.reverse()
	for leaf_id in ids:
		var id := str(leaf_id)
		var b := Button.new()
		if id == "deep":
			b.text = "Deep Leaf — future growth"
			b.add_theme_stylebox_override("normal", _leaf_style(
				Color(0.03, 0.06, 0.04), Color(0.15, 0.30, 0.20), 1))
			b.add_theme_color_override("font_color", Color(0.55, 0.65, 0.60))
		else:
			var rooted := LifeTree.is_met(id)
			var suffix := " — rooted" if rooted else " — not yet met"
			b.text = "%s%s" % [LifeTree.leaf_name(id), suffix]
			if rooted:
				b.add_theme_stylebox_override("normal", _leaf_style(
					Color(0.07, 0.20, 0.11), Color(0.85, 0.70, 0.20), 2))
				b.add_theme_color_override("font_color", Color(1.0, 0.9, 0.6))
			else:
				b.add_theme_stylebox_override("normal", _leaf_style(
					Color(0.09, 0.11, 0.09), Color(0.35, 0.35, 0.35), 1))
				b.add_theme_color_override("font_color", Color(0.65, 0.65, 0.65))
		b.custom_minimum_size = Vector2(108, 84)
		b.add_theme_font_size_override("font_size", 14)
		b.disabled = not LifeTree.unlocked
		b.pressed.connect(show_leaf.bind(id))
		_vine_leaves.add_child(b)


## Page the vine strip by one leaf width. +1 moves toward the vine's
## start (right end); -1 moves toward the tip (left end).
func _page_vine(dir: int) -> void:
	_vine_scroll.scroll_horizontal += dir * 116


## HOME-at-start: scroll the vine strip to its right end (the start).
## ScrollContainer clamps scroll to max - page, so setting max lands on
## the start. Retries over deferred frames until the max settles (layout
## grows after a resize/rebuild); when the strip fits, max is 0 and
## there is nothing to scroll.
func _scroll_vine_to_start() -> void:
	if not is_inside_tree():
		return
	var bar := _vine_scroll.get_h_scroll_bar()
	_vine_scroll.scroll_horizontal = int(bar.max_value)
	var at_start := bar.max_value > 0 and \
		_vine_scroll.scroll_horizontal >= bar.max_value - bar.page - 1.0
	var settled := is_equal_approx(bar.max_value, _last_scroll_max)
	if (at_start and settled) or _start_scroll_attempts >= 8:
		return
	_last_scroll_max = bar.max_value
	_start_scroll_attempts += 1
	call_deferred("_scroll_vine_to_start")
