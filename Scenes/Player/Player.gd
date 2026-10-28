class_name Player extends CharacterBody2D

@onready var process_material:ParticleProcessMaterial = $GPUParticles2D.process_material

static var instance:Player # There's only ever gonna be one Blade.
func _init() -> void: instance = self

const HIT_COST := 5 ## How much it costs the score to get hit.

@onready var hurtbox:Hurtbox = $Hurtbox

var direction:int = 0

@export var speed := 40.0 # Pixels across the screen resolution.

@export var firing_interval := 0.4
var fire_cooldown := 0.0

var dash_direction:int = 1
@export var dash_time := 0.4
@export var dash_speed := 90.0
@export var dash_cooldown := 1.0
var dash_timer := 0.0

var bullet_components:Array[BulletComponent]

func _ready() -> void:
	hurtbox.took_damage.connect(_on_took_damage)
	hurtbox.died.connect(_on_death)
	hurtbox.max_health = GameManager.player_max_health
	
	GameManager.set_player_health(hurtbox.health / float(GameManager.player_max_health))
	
	
	process_material.initial_velocity_max = GameManager.get_scroll_speed()
	process_material.initial_velocity_min = GameManager.get_scroll_speed()

func _on_death() -> void:
	
	GameManager.request_game_over()
	
	spawn_death_particle()
	
	SfxRegister.play_sound(preload("res://Assets/SFX/PlayerDeath.wav"))
	
	queue_free()

func spawn_death_particle() -> void:
	var particle := preload("res://Scenes/Particles/EnemyDeathParticle/EnemyDeathParticle.tscn").instantiate()
	
	get_tree().current_scene.add_child(particle)
	
	particle.global_position = global_position

func _on_took_damage() -> void:
	GameManager.remove_score.bind(HIT_COST)
	GameManager.set_player_health(hurtbox.health / float(GameManager.player_max_health))
	
	SfxRegister.play_sound(preload("res://Assets/SFX/Hit.wav"))

func _process(_delta: float) -> void:
	if hurtbox.invincibility_timer > 0:
		visible = int(hurtbox.invincibility_timer * 10) % 2 == 0
	else:
		visible = true

func _physics_process(delta: float) -> void:
	
	if Input.is_action_just_pressed("Dash") and dash_timer == 0.0:
		dash_timer = dash_time
	if dash_timer > 0:
		velocity.x = dash_direction * dash_speed
	
	var to := move_toward(dash_timer, 0.0, delta)
	if to == 0 and dash_timer > 0:
		dash_timer = -dash_cooldown
	else: dash_timer = to
	
	direction = int(Input.get_axis("Left", "Right"))
	if direction: dash_direction = direction
	
	if dash_timer <= 0:
		velocity.x = direction * speed
	
	move_and_slide()
	
	position.x = wrap(position.x, 0.0,  384.0)
	
	if Input.is_action_pressed("Shoot"): 
		if fire_cooldown <= 0:
			fire_cooldown = firing_interval
			shoot()
		fire_cooldown = move_toward(fire_cooldown, 0.0, delta)
	else:
		fire_cooldown = 0

func shoot() -> void:
	
	get_tree().current_scene.add_child(
		Bullet.make_bullet(bullet_components, Vector2.UP, position + (Vector2.UP * 25), Enemy, 3)
	)
