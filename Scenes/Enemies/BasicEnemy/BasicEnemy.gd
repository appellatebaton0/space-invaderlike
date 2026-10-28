class_name BasicEnemy extends Enemy

static func make_new() -> BasicEnemy: return preload("res://Scenes/Enemies/BasicEnemy/BasicEnemy.tscn").instantiate()

@export var speed := 40.0

func move(direction:int, delta:float):
	position.x += direction * (speed + 0.2 * position.y) * delta

func descend(delta:float):
	position.y += delta * speed * 2

func hit_points() -> int: return 2
func death_points() -> int: return 8 # Scores both hit and death, so 10.

static func weight(diff:float) -> float: return diff + 0.1

func _to_string() -> String: return "B"
