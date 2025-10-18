extends Node3D

signal first_bounce
	
@onready var skeleton: Skeleton3D = %Skeleton3D
@onready var root_bone: PhysicalBone3D = %"Physical Bone Hip"

var started_bouncing: bool = false

var is_simulating: bool = true


const START_HEIGHT: float = 30.0
const BOUNCE_HEIGHT: float = 30.0
const BOUNCE_SPEED_BOOST: float = 3.
func _ready() -> void:
	first_bounce.emit()
	#start_falling()

func start_falling() -> void:
	skeleton.physical_bones_start_simulation()
	#visible = true
	
func stop_falling() -> void:
	skeleton.physical_bones_stop_simulation()
	#position.y = START_HEIGHT
	#visible = false
	
func _physics_process(_delta: float) -> void:
	if root_bone.global_position.y <= 1. and not started_bouncing:
		started_bouncing = true
		first_bounce.emit()
	if Input.is_action_just_pressed("DebugLyzBounce"):
		#check_for_bounce()
		update_simulation()

func check_for_bounce() -> void:
	bounce_up()
	
func update_simulation() -> void:
	is_simulating = !is_simulating
	if is_simulating:
		start_falling()
	else:
		stop_falling()



func bounce_up(amount: float = BOUNCE_HEIGHT) -> void:
	root_bone.linear_velocity.y = amount
