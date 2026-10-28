class_name ModeState extends MenuState

var mode:int

func _init(set_level:int, set_text:String, set_transitions:Dictionary[int, int], set_mode:int):
	super(set_level, set_text, set_transitions)
	mode = set_mode

func on_input(direction:int) -> void:
	
	if direction != 3: return ## 3 = Right, our 'Enter'.
	
	GameManager.start_game(mode)
