class_name QuitState extends MenuState

var ref:Node

func _init(set_level:int, set_text:String, set_transitions:Dictionary[int, int], set_ref:Node):
	super._init(set_level, set_text, set_transitions)
	
	ref = set_ref

func on_input(direction:int) -> void:
	
	if direction != 3: return ## 3 = Right, our 'Enter'.
	
	ref.get_tree().quit()
