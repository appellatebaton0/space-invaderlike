class_name TankEnemy extends BasicEnemy

static func make_new() -> TankEnemy: return preload("res://Scenes/Enemies/TankEnemy/TankEnemy.tscn").instantiate()

func hit_points() -> int: return 3
func death_points() -> int: return 14 # Scores both hit and death, so 10.

static func weight(diff:float) -> float: return 1.3 * (diff - 1.8)
