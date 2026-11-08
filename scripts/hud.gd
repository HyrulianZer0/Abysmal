class_name HUD
extends CanvasLayer
const ShopScript := preload("res://scripts/shop.gd")
## Code-built HUD: HP/XP bars, run stats, message log, idle toggle,
## placeholder tabs for Skills/Magic/Prestige/Ascension (Phase 2 stubs),
## and the permadeath run-summary panel.

signal restart_requested
signal drink_requested
## Life Tree button pressed — main.gd toggles the crown view.
signal life_tree_requested
## Floor-clear shop closed by the player — the delve resumes.
signal shop_closed

var _hp_bar: ProgressBar
var _hp_label: Label
var _xp_bar: ProgressBar
var _xp_label: Label
var _depth_label: Label
var _kills_label: Label
var _gold_label: Label
var _run_label: Label
var _log: RichTextLabel
var _idle_button: Button
var _drink_button: Button
var _gear_weapon_label: Label
var _gear_armor_label: Label
var _potion_label: Label
var _minimap: Minimap
var _stub_panel: PanelContainer
var _stub_title: Label
var _stub_body: Label
var _tutorial_panel: PanelContainer
var _tutorial_title: Label
var _tutorial_body: Label
var _tutorial_next: Button
var _tutorial_step := 0
## Paused onboarding popups (game pauses so the player can study controls).
## [title, body] pairs, phone-sized.
const TUTORIAL_STEPS := [
	["Welcome to the Abyss",
		"You are a delver descending into the endless deep. Your hero explores, fights, and loots on their own — you are the brains behind the build."],
	["Idle delving",
		"IDLE is ON: the brain clears room by room — monsters first, then chests, then onward. Press SPACE (or tap Idle) any time to take manual control."],
	["Manual control",
		"WASD / arrows move, Q / E turn, H quaffs a health potion. On touch screens, use the D-pad. Bump into foes, doors, and chests to interact."],
	["Death is progress",
		"When you fall, the death shop spends your gold on skills and charms. The run ends — your power doesn't. Delve deep. Reach depth 10!"],
]
var _settings_button: Button
var _life_tree_button: Button
var _settings_panel: PanelContainer
var _settings_title: Label
var _music_slider: HSlider
var _sfx_slider: HSlider
var _quality_high_btn: Button
var _quality_low_btn: Button
var _pace_btns := {}  # "leisurely" | "normal" | "swift" -> Button
var _cheat_row: HBoxContainer
var _cheat_speed_btn: OptionButton
var _hardcore_btn: CheckButton
var _cheat_row2: HBoxContainer
var _god_mode_btn: CheckButton
var _monster_floor_btn: Button
var _title_taps := 0
var _title_last_tap_msec := 0
const CHEAT_TAPS_NEEDED := 7
const CHEAT_TAP_WINDOW_MSEC := 5000  # was 3000 — too brisk; real-device report (James, v0.8.0)
var _offline_panel: PanelContainer
var _offline_title: Label
var _offline_gold: Label
var _offline_body: Label
var _offline_tween: Tween
signal tutorial_finished
var _death_panel: PanelContainer
var _death_title: Label
var _death_stats: Label
var _death_again_btn: Button
var _shop_close_btn: Button
var _shop_mode := false  # true = floor-clear resupply; false = death screen
var _death_gear_list: VBoxContainer
var _death_pick_weapon: Dictionary = {}
var _death_pick_armor: Dictionary = {}
var _death_weapon_buttons: Array = []  # Array of [Button, Dictionary]
var _death_armor_buttons: Array = []  # Array of [Button, Dictionary]
var _death_tabs: TabContainer
var _tabs_heirlooms: VBoxContainer
var _tabs_items: VBoxContainer
var _shop_gold_label: Label
## v0.12.0 shop fix: pairs of [ScrollContainer, invisible grip Control].
## Each grip is 3x its scrollbar's width and forwards drags to the bar,
## so the bar is grabbable on touch without changing its visual size.
var _shop_scroll_grips: Array = []
var _shop_items_list: VBoxContainer
var _shop_skills_list: VBoxContainer
var _shop_reroll_btn: Button
var _shop_offerings: Array = []
var _shop_rerolls := 0
var _touch_ui := false

const BASE_MARGIN := 12.0

const STUB_TEXT := {
	"Skills": "Skills are bought with gold in the shop\n(death screen + every cleared floor):\nunlock, then upgrade per level. They persist\nacross runs — the progression that STAYS.",
	"Magic": "The magic system is coming in Phase 2:\nmana, a spellbook, and flashy dungeon-clearing\nsorcery for your idle crawler.",
	"Prestige": "Prestige is coming in Phase 2:\nreset your run for permanent multipliers\nand climb even deeper.",
	"Ascension": "Ascension is coming in Phase 2:\nthe ultimate reset — transcend the dungeon\nitself for cosmic bonuses.",
}


func _ready() -> void:
	layer = 10
	_touch_ui = DisplayServer.is_touchscreen_available()
	_build_top_left()
	_build_minimap()
	_build_stats()
	_build_log()
	_build_buttons()
	_build_stub_panel()
	_build_death_panel()
	_build_offline_panel()
	_build_tutorial_panel()
	_build_settings_panel()
	GameState.stats_changed.connect(refresh)
	GameState.log_message.connect(add_log)
	refresh()


func _panel_style() -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.03, 0.03, 0.06, 0.78)
	sb.border_color = Color(0.4, 0.4, 0.55, 0.9)
	sb.set_border_width_all(1)
	sb.set_corner_radius_all(6)
	sb.content_margin_left = 10
	sb.content_margin_right = 10
	sb.content_margin_top = 8
	sb.content_margin_bottom = 8
	return sb


## Safe-area insets (left, top, right, bottom) in canvas coordinates.
## Zeros on desktop/headless — only phones with notches/gesture bars report insets.
func _safe_insets() -> Vector4:
	var vp_size := get_viewport().get_visible_rect().size
	var win := Vector2(DisplayServer.window_get_size())
	if win.x <= 0.0 or win.y <= 0.0 or vp_size.x <= 0.0 or vp_size.y <= 0.0:
		return Vector4.ZERO
	var sx := vp_size.x / win.x
	var sy := vp_size.y / win.y
	var sa := DisplayServer.get_display_safe_area()
	var l := sa.position.x * sx
	var t := sa.position.y * sy
	var r := (win.x - sa.position.x - sa.size.x) * sx
	var b := (win.y - sa.position.y - sa.size.y) * sy
	return Vector4(maxf(l, 0.0), maxf(t, 0.0), maxf(r, 0.0), maxf(b, 0.0))


## Pin a control to an explicit rect: fractional anchors plus pixel offsets.
## No reliance on position-after-preset, so panels can't drift off-screen.
func _pin(c: Control, ax0: float, ay0: float, ax1: float, ay1: float,
		ox0: float, oy0: float, ox1: float, oy1: float) -> void:
	c.anchor_left = ax0
	c.anchor_top = ay0
	c.anchor_right = ax1
	c.anchor_bottom = ay1
	c.offset_left = ox0
	c.offset_top = oy0
	c.offset_right = ox1
	c.offset_bottom = oy1


func _build_top_left() -> void:
	var si := _safe_insets()
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _panel_style())
	var w := 264.0
	var h := 208.0
	_pin(panel, 0, 0, 0, 0, si.x + BASE_MARGIN, si.y + BASE_MARGIN,
		si.x + BASE_MARGIN + w, si.y + BASE_MARGIN + h)
	add_child(panel)
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	panel.add_child(vbox)

	_hp_label = Label.new()
	_hp_label.text = "HP"
	vbox.add_child(_hp_label)
	_hp_bar = ProgressBar.new()
	_hp_bar.custom_minimum_size = Vector2(240, 18)
	_hp_bar.show_percentage = false
	_hp_bar.max_value = 100
	_hp_bar.value = 100
	vbox.add_child(_hp_bar)

	_xp_label = Label.new()
	_xp_label.text = "Lv 1 XP"
	vbox.add_child(_xp_label)
	_xp_bar = ProgressBar.new()
	_xp_bar.custom_minimum_size = Vector2(240, 12)
	_xp_bar.show_percentage = false
	_xp_bar.max_value = 100
	_xp_bar.value = 0
	vbox.add_child(_xp_bar)

	# Gear + potion readouts: the player's job is equipment.
	_gear_weapon_label = _mk_stat_left(vbox, "Wpn: —")
	_gear_armor_label = _mk_stat_left(vbox, "Arm: —")
	_potion_label = _mk_stat_left(vbox, "Potions: HP×0 MP×0")


func _mk_stat_left(parent: Control, text: String) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", 14)
	parent.add_child(l)
	return l


## Fog-of-war minimap: unexplored = black, explored-but-unseen = dim,
## radius 4 around the player always lit. Shows player (with facing tick),
## monsters, chests, loot, and stairs — actors only in explored cells.
##
## The minimap follows the player: it renders a zoomed-in window centered
## on the crawler (VIEW_CELLS across) instead of the whole map. Only when
## the entire map fits inside the viewport does it show the whole map.
class Minimap extends Control:
	const WALL := 0
	const STAIRS := 2
	const SIGHT := 4  # lit radius (Chebyshev) around the player
	const VIEW_CELLS := 21  # cells across the viewport when following

	var grid: Array = []
	var gw := 0
	var gh := 0
	var explored := {}
	var ppos := Vector2i.ZERO
	var facing := 0
	var enemies: Array = []  # Array[Vector2i]
	var chests: Array = []   # Array of {pos, opened}
	var loot: Array = []     # Array of {pos, kind, taken}
	var doors: Array = []    # Array of {pos, state}
	var stairs := Vector2i.ZERO
	# Last computed view window (test hook): [x0, y0, x1, y1] cell bounds.
	var last_view := [0, 0, 0, 0]

	## Pure view-window computation (no drawing): returns
	## [x0, y0, x1, y1, cs, ox, oy]. Follow mode centers on the player and
	## clamps to map edges; whole-map mode fits and centers the map.
	func compute_view() -> Array:
		var want_cs := size.x / float(VIEW_CELLS)
		var vw := VIEW_CELLS  # by construction: size.x / want_cs == VIEW_CELLS
		var vh := int(ceil(size.y / want_cs))
		var cs := want_cs
		var x0 := 0
		var y0 := 0
		var x1 := gw
		var y1 := gh
		if gw > vw or gh > vh:
			x0 = clampi(ppos.x - vw / 2, 0, maxi(gw - vw, 0))
			y0 = clampi(ppos.y - vh / 2, 0, maxi(gh - vh, 0))
			x1 = mini(x0 + vw, gw)
			y1 = mini(y0 + vh, gh)
		else:
			cs = minf(size.x / float(gw), size.y / float(gh))
		last_view = [x0, y0, x1, y1]
		var vis_w := x1 - x0
		var vis_h := y1 - y0
		var ox := (size.x - vis_w * cs) * 0.5 - x0 * cs
		var oy := (size.y - vis_h * cs) * 0.5 - y0 * cs
		return [x0, y0, x1, y1, cs, ox, oy]

	const LOOT_COLORS := {
		"weapon": Color(0.85, 0.85, 0.95),
		"armor": Color(0.35, 0.75, 0.90),
		"health_potion": Color(0.95, 0.30, 0.30),
		"mana_potion": Color(0.35, 0.50, 0.95),
	}

	func _draw() -> void:
		if grid.is_empty() or gw <= 0 or gh <= 0:
			return
		draw_rect(Rect2(Vector2.ZERO, size), Color(0.008, 0.008, 0.018))
		var v: Array = compute_view()
		var cs: float = v[4]
		var ox: float = v[5]
		var oy: float = v[6]
		for y in range(last_view[1], last_view[3]):
			var row: Array = grid[y]
			for x in range(last_view[0], last_view[2]):
				var p := Vector2i(x, y)
				if not explored.has(p):
					continue  # fog: unexplored stays black
				var vis := maxi(absi(x - ppos.x), absi(y - ppos.y)) <= SIGHT
				var col: Color
				var cell: int = row[x]
				if cell == WALL:
					col = Color(0.30, 0.32, 0.42) if vis else Color(0.13, 0.14, 0.19)
				elif cell == STAIRS:
					col = Color(0.95, 0.78, 0.30)
				else:
					col = Color(0.38, 0.40, 0.50) if vis else Color(0.17, 0.18, 0.24)
				draw_rect(Rect2(Vector2(ox + x * cs, oy + y * cs), Vector2(cs + 0.5, cs + 0.5)), col)
		# Loot dots (explored cells only, inside the view window).
		for l in loot:
			if bool(l["taken"]):
				continue
			var lp: Vector2i = l["pos"]
			if not explored.has(lp) or not _in_view(lp):
				continue
			draw_circle(_cc(lp, ox, oy, cs), cs * 0.34,
				LOOT_COLORS.get(str(l["kind"]), Color.WHITE))
		# Unopened chests: violet ring if sealed, red if locked, gold if open.
		for c in chests:
			if bool(c["opened"]):
				continue
			var cp: Vector2i = c["pos"]
			if not explored.has(cp) or not _in_view(cp):
				continue
			var ccol := Color(0.80, 0.58, 0.22)
			if bool(c.get("sealed", false)):
				ccol = Color(0.65, 0.4, 1.0)
			elif int(c.get("tumblers", 0)) > 0:
				ccol = Color(1.0, 0.35, 0.35)
			draw_circle(_cc(cp, ox, oy, cs), cs * 0.42, ccol)
		# Doors: brown = closed, red = locked, skipped when open.
		for d in doors:
			var dp: Vector2i = d["pos"]
			if not explored.has(dp) or not _in_view(dp):
				continue
			var st := str(d.get("state", "open"))
			if st == "open":
				continue
			var dcol := Color(0.55, 0.38, 0.2) if st == "closed" \
				else Color(1.0, 0.3, 0.3)
			draw_rect(Rect2(_cc(dp, ox, oy, cs) - Vector2(cs, cs) * 0.4,
				Vector2(cs, cs) * 0.8), dcol)
		# Monsters (explored cells only, inside the view window).
		for epos in enemies:
			if not explored.has(epos) or not _in_view(epos):
				continue
			draw_circle(_cc(epos, ox, oy, cs), cs * 0.38, Color(0.95, 0.25, 0.25))
		# Player + facing tick.
		var pc := _cc(ppos, ox, oy, cs)
		var pcol := Color(0.35, 1.0, 0.45)
		draw_circle(pc, cs * 0.46, pcol)
		var fdir: Vector2 = [Vector2(0, -1), Vector2(1, 0), Vector2(0, 1), Vector2(-1, 0)][facing]
		draw_line(pc, pc + fdir * cs * 0.95, pcol, 2.0)


	func _in_view(p: Vector2i) -> bool:
		return p.x >= last_view[0] and p.x < last_view[2] \
			and p.y >= last_view[1] and p.y < last_view[3]

	func _cc(p: Vector2i, ox: float, oy: float, cs: float) -> Vector2:
		return Vector2(ox + (float(p.x) + 0.5) * cs, oy + (float(p.y) + 0.5) * cs)


const MINIMAP_PX := 184.0


func _build_minimap() -> void:
	var si := _safe_insets()
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _panel_style())
	# Explicit anchor+offset rect (v0.1.1 lesson): nothing clips off-screen.
	_pin(panel, 1, 0, 1, 0, -(si.z + BASE_MARGIN + MINIMAP_PX), si.y + BASE_MARGIN,
		-(si.z + BASE_MARGIN), si.y + BASE_MARGIN + MINIMAP_PX)
	add_child(panel)
	_minimap = Minimap.new()
	_minimap.custom_minimum_size = Vector2(MINIMAP_PX - 20, MINIMAP_PX - 20)
	_minimap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(_minimap)


func _build_stats() -> void:
	var si := _safe_insets()
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _panel_style())
	var w := MINIMAP_PX
	var h := 132.0
	# Directly under the minimap, same right edge.
	_pin(panel, 1, 0, 1, 0, -(si.z + BASE_MARGIN + w), si.y + BASE_MARGIN + MINIMAP_PX + 8,
		-(si.z + BASE_MARGIN), si.y + BASE_MARGIN + MINIMAP_PX + 8 + h)
	add_child(panel)
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 4)
	panel.add_child(vbox)
	_run_label = _mk_stat(vbox, "Run #1")
	_depth_label = _mk_stat(vbox, "Depth: 1")
	_kills_label = _mk_stat(vbox, "Kills: 0")
	_gold_label = _mk_stat(vbox, "Gold: 0")


## Feed fresh world state to the minimap (called by main.gd on world events).
func update_minimap(grid: Array, gw: int, gh: int, explored: Dictionary,
		enemy_cells: Array, chests: Array, loot: Array,
		player_pos: Vector2i, facing: int, stairs: Vector2i,
		doors: Array = []) -> void:
	if _minimap == null:
		return
	_minimap.grid = grid
	_minimap.gw = gw
	_minimap.gh = gh
	_minimap.explored = explored
	_minimap.enemies = enemy_cells
	_minimap.chests = chests
	_minimap.loot = loot
	_minimap.doors = doors
	_minimap.ppos = player_pos
	_minimap.facing = facing
	_minimap.stairs = stairs
	_minimap.queue_redraw()


func _mk_stat(parent: Control, text: String) -> Label:
	var l := Label.new()
	l.text = text
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	parent.add_child(l)
	return l


func _build_log() -> void:
	var si := _safe_insets()
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _panel_style())
	var w := 400.0
	var h := 170.0
	# On touch devices the D-pad owns the bottom-left corner, so the log
	# floats above it.
	var lift := 196.0 if _touch_ui else 0.0
	_pin(panel, 0, 1, 0, 1, si.x + BASE_MARGIN, -(si.w + BASE_MARGIN + lift + h),
		si.x + BASE_MARGIN + w, -(si.w + BASE_MARGIN + lift))
	add_child(panel)
	_log = RichTextLabel.new()
	_log.bbcode_enabled = true
	_log.scroll_following = true
	_log.custom_minimum_size = Vector2(360, 144)
	panel.add_child(_log)


## Idle toggle stylebox: small square, green border when ON.
func _idle_stylebox(on: bool) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.04, 0.10, 0.05, 0.92) if on else Color(0.03, 0.03, 0.06, 0.85)
	sb.border_color = Color(0.25, 0.95, 0.35, 1.0) if on else Color(0.45, 0.45, 0.55, 0.9)
	sb.set_border_width_all(3 if on else 2)
	sb.set_corner_radius_all(8)
	return sb


func _build_buttons() -> void:
	var si := _safe_insets()
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)
	var w := 232.0
	add_child(vbox)

	# Idle: small square toggle. Green border = auto-delving ON.
	var idle_row := HBoxContainer.new()
	idle_row.alignment = BoxContainer.ALIGNMENT_END
	idle_row.add_theme_constant_override("separation", 8)
	vbox.add_child(idle_row)
	# Manual potion button (the idle brain auto-drinks on its own).
	_drink_button = Button.new()
	_drink_button.text = "HP×0"
	_drink_button.add_theme_font_size_override("font_size", 18)
	_drink_button.focus_mode = Control.FOCUS_NONE
	_drink_button.tooltip_text = "Drink health potion (H)"
	_drink_button.custom_minimum_size = Vector2(64, 64)
	_drink_button.pressed.connect(_on_drink_pressed)
	idle_row.add_child(_drink_button)
	_idle_button = Button.new()
	_idle_button.text = "AUTO"
	_idle_button.add_theme_font_size_override("font_size", 16)
	_idle_button.toggle_mode = true
	_idle_button.focus_mode = Control.FOCUS_NONE
	_idle_button.tooltip_text = "Idle auto-delve (Space)"
	_idle_button.custom_minimum_size = Vector2(64, 64)
	_idle_button.add_theme_stylebox_override("normal", _idle_stylebox(false))
	_idle_button.add_theme_stylebox_override("hover", _idle_stylebox(false))
	_idle_button.add_theme_stylebox_override("pressed", _idle_stylebox(true))
	_idle_button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	_idle_button.add_theme_stylebox_override("disabled", _idle_stylebox(false))
	_idle_button.pressed.connect(_on_idle_toggled)
	idle_row.add_child(_idle_button)
	# Settings: volumes, quality, and a very-hidden dev corner.
	_settings_button = Button.new()
	_settings_button.text = "SET"
	_settings_button.add_theme_font_size_override("font_size", 14)
	_settings_button.focus_mode = Control.FOCUS_NONE
	_settings_button.tooltip_text = "Settings"
	_settings_button.custom_minimum_size = Vector2(64, 64)
	_settings_button.pressed.connect(_on_settings_pressed)
	idle_row.add_child(_settings_button)

	# Phase-2 tabs in a 2x2 grid so the panel stays narrow and on-screen.
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 8)
	grid.add_theme_constant_override("v_separation", 8)
	vbox.add_child(grid)
	for tab_name in ["Skills", "Magic", "Prestige", "Ascension"]:
		var b := Button.new()
		b.text = tab_name
		b.focus_mode = Control.FOCUS_NONE
		b.custom_minimum_size = Vector2(108, 52)
		b.pressed.connect(_on_stub_pressed.bind(tab_name))
		grid.add_child(b)
	# Life Tree: the soul tree (v0.11.0) — opens the laurel crown view.
	_life_tree_button = Button.new()
	_life_tree_button.text = "Life Tree"
	_life_tree_button.focus_mode = Control.FOCUS_NONE
	_life_tree_button.custom_minimum_size = Vector2(108, 52)
	_life_tree_button.pressed.connect(_on_life_tree_pressed)
	grid.add_child(_life_tree_button)

	# Pin AFTER children exist so the pinned height comes from content
	# (idle row 64 + grid 112 + Life Tree button 52 + 2x8 gaps = 244).
	# The old pinned 216 grew downward and clipped the Life Tree button
	# exactly 16px off-screen (v0.12.0 fix 2).
	var content_h := 0.0
	for c in vbox.get_children():
		content_h += (c as Control).get_combined_minimum_size().y
	content_h += 8.0 * float(vbox.get_child_count() - 1)
	_pin(vbox, 1, 1, 1, 1, -(si.z + BASE_MARGIN + w), -(si.w + BASE_MARGIN + content_h),
		-(si.z + BASE_MARGIN), -(si.w + BASE_MARGIN))


func _center_wrap(panel: PanelContainer) -> void:
	# Full-screen CenterContainer so the panel is truly centered.
	# mouse_filter IGNORE: the wrapper must not eat clicks for UI beneath it.
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(center)
	center.add_child(panel)


func _build_stub_panel() -> void:
	_stub_panel = PanelContainer.new()
	_stub_panel.add_theme_stylebox_override("panel", _panel_style())
	_stub_panel.custom_minimum_size = Vector2(340, 210)
	_stub_panel.visible = false
	_center_wrap(_stub_panel)
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	_stub_panel.add_child(vbox)
	_stub_title = Label.new()
	_stub_title.add_theme_font_size_override("font_size", 22)
	vbox.add_child(_stub_title)
	_stub_body = Label.new()
	_stub_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(_stub_body)
	var close := Button.new()
	close.text = "Close"
	if _touch_ui:
		close.custom_minimum_size = Vector2(0, 56)
	close.pressed.connect(func() -> void:
		_click()
		_stub_panel.visible = false
	)
	vbox.add_child(close)


func _build_tutorial_panel() -> void:
	_tutorial_panel = PanelContainer.new()
	_tutorial_panel.add_theme_stylebox_override("panel", _panel_style())
	_tutorial_panel.custom_minimum_size = Vector2(360, 230)
	_tutorial_panel.visible = false
	# The game pauses during the tutorial — this panel must stay interactive.
	_tutorial_panel.process_mode = Node.PROCESS_MODE_ALWAYS
	_center_wrap(_tutorial_panel)
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	_tutorial_panel.add_child(vbox)
	_tutorial_title = Label.new()
	_tutorial_title.add_theme_font_size_override("font_size", 24)
	vbox.add_child(_tutorial_title)
	_tutorial_body = Label.new()
	_tutorial_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_tutorial_body.custom_minimum_size = Vector2(330, 110)
	vbox.add_child(_tutorial_body)
	_tutorial_next = Button.new()
	_tutorial_next.text = "Next"
	if _touch_ui:
		_tutorial_next.custom_minimum_size = Vector2(0, 56)
	_tutorial_next.pressed.connect(_on_tutorial_next)
	vbox.add_child(_tutorial_next)


## Show the paused onboarding popups (fresh boot, floor 1, once ever).
func show_tutorial() -> void:
	_tutorial_step = 0
	_show_tutorial_step()
	_tutorial_panel.visible = true


func _show_tutorial_step() -> void:
	var s: Array = TUTORIAL_STEPS[_tutorial_step]
	_tutorial_title.text = str(s[0])
	_tutorial_body.text = str(s[1])
	_tutorial_next.text = "Delve!" if _tutorial_step == TUTORIAL_STEPS.size() - 1 else "Next"


func _on_tutorial_next() -> void:
	_click()
	_tutorial_step += 1
	if _tutorial_step >= TUTORIAL_STEPS.size():
		_tutorial_panel.visible = false
		tutorial_finished.emit()
	else:
		_show_tutorial_step()


func _build_settings_panel() -> void:
	_settings_panel = PanelContainer.new()
	_settings_panel.add_theme_stylebox_override("panel", _panel_style())
	_settings_panel.custom_minimum_size = Vector2(360, 0)
	_settings_panel.visible = false
	_center_wrap(_settings_panel)
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	_settings_panel.add_child(vbox)
	_settings_title = Label.new()
	_settings_title.text = "Settings"
	_settings_title.add_theme_font_size_override("font_size", 24)
	# Fat tap band for the easter egg: the bare label was a ~30px strip —
	# real-device taps kept missing it (James, v0.8.0). 64px tall, full width.
	_settings_title.custom_minimum_size = Vector2(0, 64)
	_settings_title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_settings_title.mouse_filter = Control.MOUSE_FILTER_STOP
	_settings_title.gui_input.connect(_on_settings_title_input)
	vbox.add_child(_settings_title)
	vbox.add_child(_labeled_slider("Music", true))
	vbox.add_child(_labeled_slider("SFX", false))
	# Quality: high/low.
	var qrow := HBoxContainer.new()
	qrow.add_theme_constant_override("separation", 8)
	vbox.add_child(qrow)
	var qlabel := Label.new()
	qlabel.text = "Quality"
	qlabel.custom_minimum_size = Vector2(70, 0)
	qrow.add_child(qlabel)
	_quality_high_btn = _quality_button("High")
	_quality_low_btn = _quality_button("Low")
	qrow.add_child(_quality_high_btn)
	qrow.add_child(_quality_low_btn)
	_refresh_quality_buttons()
	# Delve pace: player-facing presentation speed (never a balance lever).
	var prow := HBoxContainer.new()
	prow.add_theme_constant_override("separation", 8)
	vbox.add_child(prow)
	var plabel := Label.new()
	plabel.text = "Delve pace"
	plabel.custom_minimum_size = Vector2(70, 0)
	prow.add_child(plabel)
	for p in ["leisurely", "normal", "swift"]:
		var b := _pace_button(p)
		_pace_btns[p] = b
		prow.add_child(b)
	_refresh_pace_buttons()
	# Cheat row: DEV-ONLY, revealed by the title easter egg. Never advertised.
	_cheat_row = HBoxContainer.new()
	_cheat_row.add_theme_constant_override("separation", 8)
	_cheat_row.visible = false
	vbox.add_child(_cheat_row)
	var clabel := Label.new()
	clabel.text = "DEV speed"
	clabel.custom_minimum_size = Vector2(70, 0)
	_cheat_row.add_child(clabel)
	_cheat_speed_btn = OptionButton.new()
	# The UI caps at 8x — 16x stays reachable programmatically (test
	# suites, --speed flag) but is no longer offered here. A saved 16x
	# clamps the SELECTION to 8x gracefully; the stored value itself
	# is left alone until the user picks from the menu.
	for s in ["1x", "2x", "4x", "8x"]:
		_cheat_speed_btn.add_item(s)
	_cheat_speed_btn.selected = [1.0, 2.0, 4.0, 8.0].find(minf(Settings.cheat_speed, 8.0))
	if _cheat_speed_btn.selected < 0:
		_cheat_speed_btn.selected = 0
	_cheat_speed_btn.item_selected.connect(_on_cheat_speed_selected)
	_cheat_row.add_child(_cheat_speed_btn)
	# Hardcore: OPT-IN, dev-corner only. Death forfeits all carried gold
	# and the per-death monster ramp becomes +5%/run instead of +2%.
	# Never advertised anywhere else.
	_hardcore_btn = CheckButton.new()
	_hardcore_btn.text = "Hardcore"
	_hardcore_btn.button_pressed = Settings.hardcore
	_hardcore_btn.toggled.connect(_on_hardcore_toggled)
	_cheat_row.add_child(_hardcore_btn)
	# Cheat row 2: DEV-ONLY testing tools, same hidden reveal as row 1.
	_cheat_row2 = HBoxContainer.new()
	_cheat_row2.add_theme_constant_override("separation", 8)
	_cheat_row2.visible = false
	vbox.add_child(_cheat_row2)
	# God mode: enemy hits never reduce player HP (see GameState.damage_player).
	_god_mode_btn = CheckButton.new()
	_god_mode_btn.text = "DEV god mode"
	_god_mode_btn.button_pressed = Settings.dev_god_mode
	_god_mode_btn.toggled.connect(_on_god_mode_toggled)
	_cheat_row2.add_child(_god_mode_btn)
	# One-shot: the next generated floor becomes a monster floor.
	_monster_floor_btn = Button.new()
	_monster_floor_btn.pressed.connect(_on_dev_monster_floor_pressed)
	_cheat_row2.add_child(_monster_floor_btn)
	_refresh_monster_floor_btn()
	var close := Button.new()
	close.text = "Close"
	if _touch_ui:
		close.custom_minimum_size = Vector2(0, 56)
	close.pressed.connect(func() -> void:
		_click()
		_settings_panel.visible = false
	)
	vbox.add_child(close)


func _labeled_slider(label_text: String, is_music: bool) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	var label := Label.new()
	label.text = label_text
	label.custom_minimum_size = Vector2(70, 0)
	row.add_child(label)
	var slider := HSlider.new()
	slider.min_value = 0.0
	slider.max_value = 100.0
	slider.step = 1.0
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if is_music:
		slider.value = AudioManager.get_music_volume() * 100.0
		slider.value_changed.connect(func(v: float) -> void:
			AudioManager.set_music_volume(v / 100.0))
		_music_slider = slider
	else:
		slider.value = AudioManager.get_sfx_volume() * 100.0
		slider.value_changed.connect(func(v: float) -> void:
			AudioManager.set_sfx_volume(v / 100.0))
		_sfx_slider = slider
	row.add_child(slider)
	return row


func _quality_button(label_text: String) -> Button:
	var b := Button.new()
	b.text = label_text
	b.toggle_mode = true
	b.focus_mode = Control.FOCUS_NONE
	b.custom_minimum_size = Vector2(110, 48)
	b.pressed.connect(func() -> void:
		_click()
		Settings.set_quality(label_text.to_lower(), get_viewport())
		_refresh_quality_buttons()
	)
	return b


func _refresh_quality_buttons() -> void:
	_quality_high_btn.button_pressed = Settings.quality == "high"
	_quality_low_btn.button_pressed = Settings.quality == "low"


func _pace_button(pace: String) -> Button:
	var b := Button.new()
	b.text = pace.capitalize()
	b.toggle_mode = true
	b.focus_mode = Control.FOCUS_NONE
	b.custom_minimum_size = Vector2(100, 48)
	b.pressed.connect(func() -> void:
		_click()
		Settings.set_delve_pace(pace)
		_refresh_pace_buttons()
	)
	return b


func _refresh_pace_buttons() -> void:
	for p in _pace_btns:
		(_pace_btns[p] as Button).button_pressed = Settings.delve_pace == p


## Very-hidden dev corner: 7 taps on the title within 3 seconds.
func _on_settings_title_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT:
			_register_title_tap()
	elif event is InputEventScreenTouch:
		var st := event as InputEventScreenTouch
		if st.pressed:
			_register_title_tap()


func _register_title_tap() -> void:
	var now := Time.get_ticks_msec()
	if now - _title_last_tap_msec > CHEAT_TAP_WINDOW_MSEC:
		_title_taps = 0
	_title_last_tap_msec = now
	_title_taps += 1
	if _title_taps >= CHEAT_TAPS_NEEDED:
		_title_taps = 0
		_cheat_row.visible = true
		_cheat_row2.visible = true


func _on_cheat_speed_selected(idx: int) -> void:
	_click()
	# UI ceiling is 8x; 16x remains settable only from code/tests.
	var speeds := [1.0, 2.0, 4.0, 8.0]
	Settings.cheat_speed = speeds[clampi(idx, 0, speeds.size() - 1)]
	GameState.speed_mult = Settings.cheat_speed
	Settings.save_all()


func _on_god_mode_toggled(on: bool) -> void:
	_click()
	Settings.dev_god_mode = on
	Settings.save_all()
	GameState.add_log("DEV god mode " + ("ON — enemy hits cannot hurt you." if on else "OFF — mortality restored."))


func _on_dev_monster_floor_pressed() -> void:
	_click()
	GameState.dev_force_next_monster_floor = true
	_refresh_monster_floor_btn()
	GameState.add_log("DEV: the next floor will be a MONSTER FLOOR.")


func _refresh_monster_floor_btn() -> void:
	_monster_floor_btn.text = "Monster floor: ARMED" if GameState.dev_force_next_monster_floor \
		else "Next floor: monster floor"


func _on_hardcore_toggled(on: bool) -> void:
	_click()
	Settings.hardcore = on
	Settings.save_all()
	GameState.add_log("Hardcore " + ("ON — death forfeits all carried gold, monsters hunger +5%/run." if on else "OFF — the dungeon is forgiving again."))


func _on_settings_pressed() -> void:
	_click()
	# Refresh slider positions (volumes may have changed elsewhere).
	_music_slider.value = AudioManager.get_music_volume() * 100.0
	_sfx_slider.value = AudioManager.get_sfx_volume() * 100.0
	_hardcore_btn.set_pressed_no_signal(Settings.hardcore)
	_god_mode_btn.set_pressed_no_signal(Settings.dev_god_mode)
	_refresh_monster_floor_btn()
	_settings_panel.visible = true


func _build_death_panel() -> void:
	_death_panel = PanelContainer.new()
	_death_panel.add_theme_stylebox_override("panel", _panel_style())
	_death_panel.custom_minimum_size = Vector2(460, 0)
	_death_panel.visible = false
	_center_wrap(_death_panel)
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)
	_death_panel.add_child(vbox)
	var title := Label.new()
	_death_title = title
	title.text = "YOU DIED"
	title.add_theme_font_size_override("font_size", 30)
	title.add_theme_color_override("font_color", Color(1.0, 0.3, 0.3))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)
	_death_stats = Label.new()
	_death_stats.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(_death_stats)
	_shop_gold_label = Label.new()
	_shop_gold_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_shop_gold_label.add_theme_font_size_override("font_size", 16)
	vbox.add_child(_shop_gold_label)
	_death_tabs = TabContainer.new()
	_death_tabs.custom_minimum_size = Vector2(440, 300)
	vbox.add_child(_death_tabs)
	_tabs_heirlooms = VBoxContainer.new()
	_tabs_heirlooms.name = "Heirlooms"
	_tabs_heirlooms.add_theme_constant_override("separation", 4)
	_death_tabs.add_child(_tabs_heirlooms)
	var gear_title := Label.new()
	gear_title.text = "— Gear found this run: take 1 weapon + 1 armor —"
	gear_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_tabs_heirlooms.add_child(gear_title)
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(420, 220)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_tabs_heirlooms.add_child(scroll)
	_mk_shop_scroll_grip(scroll)
	_death_gear_list = VBoxContainer.new()
	_death_gear_list.add_theme_constant_override("separation", 4)
	_death_gear_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(_death_gear_list)

	# --- Shop: Items tab (Brotato-style 4 random offerings + re-roll) ------
	_tabs_items = VBoxContainer.new()
	_tabs_items.name = "Items"
	_tabs_items.add_theme_constant_override("separation", 4)
	_death_tabs.add_child(_tabs_items)
	var items_note := Label.new()
	items_note.text = "Charms are permanent and stack. Prices rise per copy owned."
	items_note.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	items_note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_tabs_items.add_child(items_note)
	_shop_items_list = VBoxContainer.new()
	_shop_items_list.add_theme_constant_override("separation", 4)
	_shop_items_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_tabs_items.add_child(_shop_items_list)
	_shop_reroll_btn = Button.new()
	if _touch_ui:
		_shop_reroll_btn.custom_minimum_size = Vector2(0, 52)
	_shop_reroll_btn.pressed.connect(_on_shop_reroll)
	_tabs_items.add_child(_shop_reroll_btn)

	# --- Shop: Skills tab (canon 14, buy unlock then upgrade) --------------
	var skills_scroll := ScrollContainer.new()
	skills_scroll.name = "Skills"
	skills_scroll.custom_minimum_size = Vector2(420, 260)
	skills_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_death_tabs.add_child(skills_scroll)
	_mk_shop_scroll_grip(skills_scroll)
	_shop_skills_list = VBoxContainer.new()
	_shop_skills_list.add_theme_constant_override("separation", 4)
	_shop_skills_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	skills_scroll.add_child(_shop_skills_list)

	var again := Button.new()
	_death_again_btn = again
	again.text = "Delve Again (R)"
	if _touch_ui:
		again.custom_minimum_size = Vector2(0, 64)
	again.pressed.connect(_on_death_confirm)
	vbox.add_child(again)
	# Floor-clear shop mode: same shop, no heirlooms — one tap to resume.
	_shop_close_btn = Button.new()
	_shop_close_btn.text = "Keep Delving"
	if _touch_ui:
		_shop_close_btn.custom_minimum_size = Vector2(0, 64)
	_shop_close_btn.visible = false
	_shop_close_btn.pressed.connect(_on_shop_close)
	vbox.add_child(_shop_close_btn)


## Rebuild the death-screen gear list from this run's finds.
func _populate_death_gear() -> void:
	for child in _death_gear_list.get_children():
		child.queue_free()
	_death_weapon_buttons.clear()
	_death_armor_buttons.clear()
	_death_pick_weapon = {}
	_death_pick_armor = {}
	var weapons: Array = []
	var armors: Array = []
	for item in GameState.run_gear:
		if str(item.get("slot", "")) == "weapon":
			weapons.append(item)
		elif str(item.get("slot", "")) == "armor":
			armors.append(item)
	if weapons.is_empty() and armors.is_empty():
		var none := Label.new()
		none.text = "No gear found this run."
		none.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_death_gear_list.add_child(none)
		return
	_add_death_gear_section("Weapons", weapons, "weapon", _death_weapon_buttons)
	_add_death_gear_section("Armor", armors, "armor", _death_armor_buttons)


func _add_death_gear_section(header: String, items: Array, slot: String, btn_list: Array) -> void:
	var h := Label.new()
	h.text = header
	h.add_theme_font_size_override("font_size", 16)
	_death_gear_list.add_child(h)
	for item in items:
		var stat := "atk" if slot == "weapon" else "def"
		var label := "%s  +%s %s  [%s]" % [str(item["name"]),
			BigNumbers.format(float(item.get(stat, 0.0))), stat.to_upper(),
			str(item.get("rarity", "?"))]
		var b := Button.new()
		b.text = label
		b.alignment = HORIZONTAL_ALIGNMENT_LEFT
		b.add_theme_color_override("font_color", Items.rarity_color(str(item.get("rarity", ""))))
		if _touch_ui:
			b.custom_minimum_size = Vector2(0, 52)
		b.set_meta("label", label)
		b.pressed.connect(_on_death_gear_pressed.bind(b, item, slot))
		_death_gear_list.add_child(b)
		btn_list.append([b, item])


func _on_death_gear_pressed(b: Button, item: Dictionary, slot: String) -> void:
	_click()
	var btn_list: Array = _death_weapon_buttons if slot == "weapon" else _death_armor_buttons
	if slot == "weapon":
		_death_pick_weapon = item
	else:
		_death_pick_armor = item
	for pair in btn_list:
		var ob: Button = pair[0]
		var base: String = ob.get_meta("label")
		ob.text = ("▶ " if pair[1] == item else "") + base


## "Delve Again": carry the picks into the next run as heirlooms, then restart.
func _on_death_confirm() -> void:
	AudioManager.play_sfx("ui_confirm")
	GameState.set_heirlooms(_death_pick_weapon, _death_pick_armor)
	restart_requested.emit()


# ------------------------------------------------------------- death shop ---
## Brotato-style: 4 random charm offerings per death (Luck adds more), plus
## the canon skill list to unlock/upgrade. Everything is permanent — death
## always leaves you stronger. Rolls fresh on every death screen.

func _roll_shop() -> void:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	_shop_offerings = ShopScript.roll_offerings(rng, GameState.skill_level("luck"))
	_shop_rerolls = 0


func _refresh_shop_gold() -> void:
	_shop_gold_label.text = "Gold: %s" % BigNumbers.format(GameState.gold)


func _populate_shop_items() -> void:
	for child in _shop_items_list.get_children():
		child.queue_free()
	# Floor-clear shop only: the shopkeeper's triage — a 50% patch-up for
	# gold. Never a full heal; that's what potions are for.
	if _shop_mode:
		var heal_price := ShopScript.field_heal_price(GameState.depth)
		var hb := Button.new()
		hb.alignment = HORIZONTAL_ALIGNMENT_LEFT
		if _touch_ui:
			hb.custom_minimum_size = Vector2(0, 52)
		hb.text = "Field dressing — restore %d%% HP  [%s G]" % [
			int(ShopScript.FIELD_HEAL_FRAC * 100.0), BigNumbers.format(heal_price)]
		hb.disabled = GameState.gold < heal_price or GameState.hp >= GameState.max_hp
		hb.pressed.connect(_on_shop_buy_heal)
		_shop_items_list.add_child(hb)
	for item in _shop_offerings:
		var item_id := str(item["id"])
		var owned := GameState.charm_count(item_id)
		var price := ShopScript.item_price(item_id, owned)
		var b := Button.new()
		b.alignment = HORIZONTAL_ALIGNMENT_LEFT
		b.text = "%s — %s  [%s G, owned %d]" % [
			str(item["name"]), str(item["desc"]), BigNumbers.format(price), owned]
		if _touch_ui:
			b.custom_minimum_size = Vector2(0, 52)
		b.disabled = GameState.gold < price
		b.pressed.connect(_on_shop_buy_charm.bind(item_id))
		_shop_items_list.add_child(b)
	_shop_reroll_btn.text = "Re-roll offerings [%s G]" % BigNumbers.format(ShopScript.reroll_price(_shop_rerolls))
	_shop_reroll_btn.disabled = GameState.gold < ShopScript.reroll_price(_shop_rerolls)


func _populate_shop_skills() -> void:
	for child in _shop_skills_list.get_children():
		child.queue_free()
	var last_cat := ""
	for s in ShopScript.SKILLS:
		var cat := str(s["cat"])
		if cat != last_cat:
			last_cat = cat
			var h := Label.new()
			h.text = "— %s —" % cat
			h.add_theme_font_size_override("font_size", 15)
			h.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			_shop_skills_list.add_child(h)
		var skill_id := str(s["id"])
		var lvl := GameState.skill_level(skill_id)
		var b := Button.new()
		b.alignment = HORIZONTAL_ALIGNMENT_LEFT
		if _touch_ui:
			b.custom_minimum_size = Vector2(0, 52)
		if not bool(s.get("available", true)):
			b.text = "%s — %s  [coming soon]" % [str(s["name"]), str(s["effect"])]
			b.disabled = true
		else:
			var price := ShopScript.skill_price(skill_id, lvl)
			var lvl_text := "Lv %d" % lvl if lvl > 0 else "LOCKED"
			b.text = "%s (%s) — %s  [%s G]" % [
				str(s["name"]), lvl_text, str(s["effect"]), BigNumbers.format(price)]
			b.disabled = GameState.gold < price
			b.pressed.connect(_on_shop_buy_skill.bind(skill_id))
		_shop_skills_list.add_child(b)


func _on_shop_buy_charm(item_id: String) -> void:
	if GameState.buy_charm(item_id):
		AudioManager.play_sfx("ui_confirm")
		GameState.add_log("Bought %s." % str(ShopScript.item_by_id(item_id)["name"]))
		_refresh_shop_gold()
		_populate_shop_items()


## Depth-shop triage: buy the 50% patch-up with gold. Only offered in the
## floor-clear shop (never the death screen — the dead don't need doctors).
func _on_shop_buy_heal() -> void:
	var price := ShopScript.field_heal_price(GameState.depth)
	if GameState.gold < price or GameState.hp >= GameState.max_hp:
		return
	AudioManager.play_sfx("ui_confirm")
	GameState.gold -= price
	GameState.hp = minf(GameState.max_hp,
		GameState.hp + GameState.max_hp * ShopScript.FIELD_HEAL_FRAC)
	GameState.add_log("Patched up (+%d%% HP, -%s G)."
		% [int(ShopScript.FIELD_HEAL_FRAC * 100.0), BigNumbers.format(price)])
	_refresh_shop_gold()
	_populate_shop_items()
	refresh()


func _on_shop_buy_skill(skill_id: String) -> void:
	if GameState.buy_skill(skill_id):
		AudioManager.play_sfx("ui_confirm")
		var s := ShopScript.skill_by_id(skill_id)
		GameState.add_log("Skill up: %s Lv %d." % [str(s["name"]), GameState.skill_level(skill_id)])
		_refresh_shop_gold()
		_populate_shop_skills()


func _on_shop_reroll() -> void:
	var price := ShopScript.reroll_price(_shop_rerolls)
	if GameState.gold < price:
		return
	AudioManager.play_sfx("ui_confirm")
	GameState.gold -= price
	_shop_rerolls += 1
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	_shop_offerings = ShopScript.roll_offerings(rng, GameState.skill_level("luck"))
	_populate_shop_items()


## Test hook: simulate tapping gear picks on the death screen.
func death_test_pick(weapon: Dictionary, armor: Dictionary) -> void:
	_death_pick_weapon = weapon
	_death_pick_armor = armor


## Test hook: press "Delve Again" programmatically.
func death_test_confirm() -> void:
	_on_death_confirm()


func refresh() -> void:
	_hp_bar.max_value = GameState.max_hp
	_hp_bar.value = GameState.hp
	_hp_label.text = "HP  %s / %s" % [BigNumbers.format(GameState.hp), BigNumbers.format(GameState.max_hp)]
	_xp_bar.max_value = GameState.xp_next
	_xp_bar.value = GameState.xp
	_xp_label.text = "Lv %d XP  %s / %s" % [GameState.level, BigNumbers.format(GameState.xp), BigNumbers.format(GameState.xp_next)]
	_run_label.text = "Run #%d" % GameState.run_number
	_depth_label.text = "Depth: %d" % GameState.depth
	_kills_label.text = "Kills: %s" % BigNumbers.format(float(GameState.run_kills))
	_gold_label.text = "Gold: %s" % BigNumbers.format(GameState.gold)
	# Toggle-mode button shows the "pressed" (green-border) stylebox when ON.
	_idle_button.button_pressed = GameState.idle_mode
	# Gear + potion readouts.
	_gear_weapon_label.text = "Wpn: " + _gear_text(GameState.equipment.get("weapon", {}), "atk")
	_gear_armor_label.text = "Arm: " + _gear_text(GameState.equipment.get("armor", {}), "def")
	_potion_label.text = "Potions: HP×%d MP×%d" % [GameState.health_potions, GameState.mana_potions]
	_drink_button.text = "HP×%d" % GameState.health_potions
	_drink_button.disabled = GameState.health_potions <= 0 \
		or GameState.hp >= GameState.max_hp or not GameState.alive


func _gear_text(item: Dictionary, stat: String) -> String:
	if item.is_empty():
		return "—"
	return "%s +%s" % [str(item["name"]), BigNumbers.format(float(item.get(stat, 0.0)))]


## UI click helper — every button tap makes a sound.
func _click() -> void:
	AudioManager.play_sfx("ui_click")


func _on_drink_pressed() -> void:
	_click()
	# Routed through main: free top-up in idle mode, costs a turn in manual.
	drink_requested.emit()


func add_log(text: String) -> void:
	_log.append_text("[color=#9fb4ff]%s[/color]\n" % text)
	# Trim old lines so the log can't grow forever.
	var lines := _log.get_parsed_text().split("\n")
	if lines.size() > 60:
		var keep := PackedStringArray()
		for i in range(lines.size() - 60, lines.size()):
			keep.append(lines[i])
		_log.text = "[color=#9fb4ff]" + "\n".join(keep) + "[/color]"


func show_death() -> void:
	_shop_mode = false
	_death_title.text = "YOU DIED"
	_death_title.add_theme_color_override("font_color", Color(1.0, 0.3, 0.3))
	_death_stats.text = (
		"Depth reached: %d\nKills this run: %d\nLevel: %d\nGold hoarded: %s\n\nThe dungeon claims another."
		% [GameState.depth, GameState.run_kills, GameState.level, BigNumbers.format(GameState.run_gold)]
	)
	_death_stats.visible = true
	_set_heirlooms_tab_hidden(false)
	_death_again_btn.visible = true
	_shop_close_btn.visible = false
	_populate_death_gear()
	_roll_shop()
	_refresh_shop_gold()
	_populate_shop_items()
	_populate_shop_skills()
	_death_panel.visible = true


## Floor-clear shop (Brotato beat): same offerings/tabs as the death shop,
## minus heirlooms — one tap on "Keep Delving" resumes the crawl.
func show_shop(title: String) -> void:
	_shop_mode = true
	_death_title.text = title
	_death_title.add_theme_color_override("font_color", Color(0.5, 0.9, 1.0))
	_death_stats.visible = false
	_set_heirlooms_tab_hidden(true)
	_death_again_btn.visible = false
	_shop_close_btn.visible = true
	_roll_shop()
	_refresh_shop_gold()
	_populate_shop_items()
	_populate_shop_skills()
	_death_panel.visible = true


func hide_shop() -> void:
	_death_panel.visible = false
	for pair in _shop_scroll_grips:
		(pair[1] as Control).visible = false
	_shop_offerings = []
	_shop_rerolls = 0
	if _shop_mode:
		_shop_mode = false
		shop_closed.emit()


func _on_shop_close() -> void:
	_click()
	hide_shop()


## Shop scrollbar touch fix (v0.12.0): the native bar is ~16px wide on
## touch — too thin to grab reliably. Each shop ScrollContainer gets an
## invisible grip 3x the bar's width, centered on the bar (one bar-width
## on each side), which forwards drags to the bar at thumb ratio. The
## bar's own size and visuals are untouched; wheel events are left
## unhandled so they still reach the ScrollContainer natively.
func _mk_shop_scroll_grip(scroll: ScrollContainer) -> void:
	var grip := Control.new()
	grip.mouse_filter = Control.MOUSE_FILTER_STOP
	grip.visible = false
	add_child(grip)
	grip.gui_input.connect(_on_shop_scroll_grip_input.bind(scroll, grip))
	_shop_scroll_grips.append([scroll, grip])


func _process(_delta: float) -> void:
	if _death_panel == null or not _death_panel.visible:
		for pair in _shop_scroll_grips:
			(pair[1] as Control).visible = false
		return
	for pair in _shop_scroll_grips:
		var scroll := pair[0] as ScrollContainer
		var grip := pair[1] as Control
		if not scroll.is_visible_in_tree():
			grip.visible = false
			continue
		var vbar := scroll.get_v_scroll_bar()
		if vbar == null:
			grip.visible = false
			continue
		var r := vbar.get_global_rect()
		grip.position = Vector2(r.position.x - r.size.x, r.position.y)
		grip.size = Vector2(r.size.x * 3.0, r.size.y)
		grip.visible = true


func _on_shop_scroll_grip_input(scroll: ScrollContainer, grip: Control,
		event: InputEvent) -> void:
	var vbar := scroll.get_v_scroll_bar()
	if vbar == null:
		return
	if event is InputEventScreenDrag:
		grip.set_meta("dragged", true)
		_scroll_grip_drag(scroll, vbar, event.relative.y)
		get_viewport().set_input_as_handled()
	elif event is InputEventMouseMotion \
			and (event.button_mask & MOUSE_BUTTON_MASK_LEFT) != 0:
		grip.set_meta("dragged", true)
		_scroll_grip_drag(scroll, vbar, event.relative.y)
		get_viewport().set_input_as_handled()
	elif event is InputEventScreenTouch and event.pressed:
		grip.set_meta("press_y", event.position.y)
		grip.set_meta("dragged", false)
		get_viewport().set_input_as_handled()
	elif event is InputEventScreenTouch and not event.pressed:
		if not bool(grip.get_meta("dragged", false)):
			_scroll_grip_tap(scroll, vbar, float(grip.get_meta("press_y", 0.0)))
		get_viewport().set_input_as_handled()
	elif event is InputEventMouseButton \
			and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			grip.set_meta("press_y", event.position.y)
			grip.set_meta("dragged", false)
			get_viewport().set_input_as_handled()
		else:
			if not bool(grip.get_meta("dragged", false)):
				_scroll_grip_tap(scroll, vbar, float(grip.get_meta("press_y", 0.0)))
			get_viewport().set_input_as_handled()


## Thumb-ratio drag: moving the grip by dy moves the content as if the
## native thumb had been dragged by dy.
func _scroll_grip_drag(scroll: ScrollContainer, vbar: VScrollBar,
		dy: float) -> void:
	var max_scroll := vbar.max_value - vbar.page
	var track := vbar.size.y
	if max_scroll <= 0.0 or track <= 0.0:
		return
	scroll.scroll_vertical = clampf(
		scroll.scroll_vertical + dy * max_scroll / track, 0.0, max_scroll)


## Tap (press + release without a drag) on the grip: page up/down like a
## native track click, based on whether the tap was above or below the
## thumb. A tap on the thumb itself is a no-op.
func _scroll_grip_tap(scroll: ScrollContainer, vbar: VScrollBar,
		press_y: float) -> void:
	var max_scroll := vbar.max_value - vbar.page
	var track := vbar.size.y
	if max_scroll <= 0.0 or track <= 0.0 or vbar.max_value <= 0.0:
		return
	var thumb := track * vbar.page / vbar.max_value
	var pos := (scroll.scroll_vertical / max_scroll) * (track - thumb)
	if press_y < pos:
		scroll.scroll_vertical = maxf(0.0, scroll.scroll_vertical - vbar.page)
	elif press_y > pos + thumb:
		scroll.scroll_vertical = minf(max_scroll, scroll.scroll_vertical + vbar.page)


func _set_heirlooms_tab_hidden(hidden: bool) -> void:
	for i in _death_tabs.get_tab_count():
		if _death_tabs.get_tab_control(i) == _tabs_heirlooms:
			_death_tabs.set_tab_hidden(i, hidden)
			return


func hide_death() -> void:
	_death_panel.visible = false
	for pair in _shop_scroll_grips:
		(pair[1] as Control).visible = false
	_death_pick_weapon = {}
	_death_pick_armor = {}
	_shop_offerings = []
	_shop_rerolls = 0


## "While You Were Away…" return screen: headline gold counts up on entry,
## then the breakdown. Phone-readable, one panel, one tap back to the delve.
## Depth is HELD while away — descent stays the player's decision.
func _build_offline_panel() -> void:
	_offline_panel = PanelContainer.new()
	_offline_panel.add_theme_stylebox_override("panel", _panel_style())
	_offline_panel.custom_minimum_size = Vector2(460, 0)
	_offline_panel.visible = false
	_center_wrap(_offline_panel)
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	_offline_panel.add_child(vbox)
	_offline_title = Label.new()
	_offline_title.text = "While You Were Away…"
	_offline_title.add_theme_font_size_override("font_size", 28)
	_offline_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(_offline_title)
	_offline_gold = Label.new()
	_offline_gold.add_theme_font_size_override("font_size", 40)
	_offline_gold.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
	_offline_gold.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(_offline_gold)
	_offline_body = Label.new()
	_offline_body.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_offline_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(_offline_body)
	var cont := Button.new()
	cont.text = "Delve on"
	if _touch_ui:
		cont.custom_minimum_size = Vector2(0, 56)
	cont.pressed.connect(func() -> void:
		_click()
		hide_offline_report()
	)
	vbox.add_child(cont)


func show_offline_report(rep: Dictionary) -> void:
	var away_text := str(rep.get("away_text", ""))
	var gold := float(rep.get("gold", 0.0))
	var kpm := float(rep.get("kills_per_min", 0.0))
	var gpk := float(rep.get("gold_per_kill", 0.0))
	var mult := float(rep.get("gold_mult", 1.0))
	var depth := int(rep.get("depth", GameState.depth))
	var secs := int(rep.get("seconds", 0))
	_offline_body.text = (
		"%s away · depth %d held\n"
		% [away_text, depth]
		+ "~%s kills · ~%.1f kills/min · ~%s gold/kill\n"
		% [BigNumbers.format(kpm * secs / 60.0), kpm, BigNumbers.format(gpk)]
		+ "Luck & charm bonus: ×%.2f\n" % mult
		+ "The hero fought safe and lived to tell it."
	)
	_offline_panel.visible = true
	if _offline_tween != null and _offline_tween.is_valid():
		_offline_tween.kill()
	_offline_tween = create_tween()
	_offline_tween.tween_method(_set_offline_gold_text, 0.0, gold, 1.0)


func _set_offline_gold_text(v: float) -> void:
	_offline_gold.text = "+%s G" % BigNumbers.format(v)


func hide_offline_report() -> void:
	if _offline_tween != null and _offline_tween.is_valid():
		_offline_tween.kill()
	_offline_panel.visible = false


func _on_idle_toggled() -> void:
	_click()
	GameState.idle_mode = _idle_button.button_pressed
	GameState.add_log("Idle mode " + ("ON — auto-explore engaged." if GameState.idle_mode else "OFF — manual control."))
	refresh()


func _on_stub_pressed(tab_name: String) -> void:
	_click()
	_stub_title.text = tab_name
	_stub_body.text = str(STUB_TEXT[tab_name])
	_stub_panel.visible = true


func _on_life_tree_pressed() -> void:
	_click()
	life_tree_requested.emit()
