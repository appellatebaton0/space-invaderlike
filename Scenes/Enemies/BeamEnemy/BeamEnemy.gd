class_name BeamEnemy extends PistolEnemy

@onready var sprite := $AnimatedSprite2D

static func make_new() -> BeamEnemy: return preload("res://Scenes/Enemies/BeamEnemy/BeamEnemy.tscn").instantiate()

func hit_points() -> int: return randi_range(2,3)
func death_points() -> int: return 12

static func weight(diff:float) -> float: return 1.5 * (diff - 2.1)

func _to_string() -> String: return "E"

@export var beam_duration_range := Vector2(2.0, 3.0)

func shoot() -> void:
	var duration := randf_range(beam_duration_range.x, beam_duration_range.y)
	
	var current_beam := Beam.make_beam(Vector2.ZERO, duration, Player)
	
	add_child(current_beam)
	
	current_beam.show_behind_parent = true
	
	sprite.play("attack")
	
	current_beam.finished.connect(restart_cooldown)
	

func restart_cooldown():
	sprite.play("default")
	super()
