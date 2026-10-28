@abstract class_name Enemy extends CharacterBody2D

static var _enemies:Array[Enemy] # All the enemies in memory.
static func register_enemy(enemy:Enemy):
	_enemies.append(enemy)
	GameManager.enemy_count_changed.emit()
	_fix_enemies()
static func deregister_enemy(enemy:Enemy):
	_enemies.erase(enemy)
	GameManager.enemy_count_changed.emit()
	_fix_enemies()
static func _fix_enemies() -> void:
	var fix:Array[Enemy]
	for enemy in _enemies:
		if is_instance_valid(enemy): fix.append(enemy)
	_enemies = fix
static func get_enemies() -> Array[Enemy]:
	_fix_enemies()
	return _enemies 
static func get_enemy_bounds(with := get_enemies()) -> Rect2:
	
	var top_left := Vector2.INF
	var bottom_right := -Vector2.INF
	
	for enemy in with:
		var collision_shape:RectangleShape2D = enemy.collider.shape
		
		var enemy_top_left = enemy.global_position - (collision_shape.size / 2.0)
		var enemy_bottom_right = enemy.global_position + (collision_shape.size / 2.0)
	
		top_left.x = min(top_left.x, enemy_top_left.x)
		top_left.y = min(top_left.y, enemy_top_left.y)
		
		bottom_right.x = max(bottom_right.x, enemy_bottom_right.x)
		bottom_right.y = max(bottom_right.y, enemy_bottom_right.y)
	
	return Rect2(top_left, bottom_right - top_left)
func get_commander() -> Commander:
	var parent := get_parent()
	return parent if parent is Commander else null

static func make_new() -> Enemy: return null

func _init() -> void: 
	_enemies.append(self)

@onready var hurtbox:Hurtbox = $Hurtbox
@onready var collider:CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	hurtbox.died.connect(_on_death)
	hurtbox.took_damage.connect(_on_hit)

func _on_death() -> void: 
	_score_death_points()
	deregister_enemy(self)
	spawn_death_particle()
	queue_free()

func _on_hit() -> void:
	
	SfxRegister.play_sound(preload("res://Assets/SFX/EnemyHit.tres"))
	
	_score_hit_points()

func spawn_death_particle() -> void:
	var particle := preload("res://Scenes/Particles/EnemyDeathParticle/EnemyDeathParticle.tscn").instantiate()
	
	get_tree().current_scene.add_child(particle)
	
	particle.global_position = global_position

## Defines how this enemy moves.
@abstract func move(direction:int, delta:float) 
## Define how this enemy descends.
@abstract func descend(delta:float) 
## How many points this enemy is worth on hit.
@abstract func hit_points() -> int
## How many points this enemy is worth on death.
@abstract func death_points() -> int

## The likelyhood of this enemy showing up at a certain difficulty, as a weight.
static func weight(_diff:float) -> float: return 0.0

func _score_hit_points() -> void: GameManager.add_score(hit_points())
func _score_death_points() -> void: GameManager.add_score(death_points())

func _process(_delta: float) -> void:
	if hurtbox.invincibility_timer > 0:
		visible = int(hurtbox.invincibility_timer * 10) % 2 == 0
	else:
		visible = true


## Debug commander bounds drawing.
#func _process(_delta: float) -> void: queue_redraw()
#func _draw() -> void: 
	#var rect := get_enemy_bounds(get_commander().get_enemies())
	#rect.position -= position
	#
	#draw_rect(rect, Color(1.0, 0.0, 0.0, 0.04))
