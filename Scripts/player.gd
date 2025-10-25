class_name Player extends CharacterBody3D

static var ref: Player

@onready var camera: Camera3D = %Camera3D

var _movement_blocked: bool = false

var _activation_blocked: bool = false
const JOY_LOOK_SCALAR: float = 9.

var input_dir: Vector2
var direction: Vector3

const SPEED_DEFAULT: float = 5.5
const SPEED_SPRINT: float = 7.
const JUMP_VELOCITY: float = 4.5

var speed: float = SPEED_DEFAULT
var target_speed: float = SPEED_DEFAULT

func set_speed(value: float) -> void:
	target_speed = value

func _process(_delta: float) -> void:
	speed = lerp(speed, target_speed, 0.1)

const ROTATE_FACTOR: float = 4.
const ROTATE_SPEED: float = 1.
const ROTATE_CLAMP: float = 1.5
const ROTATE_VERTICAL_CLAMP: float = 1.5

const YAW_RESET_SPEED: float = .3

@onready var mesh: MeshInstance3D = %PlayerCapsule
@onready var collision_standing: CollisionShape3D = %Collision_Standing

var player_state: player_states
enum player_states {
	WALKING,
	SPRINTING,
	FROZEN,
	}

func _init() -> void:
	ref = self
	
func _ready() -> void:
	mesh.visible = false
	
func change_state(new_state: player_states) -> void:

	player_state = new_state
	Print.debug_print("Player state updated to:\t", str(player_states.keys()[player_state]))
	
func _input(event: InputEvent) -> void:
	if Player.ref == null:
		return

	if OS.is_debug_build():
		if Input.is_action_just_pressed("Restart"):
			get_tree().reload_current_scene()
	
	if not player_state == player_states.FROZEN:
		_handle_looking(event)
			
		
		if Input.is_action_just_pressed("Activate"):
			Print.debug_print("Activate key pressed...")
			if _activation_blocked:
				Print.debug_print("Activate input BLOCKED!")
			else:
				pass #Add activation logic here

func _physics_process(delta: float) -> void:
	if not player_state == player_states.FROZEN:
		_handle_movement(delta)
		
	_handle_joypad_looking()
		
func block_movement(block:bool) -> void:
	_movement_blocked = block
	if block:
		Print.debug_print("Movement BLOCKED!")
	else:
		Print.debug_print("Movement unblocked.")

func block_activation(block:bool) -> void:
	_activation_blocked = block
	if block:
		Print.debug_print([Print.FX.INFO],"Future activation BLOCKED!")
	else:
		Print.debug_print([Print.FX.INFO],"Future activation unblocked.")

func _handle_joypad_looking() -> void:
	var joy_vector: Vector2 = Vector2(Input.get_vector(
		"Look_Joy_Left",
		"Look_Joy_Right",
		"Look_Joy_Up",
		"Look_Joy_Down"))
	var joy_pos: Vector2 = Vector2(
		joy_vector.x * JOY_LOOK_SCALAR,
		joy_vector.y *JOY_LOOK_SCALAR)
		
	_rotate_player(joy_pos)
		
func _handle_looking(event: InputEvent) -> void:
	if event is InputEventMouseMotion or event is InputEventScreenDrag:
		
		var mouse_pos: Vector2 = event.screen_relative
		_rotate_player(mouse_pos)

func _handle_movement(delta:float) -> void:
	if Input.is_action_pressed("Sprint"):
		speed = SPEED_SPRINT
	else:
		speed = SPEED_DEFAULT
	
	if not is_on_floor():
		velocity += get_gravity() * delta
			
	input_dir = Input.get_vector("Left", "Right", "Forward", "Backward")
	direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
		
	move_and_slide()

func _rotate_player(mouse_pos:Vector2) -> void:
	var vertical_rotation_deg: float = deg_to_rad(-mouse_pos.y * ROTATE_SPEED/ROTATE_FACTOR)
	var horizontal_rotation_deg: float = deg_to_rad(-mouse_pos.x * ROTATE_SPEED/ROTATE_FACTOR)
	
	var horiz_rotation: float = global_rotation.y + horizontal_rotation_deg
	global_rotation.y = lerp(global_rotation.y,horiz_rotation,1.)
	
	var vert_rotation: float = PlayerHead.ref.global_rotation.x + vertical_rotation_deg
	var vert_clamped: float = clamp(vert_rotation,-ROTATE_VERTICAL_CLAMP,ROTATE_VERTICAL_CLAMP)
	
	PlayerHead.ref.global_rotation.x = lerp(PlayerHead.ref.global_rotation.x,vert_clamped,1.)
