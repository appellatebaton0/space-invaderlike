class_name MenuState extends Resource

@export var level := 0
@export_multiline() var text := ""        

func get_text() -> String: return text

@export var transitions:Dictionary[int, int]

func _init(set_level:int, set_text:String, set_transitions:Dictionary[int, int]):
	level = set_level
	text = set_text
	transitions = set_transitions

func try_transition(direction:int) -> int:
	
	on_input(direction)
	
	if not transitions.has(direction):
		return -1
	
	return transitions[direction]

func on_input(_direction:int) -> void: pass
