class_name Bullet extends Hitbox
## A boolet.

static func make_bullet(args:Array, set_direction:Vector2, set_pos:Vector2, set_class_mask = null, set_damage := 1) -> Bullet:

	
	var new:Bullet = preload("res://Scenes/Bullet/Bullet.tscn").instantiate()
	
	for component in args:
		if component is BulletComponent:
			new._register_component(component)
		else:
			new._register_component(component.new())
	
	new.direction  = set_direction
	new.class_mask = set_class_mask
	new.position   = set_pos
	new.damage     = set_damage
	
	
	return new

@export var _speed := 180.0
@export var direction := Vector2.DOWN

var components:Array[BulletComponent]

func _physics_process(delta: float) -> void:

	
	global_position += direction * _speed * delta
	
	if (global_position.y < -20.0 or global_position.y > 400 
	 or global_position.x < -20.0 or global_position.x > 400):
		queue_free()

func _on_hit() -> void: queue_free()

func _register_component(component:BulletComponent):
	
	components.append(component)
	
	add_child(component)
