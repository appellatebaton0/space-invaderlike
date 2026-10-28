class_name GameOver extends Control

static var _was_win := false

## Define all the controls.

@onready var title := $MarginContainer/VBoxContainer/Title

@onready var score := $MarginContainer/VBoxContainer/Score
@onready var highscore := $MarginContainer/VBoxContainer/Highscore
@onready var new_highscore := $MarginContainer/VBoxContainer/NewHighscore

@onready var depth := $MarginContainer/VBoxContainer/Depth
@onready var highdepth := $MarginContainer/VBoxContainer/Highdepth
@onready var new_highdepth := $MarginContainer/VBoxContainer/NewHighdepth

@onready var button := $MarginContainer/VBoxContainer/Button

@onready var control_set = [score, highscore, new_highscore, depth, highdepth, new_highdepth, button]

var tween:Tween

func _ready() -> void:
	button.pressed.connect(func(): Transitioner.request_transition(2.0, "res://Scenes/UI/MainMenu/MainMenu.tscn", false))
	
	title.text = "MISSION COMPLETE" if _was_win else "MISSION FAILED"
	
	await get_tree().create_timer(1.8).timeout # Wait a bit to let the transition into the scene finish.
	
	animate()
	
	SfxRegister.auto_register(self)

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("Right") and not (tween and tween.is_running()):
		Transitioner.request_transition(2.0, "res://Scenes/UI/MainMenu/MainMenu.tscn", false)

func animate() -> void:
	
	if tween and tween.is_running(): tween.kill()
	tween = create_tween()
	
	for control:SlapControl in control_set:
		
		match control:
			new_highdepth:
				tween.tween_interval(0.8)
				if GameManager._got_new_depth:
					tween.tween_callback(control.slap_down)
					tween.tween_interval(0.8)
			new_highscore:
				tween.tween_interval(0.8)
				if GameManager._got_new_score:
					tween.tween_callback(control.slap_down)
					tween.tween_interval(0.8)
			_:
				tween.tween_callback(control.slap_down)
				tween.tween_interval(0.4)
				
				control.set("text", get_text_for(control))

func get_text_for(node:Control):
	
	match node:
		score: return "SCORE: " + GameManager.digitize(GameManager.get_score(),6)
		highscore: return "HIGHSCORE: " + GameManager.digitize(GameManager.get_highscore(),6)
		depth: return "DEPTH: " + GameManager.digitize(GameManager.get_depth(),3)
		highdepth: return "BEST DEPTH: " + GameManager.digitize(GameManager.get_highdepth(), 3)
		_: return node.get("text")
