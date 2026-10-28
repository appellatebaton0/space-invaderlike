extends CanvasLayer

@onready var pause_progress_bar:ProgressBar = $VBoxContainer/Label2/ProgressBar

var _paused:bool = false

func _ready() -> void:
	hide()

func _process(delta: float) -> void:
	
	if not get_tree().current_scene is Level:
		
		if _paused: toggle_paused()
		else: pause_progress_bar.value = 0.0
		
		return
	
	if Transitioner.is_transitioning(): return
	
	if Input.is_action_just_released("Pause"):
		toggle_paused()
	
	if not _paused: return
	
	pause_progress_bar.value = move_toward(pause_progress_bar.value, 1.0 if Input.is_action_pressed("Pause") else 0.0, delta)
	
	if pause_progress_bar.value >= 1.0:
		GameManager.request_game_over()

func toggle_paused() -> void:
	_paused = !_paused
	
	if _paused: # Is now paused.
		
		get_tree().paused = true
		
		show()
		
	else:
		get_tree().paused = false
		
		hide()
