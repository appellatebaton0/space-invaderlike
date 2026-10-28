@tool
class_name SlapControl extends Control
## A control that appears to slap itself down onto the UI on command.

@export_tool_button("Test Slap") var ts := slap_down

var tween:Tween

func _ready() -> void:
	offset_transform_enabled = true
	
	if Engine.is_editor_hint(): return
	
	self_modulate.a = 0.0

func slap_down():
	
	if tween and tween.is_running(): tween.kill()
	tween = create_tween().set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_IN)
	
	self_modulate.a = 0.0
	offset_transform_scale = Vector2.ONE * 1.9
	
	tween.tween_property(self, "offset_transform_scale", Vector2.ONE * 0.95, 0.4)
	tween.parallel().tween_property(self, "self_modulate:a", 1.0, 0.5)
	tween.set_ease(Tween.EASE_OUT_IN)
	
	tween.tween_property(self, "offset_transform_scale", Vector2.ONE, 0.1)
