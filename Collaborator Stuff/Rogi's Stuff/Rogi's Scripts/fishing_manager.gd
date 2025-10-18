## The manager for the fishing minigame

class_name FishingManager extends Node

static var ref: FishingManager

const ANGLER_1 = preload("uid://6rycvarcb1q")
const ANGLER_2 = preload("uid://c65cbh5efqxdp")
const ANGLER_3 = preload("uid://bl43n03s0c55f")
const CLOWN_1 = preload("uid://c6fsxplx5mo7g")
const CLOWN_2 = preload("uid://ba134yn27slrk")
const CLOWN_3 = preload("uid://djv25joaornnp")
const PUFFER_1 = preload("uid://piwdeci5qs82")
const PUFFER_2 = preload("uid://g3dul4ka1edg")
const PUFFER_3 = preload("uid://7mmovy5xb71b")

const TENSION_DECREASE_RATE: float = 50.0
const TENSION_INCREASE_RATE: float = 60.0
const FISH_ONLY_PULL_STRENGTH: float = 0.05
const BOTH_PULLING_STRENGTH: float = 1.5

const MINIMUM_FISH_PULL_TIME: float = 1.0
const MAXIMUM_FISH_PULL_TIME: float = 6.0

var fish_array: Array[Fish] = [ANGLER_1,ANGLER_2,ANGLER_3,CLOWN_1,CLOWN_2,CLOWN_3,PUFFER_1,PUFFER_2,PUFFER_3]

var _is_fishing: bool = false:
	get:
		return _is_fishing
	set(val):
		if _is_fishing == val:
			return
		_is_fishing = val


var _line_tension_percent : float = 0:
	get:
		return _line_tension_percent
	set(val):
		if _line_tension_percent == val:
			return
		_line_tension_percent = clamp(val, 0.0, 100.0)

var _current_fish: Fish:
	get:
		return _current_fish
	set(val):
		if _current_fish == val:
			return
		_current_fish = val

var _is_fish_pulling: bool = false:
	get:
		return _is_fish_pulling
	set(val):
		if _is_fish_pulling == val:
			return
		_is_fish_pulling = val


func _init() -> void:
	ref = self

func _ready():
	toggle_is_fish_pulling()

func get_is_fishing():
	return _is_fishing

func set_is_fishing(truth_value: bool) -> void:
	_is_fishing = truth_value

func get_line_tension_percent():
	return _line_tension_percent

func set_line_tension_percent(percent: float) -> void:
	_line_tension_percent = percent

func get_current_fish():
	return _current_fish

func set_current_fish(fish: Fish) -> void:
	_current_fish = fish

func get_is_fish_pulling():
	return _is_fish_pulling

func set_is_fish_pulling(truth_value: bool) -> void: 
	_is_fish_pulling = truth_value

func start_finshing() -> Fish:
	if !_is_fishing:
		set_line_tension_percent(50.0)
	set_is_fishing(true)
	var random_fish: Fish = fish_array.pick_random()
	set_current_fish(random_fish)
	return random_fish

func toggle_is_fish_pulling():
	_is_fish_pulling = !_is_fish_pulling
	await get_tree().create_timer(randf_range(MINIMUM_FISH_PULL_TIME, MAXIMUM_FISH_PULL_TIME)).timeout
	toggle_is_fish_pulling()
	print(_is_fish_pulling)

func update_line_tension(delta):
#region booleans
	var neither_pulling: bool = !Input.is_action_pressed("DebugFishing") and !get_is_fish_pulling()
	var player_only_pulling: bool = Input.is_action_pressed("DebugFishing") and !get_is_fish_pulling()
	var fish_only_pulling: bool = !Input.is_action_pressed("DebugFishing") and get_is_fish_pulling()
#endregion
	if neither_pulling:
		_line_tension_percent -= TENSION_DECREASE_RATE * delta
	elif player_only_pulling:
		_line_tension_percent += TENSION_INCREASE_RATE * _current_fish.size * delta
	elif fish_only_pulling:
		_line_tension_percent += TENSION_INCREASE_RATE * _current_fish.size * delta * FISH_ONLY_PULL_STRENGTH
	else: #both pulling
		_line_tension_percent += TENSION_INCREASE_RATE * _current_fish.size * delta * BOTH_PULLING_STRENGTH

func end_fishing() -> void: 
	set_is_fishing(false)

func _process(delta):
	if Input.is_action_just_pressed("DebugFishing"):
		start_finshing()
	
	if _is_fishing:
		update_line_tension(delta)
