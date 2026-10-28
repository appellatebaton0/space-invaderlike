class_name PistolEnemy extends BasicEnemy

static func make_new() -> PistolEnemy: return preload("res://Scenes/Enemies/PistolEnemy/PistolEnemy.tscn").instantiate()

@export var shoot_frequency_range := Vector2(1.5, 2.0)
var shoot_timer:SceneTreeTimer

var bullet_components:Array[BulletComponent]

func _ready() -> void:
	super()
	await get_tree().create_timer(randf() * 3.0).timeout
	restart_cooldown()

func hit_points() -> int: return 2
func death_points() -> int: return 12 # Scores both hit and death, so 14.

static func weight(diff:float) -> float: return (1.1 * diff) - 0.33

func _process(_delta: float) -> void:
	super(_delta)
	modulate = Color.WHITE
	if shoot_timer and shoot_timer.time_left > 0 and shoot_timer.time_left < 0.3:
		modulate = Color.WHITE * (3.2 * (int(shoot_timer.time_left * 20) % 2))

func restart_cooldown():
	
	shoot_timer = get_tree().create_timer(
		randf_range(shoot_frequency_range.x, shoot_frequency_range.y), false
	)
	
	if not shoot_timer.timeout.is_connected(shoot):
		shoot_timer.timeout.connect(shoot)

func shoot() -> void:
	get_tree().current_scene.add_child(
		Bullet.make_bullet(bullet_components, Vector2.DOWN, position + (Vector2.DOWN * 25), Player)
	)
	
	restart_cooldown()

func _to_string() -> String: return "P"
