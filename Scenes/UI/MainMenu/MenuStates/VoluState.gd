class_name VoluState extends MenuState

var bus:int
var increment:float

func get_text() -> String:
	return text % [int(AudioServer.get_bus_volume_linear(bus) / abs(increment))]

func _init(set_level:int, set_text:String, set_transitions:Dictionary[int, int], set_bus:StringName, set_increment:float):
	super(set_level, set_text, set_transitions)
	
	bus = AudioServer.get_bus_index(set_bus)
	increment = set_increment

func on_input(direction:int) -> void:
	
	if direction != 3: return ## 3 = Right, our 'Enter'.
	
	
	
	AudioServer.set_bus_volume_linear(bus, clamp(AudioServer.get_bus_volume_linear(bus) + increment, 0.0, 1.5))
