class_name Beam extends Hitbox

signal finished

@export var duration := 1.0

@onready var collision_shape := $CollisionShape2D

static func make_beam(set_pos:Vector2, set_duration := 1.0, set_class_mask = null) -> Beam:

	var new:Beam = preload("res://Scenes/Beam/Beam.tscn").instantiate()
	
	new.class_mask = set_class_mask
	new.position   = set_pos
	new.duration   = set_duration
	
	return new

func _process(delta: float) -> void:
	super(delta)
	duration = move_toward(duration, 0.0, delta)
	
	scale.y = move_toward(scale.y, 1.0, delta * 4)
	
	if duration < 0.5:
		modulate.a = pow((duration * 2.0), 2.0)
	
	## Leniency, so the player can touch beams when they're still a bit visible.
	collision_shape.disabled = modulate.a < 0.3
	
	if duration <= 0 and not is_queued_for_deletion():
		finished.emit()
		queue_free()
