class_name Hurtbox extends Healthbox
## The hurtbox for any given thing.

signal took_damage
signal died

## Also manages the health for an object.
@export var max_health := 4:
	set(to):
		health = min(health, to)
		max_health = to
var health := 0

## *Also* manage invincibility time.
@export var invincibility_time = 0.0
var invincibility_timer := 0.0

func _ready() -> void:
	health = max_health

func _process(delta: float) -> void:
	invincibility_timer = move_toward(invincibility_timer, 0.0, delta)

func _took_damage(x:int) -> void: 
	
	# Stop, stop, he's already dead!
	if health <= 0: return
	
	# Can't touch this.
	if invincibility_timer > 0: return
	
	health = max(health - x, 0)
	
	invincibility_timer = invincibility_time
	
	took_damage.emit()
	
	if health == 0:
		
		for shape in get_collision_shapes():
			shape.disabled = true
		
		died.emit()

func get_collision_shapes() -> Array[CollisionShape2D]:
	var response:Array[CollisionShape2D]
	
	for child in get_children(): if child is CollisionShape2D:
		response.append(child)
	
	return response
