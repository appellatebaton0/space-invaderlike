class_name Commander extends Node2D
## Provides the information needed for a group of enemies to move together.

## Create a new commander with a set of enemies, and automatically arrange those enemies.
func _init(enemies:Array[Enemy], width := 6, position := Vector2.ZERO) -> void:
	
	# hmm... we ideally want to have enemies with the same speed in the same row,
	# and support for enemies with different sizing...
	
	# I'm... gonna dump both to keep this as simple as possible. Just make a grid of the given size
	# with all the enemies in it.
	
	const ENEMY_SIZE := 24.0
	const MARGIN := 4.0
	const SPACING := ENEMY_SIZE + MARGIN
	
	var place_position := Vector2.ZERO
	var i = 0
	
	for enemy in enemies:
		add_child(enemy)
		
		enemy.global_position = place_position + position
		i+=1
		place_position.x += SPACING
		if i >= width:
			place_position.x = 0
			place_position.y += SPACING
			i = 0

var _direction:int = 1 :get = get_direction

@export var descent_time := 0.2
var descent_timer := 0.0

func _physics_process(delta: float) -> void:
	var enemies := get_enemies()
	if enemies.size() == 0: return
	
	var dir := _direction # Don't allow the direction to change in the middle of moving some of the enemies.
	for enemy in enemies:
		enemy.move(dir, delta)
		
		if descent_timer > 0.0:
			enemy.descend(delta)
		
		if enemy.position.y > 240:
			GameManager.request_game_over()
	descent_timer = move_toward(descent_timer, 0.0, delta)

## Get the enemies under this commander's command.
func get_enemies() -> Array[Enemy]:
	var response:Array[Enemy]
	for child in get_children():
		if child is Enemy: response.append(child)
	return response

## Get the direction that enemies should move.
func get_direction() -> int:
	var bound = Enemy.get_enemy_bounds(get_enemies())
	
	if bound.position.x < 0:
		if _direction !=  1: descent_timer = descent_time
		_direction = 1
	
	if bound.position.x + bound.size.x > 388:
		if _direction != -1: descent_timer = descent_time
		_direction = -1
	
	if bound.position.y > 284:
		GameManager.request_game_over()
	
	return _direction
