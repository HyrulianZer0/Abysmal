class_name TouchControls
extends CanvasLayer
## Virtual D-pad for touch devices: grid-step movement + 90° turning.
##
## Each button emits pad_action, which main.gd routes through the exact same
## action pipeline as the keyboard (_handle_action) — so touch and keyboard
## stay in lock-step in both idle and manual modes.
## (Previously this fired Input.action_press()/release(), which only sets
## action *state* and never dispatches an InputEvent — main.gd reads input
## via _unhandled_input, so every tap vanished. That was the v0.4.0 D-pad bug.)
## Tap = one step/turn; hold = repeat (timer re-fires the press edge).
## The whole layer hides itself on devices without a touchscreen.

signal pad_action(action: StringName)

const BTN := 76.0
const REPEAT_INTERVAL := 0.24

# action name -> button glyph
const LAYOUT: Array = [
	["turn_left", "↺"], ["move_forward", "▲"], ["turn_right", "↻"],
	["strafe_left", "◀"], ["move_back", "▼"], ["strafe_right", "▶"],
]

var _repeat_timer: Timer
var _held_action: StringName = &""
var _pad: GridContainer


func _ready() -> void:
	layer = 20
	visible = DisplayServer.is_touchscreen_available()
	if not visible:
		return
	_repeat_timer = Timer.new()
	_repeat_timer.wait_time = REPEAT_INTERVAL
	_repeat_timer.timeout.connect(_on_repeat)
	add_child(_repeat_timer)
	_build_pad()
	if GameState.stats_changed.connect(_on_stats_changed) != OK:
		pass
	_on_stats_changed()


func _build_pad() -> void:
	_pad = GridContainer.new()
	_pad.columns = 3
	_pad.add_theme_constant_override("h_separation", 8)
	_pad.add_theme_constant_override("v_separation", 8)
	_pad.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	_pad.position = Vector2(16, -(BTN * 2.0 + 8.0 + 16.0))
	add_child(_pad)
	for spec in LAYOUT:
		var b := Button.new()
		b.text = str(spec[1])
		b.custom_minimum_size = Vector2(BTN, BTN)
		b.add_theme_font_size_override("font_size", 30)
		b.focus_mode = Control.FOCUS_NONE
		b.mouse_filter = Control.MOUSE_FILTER_STOP
		b.button_down.connect(_on_pad_down.bind(StringName(str(spec[0]))))
		b.button_up.connect(_on_pad_up)
		_pad.add_child(b)


func _on_pad_down(action: StringName) -> void:
	_held_action = action
	_fire()
	_repeat_timer.start()


func _on_pad_up() -> void:
	_held_action = &""
	_repeat_timer.stop()


func _on_repeat() -> void:
	if _held_action != &"":
		_fire()


func _fire() -> void:
	# One discrete action edge per fire: tap = one step, hold = repeat.
	# Emitted as a signal — main.gd handles it like a keyboard press.
	pad_action.emit(_held_action)


func _on_stats_changed() -> void:
	# Dim the pad while idle mode owns movement (taps are ignored then).
	if _pad:
		_pad.modulate.a = 0.35 if GameState.idle_mode else 1.0
