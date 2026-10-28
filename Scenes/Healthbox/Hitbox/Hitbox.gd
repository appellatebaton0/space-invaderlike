class_name Hitbox extends Healthbox

## Emitted when this hitbox collides with a hurtbox.
@warning_ignore("unused_signal")
signal hit

## The hitboxes also manage damage done, at least for now.
@export var damage := 1

## Whether this does constant damage instead of entrance damage.
@export var constant_damage := false

func _ready() -> void:
	area_entered.connect(_on_area_entered)

func _process(_delta: float) -> void:
	if not constant_damage: return
	
	for area in get_overlapping_areas():
		_try_damage(area)

func _on_area_entered(area:Area2D):
	if constant_damage: return
	
	_try_damage(area)

func _try_damage(area:Area2D):
	if area is Hurtbox:
		
		# Class masking.
		if class_mask:
			if not is_instance_of(area.get_user(), class_mask): return 
		
		area._took_damage(damage)
		
		hit.emit()
		_on_hit()

func _on_hit() -> void: pass
