extends CanvasLayer

## Define UI nodes.
@onready var score_label := $MarginContainer/Score
@onready var depth_label := $MarginContainer/Depth
@onready var health_bar := $MarginContainer/HealthBar

func _ready() -> void: 
	_update_scoreboard()
	enemy_count_changed.connect(_on_enemy_count_changed)

#region Scoreboard

#region Score
signal score_changed(to:int)

var _score:int = 0:
	set = set_score,
	get = get_score
var _highscore:int = 0
var _got_new_score := false

func set_score(to:int) -> void:
	_score = to
	if to > _highscore:
		_highscore = to
		_got_new_score = true
	_update_scoreboard()
	score_changed.emit(to)

func get_score() -> int: return _score
func get_highscore() -> int: return _highscore

func add_score(amount:int) -> void:
	_score += amount
func remove_score(amount:int) -> void:
	_score = max(_score - amount, 0)
#endregion

#region Depth
signal depth_changed(to:int)

var _depth:int = 0:
	set = set_depth,
	get = get_depth
var _highdepth:int = 0
var _got_new_depth := false

func set_depth(to:int) -> void:
	_depth = to
	if to > _highdepth:
		_highdepth = to
		_got_new_depth = true
	_update_scoreboard()
	depth_changed.emit(to)

func get_depth() -> int: return _depth
func get_highdepth() -> int: return _highdepth

func add_depth(amount:int) -> void:
	_depth += amount
func remove_depth(amount:int) -> void:
	_depth = max(_score - amount, 0)
#endregion

#region Health

var _player_health:float = 0:
	set = set_player_health,
	get = get_player_health

func set_player_health(to:float) -> void:
	_player_health = to
	_update_scoreboard()

func get_player_health() -> float: return _player_health

#endregion

func _update_scoreboard() -> void:
	score_label.text = "SCORE " + digitize(get_score(), 6)
	depth_label.text = "DEPTH " + digitize(get_depth(), 3)
	
	health_bar.value = get_player_health()

func set_visibility(to:bool):
	visible = to

func digitize(value:int, digits:int) -> String:
	
	var response := str(value)
	
	while response.length() < digits:
		response = "0" + response
	
	return response

#endregion

#region Game State

@warning_ignore("unused_signal")
signal enemy_count_changed

## Starting the game

const NORMAL_ROUND_COUNT = 3

## The rounds remaining in this run. -1 = Infinite.
var rounds_remaining := 0

## Waves per round.
const WAVES_PER_ROUND := 10

## The waves remaining in this round. 
var waves_remaining := 0

## The current difficulty value. Determines the difficulty of waves.
var current_difficulty:float:
	get():
		return difficulty_curve(diff_x)
var diff_x := 0.0

# Linear... for now...
func difficulty_curve(x:float) -> float:
	return 1.5 * x

var player_max_health:int = 10 # We're changing this for Ironman Mode, and I can't be bothered.



func start_game(mode:int):
	
	player_max_health = 10
	diff_x = 0.0
	set_score(0)
	set_depth(0)
	_got_new_score = false
	_got_new_depth = false
	
	match mode:
		## Normal mode. [NORMAL_ROUND_COUNT] waves of enemies, then sucess!
		0: _start_game(NORMAL_ROUND_COUNT)
		
		## Endless mode. Infinite rounds.
		1: _start_game(-1)
		
		## Ironman mode. Normal but w/ 1hp to start.
		2: 
			player_max_health = 1
			_start_game(NORMAL_ROUND_COUNT)

func _start_game(round_count:int):
	MusicPlayer.transition("Game")
	rounds_remaining = round_count
	_start_round()

func _start_round() -> void:
	
	_update_scoreboard()
	
	if rounds_remaining == 0:
		
		## Catch and redirect to win screen.a
		GameOver._was_win = true
		Transitioner.request_transition(3.0, "res://Scenes/UI/GameOver/GameOver.tscn", false)
		
		return
	
	# Tick the remaining rounds down 1, unless endless.
	if rounds_remaining != -1:
		rounds_remaining -= 1
	
	var rounds_remaining_text := str(rounds_remaining + 1) + " ROUNDS REMAINING"
	@warning_ignore("integer_division")
	if rounds_remaining == -1: rounds_remaining_text = "ROUND " + str(get_depth() / WAVES_PER_ROUND + 1)
	
	await Transitioner.request_transition(2.5, "res://Scenes/Levels/Level01/Level01.tscn", true, rounds_remaining_text, preload("res://Assets/SFX/RoundComplete.wav"))
	
	
	waves_remaining = WAVES_PER_ROUND
	start_wave(false)

signal starting_wave(difficulty:float)
func start_wave(with_animation := true) -> void:
	
	# No more waves. Onto the next round.
	if waves_remaining == 0:
		_start_round()
		return
	
	waves_remaining -= 1
	add_depth(1)
	
	if with_animation:
		await get_tree().create_timer(1.0).timeout
		
	
	# Increase the difficulty a bit.
	diff_x += 0.1
	
	# Tell the level to get started
	starting_wave.emit(current_difficulty)


func request_game_over() -> void:
	GameOver._was_win = false
	Transitioner.request_transition(3.0, "res://Scenes/UI/GameOver/GameOver.tscn", false)
	MusicPlayer.transition("Menu")


static var enemies_remaining:int:
	get(): return Enemy.get_enemies().size()

## When the last enemy dies, start the next wave.
func _on_enemy_count_changed() -> void:
	if enemies_remaining == 0: start_wave()

func get_scroll_speed() -> float:
	return 75.0 + (35.6 * current_difficulty)
