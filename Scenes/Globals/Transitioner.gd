extends CanvasLayer

@onready var overlay := $TransitionOverlay
var overlay_material:ShaderMaterial

@onready var label := $Label

var transition_tween:Tween

var _transitioning:bool = false

func _ready() -> void:
	overlay_material = overlay.material

func recreate_tween() -> Tween:
	if transition_tween and transition_tween.is_running(): transition_tween.kill()
	transition_tween = create_tween()
	
	return transition_tween

func is_transitioning() -> bool:
	return _transitioning


## Transition in and out in the requested time, as a coroutine that returns when it's fully transitioned in.
func request_transition(time:float, path:String, show_score_after:bool = GameManager.visible, text := "", sound:AudioStream = null) -> void:
	if transition_tween and transition_tween.is_running(): return
	
	_transitioning = true
	
	var wait_time := minf(0.4, time / 3.0)
	
	recreate_tween().tween_method(set_overlay_threshold, 0.0, 1.0, (time - wait_time) / 2.0)
	await transition_tween.finished
	
	get_tree().change_scene_to_file(path)
	
	label.text = text
	label.show()
	
	if sound:
		SfxRegister.play_sound(sound)
	
	await get_tree().create_timer(time / 3.0).timeout
	label.hide()
	
	GameManager.set_visibility(show_score_after)
	recreate_tween().tween_method(set_overlay_threshold, 1.0, 0.0, (time - wait_time) / 2.0)
	
	transition_tween.finished.connect(func(): _transitioning = false)


func set_overlay_threshold(to:float):
	overlay_material.set_shader_parameter("threshold", to)
