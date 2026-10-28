@abstract class_name Healthbox extends Area2D
## A base class for hurtboxes and healthboxes. Affect or store health in some way. 

@export var user:Node
func get_user() -> Node:
	if not user: return get_parent()
	return user

var class_mask # Used to mask damage taken/given.
