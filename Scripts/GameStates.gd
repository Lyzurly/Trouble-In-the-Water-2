extends Node

var state: states
enum states {GAMEPLAY,PAUSED, MAIN_MENU}

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	set_process_mode(Node.PROCESS_MODE_ALWAYS)

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("Pause"):
		#print("Pause detected during state ",state)
		match state:
			states.GAMEPLAY:
				change_state(states.PAUSED)
			states.PAUSED:
				change_state(states.GAMEPLAY)

func change_state(new_state: states) -> void:
	state = new_state
	get_tree().paused = state == states.PAUSED
	
	match state:
		states.GAMEPLAY:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		states.PAUSED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		states.MAIN_MENU:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		_:
			print("null state?")
	
