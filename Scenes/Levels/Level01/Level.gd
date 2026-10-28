@tool
class_name Level extends Node
## Manages the Commanders for a wave, and communicates w/ the GameManager to 
## keep waves and rounds going.


@export var test_diff := 0.0
@export var repeat := 5
@export_tool_button("try weight") var try := func():
	
	for j in range(test_diff):
		var this_diff := j / 10.0
	
		var averages:Dictionary[String, int]
		
		for i in repeat:
			var attempt := get_new_enemies(this_diff, get_enemy_count(this_diff))
			var results:Dictionary[String, int]
			
			for enemy in attempt:
				if not results.has(str(enemy)):
					results[str(enemy)] = 1
					continue
				results[str(enemy)] += 1
			
			results.sort()
			
			for result in results:
				if not averages.has(result):
					averages[result] = results[result]
				else:
					averages[result] += results[result]
			
			#print(attempt, ": ", results)
		
		var sum := 0
		for option in averages:
			averages[option] /= repeat
			sum += averages[option]
		
		#print("DIFF: ", this_diff, "\tCOUNT: ", sum, "\tAVG: ",averages)
	
	pass

@onready var scroll := $Parallax2D
@onready var canvas_group:CanvasGroup = $CanvasGroup
@onready var transition_material:ShaderMaterial = canvas_group.material
var transition_tween:Tween
func reset_tween() -> Tween:
	if transition_tween and transition_tween.is_running():
		transition_tween.kill()
	transition_tween = create_tween()
	return transition_tween

## All the spawnable enemies.
var spawnable_enemies:Array = [
	PistolEnemy, BasicEnemy, BeamEnemy, TankEnemy
]

func _ready() -> void:
	GameManager.starting_wave.connect(_start_wave)
	
	scroll.autoscroll.y = GameManager.get_scroll_speed()
	
func _start_wave(difficulty:float) -> void:
	
	transition_material.set_shader_parameter("threshold", 0.0)
	
	var tween := create_tween().tween_method(func(a): $CanvasLayer.visible = int(a * 3) % 2 == 0, 0.0, 1.99, 2.0)
	
	if GameManager.waves_remaining + 1 != GameManager.WAVES_PER_ROUND:
		SfxRegister.play_sound(preload("res://Assets/SFX/WaveComplete.wav"))
	
	var waves_remaining := GameManager.waves_remaining + 1
	
	$CanvasLayer/Label.text = (str(waves_remaining) + " WAVES REMAINING") if waves_remaining > 1 else ("FINAL WAVE")
	
	await tween.finished
	$CanvasLayer.hide()
	
	var commander := Commander.new(get_new_enemies(difficulty, get_enemy_count(difficulty)), [5,5,5,6,6,6,6,6,6,7,7,8].pick_random(), Vector2(30, 40))
	
	canvas_group.add_child(commander)
	wipe_transition()

## Determines how many enemies to spawn for a given difficulty.
const BASELINE  := 6. # The base number of enemies.
const VARIANCE  := 4. # The amount more than the current base there can be.
const FREQUENCY := 3. # How many times the number goes from BASELINE to BASELINE + VARIANCE in one COUNT.
const COUNT     := 0.5 # The baseline rises STEP * floor(difficulty / COUNT).
const STEP      := 1.5 # How much the baseline rises every COUNT.
func get_enemy_count(x:float) -> int:
	
	# The additive term for variance, as defined by VARIANCE and FREQUENCY.
	# (FREQUENCY is defined in terms of COUNT).
	var _variance := VARIANCE * fmod(x * FREQUENCY / COUNT, 1.0)
	# The additive term for rise, as defined by COUNT and STEP.
	var _rise := STEP * floorf(x / COUNT)
	
	var total := BASELINE + _variance + _rise
	
	# Turn any floating point into a chance to add one. Eg, 0.3 is 0 with a 30% chance to be 1.
	var floating_point := total - floorf(total)
	total = floorf(total)
	
	if not floating_point == 0:
		if randf() <= floating_point:
			total += 1
	
	return mini(int(total), 30)

## Get a new set of [count] enemies, using a difficulty value to control the distribution.
func get_new_enemies(diff:float, count := 1) -> Array[Enemy]:
	
	var weights:Dictionary[Variant, float]
	
	for option in spawnable_enemies:
		weights[option] = max(option.weight(diff), 0)
	
	var high := 0.0
	
	for weight in weights.values():
		high += weight
	
	var response:Array[Enemy]
	
	for i in count:
		
		var value := randf() * high
		
		var local_high := 0.0
		
		for option in weights:
			var weight := weights[option]
			#print("trying ", value, " against ", local_high, " - ", local_high + weight)
			if value >= local_high and value <= weight + local_high:
				response.append( option.make_new() )
				break
			local_high += weight
	
	return response

func wipe_transition() -> void:
	reset_tween().tween_method(func(a): transition_material.set_shader_parameter("threshold", a), 0.0, 1.0, 0.6)
	
	
	
	
