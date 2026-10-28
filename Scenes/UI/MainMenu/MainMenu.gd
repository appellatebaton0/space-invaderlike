class_name MainMenu extends Control
## The main menu for the game.

static var has_booted := false

@export var initial_state:int = 0
var current_state:MenuState

## Def a better way to do this, but I'm lazy & want to try something new.
@onready var menu_states:Array[MenuState] = [
	## Main menu
	MenuState.new(0, "----\n\nNEBULOUS (-> START)  \n\n----\n\n>START\n\nOPTIONS \n\nQUIT \n\n---", {0:2, 1:1, 3:3}),
	MenuState.new(0, "----\n\nNEBULOUS (-> OPTIONS)\n\n----\n\nSTART \n\n>OPTIONS\n\nQUIT \n\n---", {0:0, 1:2, 3:6}),
	QuitState.new(0, "----\n\nNEBULOUS (-> QUIT)   \n\n----\n\nSTART \n\nOPTIONS \n\n>QUIT\n\n---", {0:1, 1:0}, self),
	
	## Start submenu
	ModeState.new(1, "----\n\nSTART (-> NORMAL) \n\n----\n\n>NORMAL\n\nENDLESS \n\nIRONMAN \n\n---\n<- BACK", {0:5, 1:4, 2:0}, 0),
	ModeState.new(1, "----\n\nSTART (-> ENDLESS)\n\n----\n\nNORMAL \n\n>ENDLESS\n\nIRONMAN \n\n---\n<- BACK", {0:3, 1:5, 2:0}, 1),
	ModeState.new(1, "----\n\nSTART (-> IRONMAN)\n\n----\n\nNORMAL \n\nENDLESS \n\n>IRONMAN\n\n---\n<- BACK", {0:4, 1:3, 2:0}, 2),
	
	## Options submenu (Volume controls.
	VoluState.new(1, "----\n\nOPTIONS (-> VOL UP)  \n\n----\n\n- VOLUME: %s -\n\n>VOL UP\n\nVOL DOWN \n\n---\n<- BACK", {0:7, 1:7, 2:1}, &"Master", 0.1),
	VoluState.new(1, "----\n\nOPTIONS (-> VOL DOWN)\n\n----\n\n- VOLUME: %s -\n\nVOL UP \n\n>VOL DOWN\n\n---\n<- BACK", {0:6, 1:6, 2:1}, &"Master", -0.1),
]

@onready var display:Label = $Display

@onready var anim_player:AnimationPlayer = $AnimationPlayer

@onready var buttons:Dictionary[int, TextureButton] = {
	0: $UpButton,
	1: $DownButton,
	2: $LeftButton,
	3: $RightButton
}

var tween:Tween
func reset_tween() -> Tween:
	if tween and tween.is_running(): tween.kill()
	tween = create_tween()
	return tween

func _ready() -> void:
	GameManager.set_visibility(false)
	SfxRegister.auto_register(self)
	
	current_state = menu_states[initial_state]
	
	for direction in buttons:
		var button := buttons[direction]
		
		button.pressed.connect(_input_direction.bind(direction))
	
	if not has_booted:
		anim_player.play("BOOT")
		has_booted = true
	
	if anim_player.is_playing():
		await anim_player.animation_finished
	
	tween_transition(current_state.get_text(), 0.3, true)


func _on_start_pressed() -> void:
	await Transitioner.request_transition(1.0, "res://Scenes/Levels/Level01/Level01.tscn", true)

func _on_quit_pressed() -> void: get_tree().quit()

func _process(_delta: float) -> void:
	
	var dir := -1
	
	if   Input.is_action_pressed("Shoot"): dir = 0
	elif Input.is_action_pressed("Dash"):  dir = 1
	elif Input.is_action_pressed("Left"):  dir = 2
	elif Input.is_action_pressed("Right"): dir = 3
	
	for direction in buttons:
		var button := buttons[direction]
		
		button.disabled = dir == direction 
	
	
	if dir == -1: return
	
	var can_continue := false
	for input in ["Shoot", "Dash", "Left", "Right"]:
		if Input.is_action_just_pressed(input):
			can_continue = true
			
			var sound_file:String
			match dir:
				3: sound_file = "res://Assets/SFX/UISelect.wav"
				2: sound_file = "res://Assets/SFX/UIBack.wav"
				_: sound_file = "res://Assets/SFX/UIMove.wav"
			
			SfxRegister.play_sound(load(sound_file))
		
			break
	
	if not can_continue: return
	
	_input_direction(dir)

func _input_direction(dir:int):
	
	if Transitioner.is_transitioning(): return

	if anim_player.is_playing():
		anim_player.stop()
		display.visible_ratio = 0.0
		tween_transition(current_state.get_text(), 0.3, true)

	if not current_state: return
	
	var new_state := current_state.try_transition(dir)
	
	
	if new_state == -1: 
		state_transition(menu_states.find(current_state))
		return
	
	state_transition(new_state)

func state_transition(to:int):
	
	## No starting a new motion mid-animation. Doofus.
	if anim_player.is_playing() or Transitioner.is_transitioning(): return
	
	var new_state := menu_states[to]
	
	## Takes longer if the level is different.
	tween_transition(new_state.get_text(), 0.3 if current_state.level != new_state.level else 0.1)
	
	current_state = new_state
	
	for direction in buttons:
		var button := buttons[direction]
		
		button.disabled = false

func tween_transition(new_text:String, trans_times := 0.3, no_in := false):
	reset_tween()
	if not no_in:
		tween.tween_property(display, "visible_ratio", 0.0, trans_times)
	tween.tween_callback(func(): display.text = new_text)
	tween.tween_property(display, "visible_ratio", 1.0, trans_times)
