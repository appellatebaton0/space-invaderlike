extends Node
## Allows for registering SFX to a signal action, by class.

## All the AudioStreamPlayers in here.
var players:Array[AudioStreamPlayer]

## Get an available player.
func get_player() -> AudioStreamPlayer:
	for player:AudioStreamPlayer in players:
		if not player.playing: return player
	
	var new := AudioStreamPlayer.new()
	
	new.bus = &"SFX"
	
	add_child(new)
	
	players.append(new)
	
	return new

const SOUNDBANK:Dictionary[String, AudioStream] = {
	"pressed": preload("res://Assets/SFX/UISelect.wav"),
}

## AutoAssigns & Registering

func _ready() -> void: get_tree().scene_changed.connect(_on_scene_changed)

func _on_scene_changed(): auto_register(get_tree().current_scene)

class AutoAssign extends Resource:
	var type
	var bank_id:String
	var signal_name:String
	
	func _init(set_type, set_signal_name:String, set_bank_id:String) -> void:
		type        = set_type
		bank_id     = set_bank_id
		signal_name = set_signal_name
	
	
	
	func try(node:Node) -> bool:
		return is_instance_of(node, type) and node.has_signal(signal_name)

var auto_assignments:Array[AutoAssign] = [
	
	## Buttons
	AutoAssign.new(BaseButton, "pressed", "pressed"),
	
]

func auto_register(parent:Node, recur := true) -> void:
	
	for auto_assign in auto_assignments:
		if auto_assign.try(parent):
			register_single(parent, auto_assign.signal_name, auto_assign.bank_id)
	
	if not recur: return
	
	for child in parent.get_children():
		auto_register(child)

func register_single(node:Node, signal_name:String, bank_id:String):
	node.connect(signal_name, play_bank.bind(bank_id))

## Playing sound.

func play_bank(id:String): 
	play_sound(SOUNDBANK[id])
func play_sound(sound:AudioStream):
	
	var player := get_player()
	
	player.stream = sound
	
	player.play()
