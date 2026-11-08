class_name DamagePopup
extends Label3D
## Floating damage number: rises, fades, frees itself. Headless-safe.


func setup(text: String, color: Color) -> void:
	self.text = text
	font_size = 64
	pixel_size = 0.005
	billboard = BaseMaterial3D.BILLBOARD_ENABLED
	modulate = color
	outline_size = 12
	outline_modulate = Color(0, 0, 0, 0.9)
	# Spawn slightly above the target and drift up while fading.
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "position:y", position.y + 0.9, 0.8).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(self, "modulate:a", 0.0, 0.8).set_delay(0.15)
	tween.chain().tween_callback(queue_free)
