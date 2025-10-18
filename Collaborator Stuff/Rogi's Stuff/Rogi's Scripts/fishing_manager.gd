## The manager for the fishing minigame

class_name FishingManager extends Node

static var ref: FishingManager

signal fishing_success
signal fishing_failure_linebreak
signal fishing_failure_escape

enum FISHING_RESULTS {
	SUCCESS,
	FAIL_LINEBREAK,
	FAIL_ESCAPE
}

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
const MAXIMUM_FISH_PULL_TIME: float = 3.5
const EXTRA_PLAYER_PULL_TIME: float = 2.0
const INITIAL_FISH_DISTANCE: float = 50.0
const INITIAL_FISH_DISTANCE_MARGIN: float = 10.0

const PLAYER_PULL_STRENGTH: float = 90.0
const FISH_PULL_STRENGTH: float = 30.0

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
		if val > 109.0:
			end_fishing(FISHING_RESULTS.FAIL_LINEBREAK)
		if val < 1.0:
			end_fishing(FISHING_RESULTS.FAIL_ESCAPE)
		_line_tension_percent = clamp(val, 0.0, 110.0)

var _fish_distance: float:
	get:
		return _fish_distance
	set(val):
		if _fish_distance == val:
			return
		if _fish_distance < 0.5:
			end_fishing(FISHING_RESULTS.SUCCESS)
			fishing_success.emit()
		_fish_distance = clamp(val, 0.0, 200.0)

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

func get_fish_distance():
	return _fish_distance

func set_fish_distance(distance: float) -> void:
	_fish_distance = distance

func get_current_fish():
	return _current_fish

func set_current_fish(fish: Fish) -> void:
	_current_fish = fish

func get_is_fish_pulling():
	return _is_fish_pulling

func set_is_fish_pulling(truth_value: bool) -> void: 
	_is_fish_pulling = truth_value

func start_finshing() -> void:
	if !_is_fishing:
		var random_fish: Fish = fish_array.pick_random()
		set_current_fish(random_fish)
		set_line_tension_percent(50.0)
		set_fish_distance(randf_range(INITIAL_FISH_DISTANCE - INITIAL_FISH_DISTANCE_MARGIN, INITIAL_FISH_DISTANCE + INITIAL_FISH_DISTANCE_MARGIN))
	set_is_fishing(true)


func toggle_is_fish_pulling():
	if _is_fish_pulling:
		set_is_fish_pulling(false)
		await get_tree().create_timer(EXTRA_PLAYER_PULL_TIME + randf_range(MINIMUM_FISH_PULL_TIME, MAXIMUM_FISH_PULL_TIME)).timeout
		toggle_is_fish_pulling()
	else:
		set_is_fish_pulling(true)
		await get_tree().create_timer(randf_range(MINIMUM_FISH_PULL_TIME, MAXIMUM_FISH_PULL_TIME)).timeout
		toggle_is_fish_pulling()




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

func update_fish_distance(delta):
	#region booleans
	var neither_pulling: bool = !Input.is_action_pressed("DebugFishing") and !get_is_fish_pulling()
	var player_only_pulling: bool = Input.is_action_pressed("DebugFishing") and !get_is_fish_pulling()
	var fish_only_pulling: bool = !Input.is_action_pressed("DebugFishing") and get_is_fish_pulling()
	
	if neither_pulling:
		return
	elif player_only_pulling:
		_fish_distance -= PLAYER_PULL_STRENGTH * delta
	elif fish_only_pulling:
		_fish_distance +=  FISH_PULL_STRENGTH * delta
	else:
		_fish_distance -= (PLAYER_PULL_STRENGTH - FISH_PULL_STRENGTH) * delta

func end_fishing(fishing_result: FISHING_RESULTS) -> void: 
	set_is_fishing(false)
	match fishing_result: 
		FISHING_RESULTS.SUCCESS:
			Globals.fish_collection.append(_current_fish)
			fishing_success.emit()
		FISHING_RESULTS.FAIL_LINEBREAK:
			fishing_failure_linebreak.emit()
		FISHING_RESULTS.FAIL_ESCAPE:
			fishing_failure_escape.emit()

func _process(delta):
	if Input.is_action_just_pressed("DebugFishing"):
		start_finshing()
	
	if _is_fishing:
		update_line_tension(delta)
		update_fish_distance(delta)
