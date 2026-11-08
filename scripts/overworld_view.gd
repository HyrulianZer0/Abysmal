class_name OverworldView
extends Node
## Overworld stub state — Phase 3 scaffolding.
##
## A stub state only: a placeholder panel proving the OVERWORLD state is
## reachable and returnable (town <-> overworld). There is no map, no
## movement, no content yet — the overworld grows here in a later phase.

## TODO_JAMES: OVERWORLD MAP SIZE IS UNDECIDED.
## James has not chosen an overworld map size, so this constant is an
## explicit placeholder (0 = no size chosen) — NOT a design pick. Do not
## build anything that assumes an overworld size, and do not "fill in" a
## value here, until he decides.
const OVERWORLD_MAP_SIZE := 0  # 0 = undecided; no size chosen

signal return_requested

var return_button: Button


func _ready() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	var bg := ColorRect.new()
	bg.color = Color(0.05, 0.08, 0.16)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	layer.add_child(bg)

	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_top", 120)
	layer.add_child(margin)
	var vbox := VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_BEGIN
	vbox.add_theme_constant_override("separation", 10)
	margin.add_child(vbox)

	var title := Label.new()
	title.text = "OVERWORLD — stub state (Phase 3)"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 30)
	title.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	vbox.add_child(title)

	var body := Label.new()
	body.text = "Map size: UNDECIDED — awaiting James's decision (TODO_JAMES).\nNo map, no movement, no content yet — the overworld grows here."
	body.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	body.add_theme_font_size_override("font_size", 16)
	body.modulate = Color(1, 1, 1, 0.75)
	body.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	vbox.add_child(body)

	return_button = Button.new()
	return_button.text = "Return to town"
	return_button.custom_minimum_size = Vector2(280, 48)
	return_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	return_button.pressed.connect(func() -> void: return_requested.emit())
	vbox.add_child(return_button)
