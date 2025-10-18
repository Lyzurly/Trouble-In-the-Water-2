## The manager for the fishing minigame

class_name FishingManager extends Node

static var ref: FishingManager

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

var _current_fish: int = 0:
	get:
		return _current_fish
	set(val):
		if _current_fish == val:
			return
		_current_fish = val
		

func get_line_tension_percent():
	return _line_tension_percent

func _set_line_tension_percent(percent: float) -> void:
	_line_tension_percent = percent

func get_is_fishing():
	return _is_fishing

func set_is_fishing(truth_value: bool) -> void:
	_is_fishing = truth_value

func start_finshing() -> void:
	_set_line_tension_percent(50.0)
	_is_fishing = true

func end_fishing() -> Dictionary: 
	

func _process(_delta):
	if Input.is_action_just_pressed("DebugFishing"):
		start_finshing()
