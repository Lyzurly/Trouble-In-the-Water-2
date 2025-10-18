extends Node3D

@onready var ground: StaticBody3D = %Ground
@onready var lake: StaticBody3D = %Lake

func _ready() -> void:
	_init_collisions()
	
func _init_collisions() -> void:
	ground.set_collision_layer_value(
		Globals.COLLISIONS.GROUND,true
	)
	lake.set_collision_layer_value(
		Globals.COLLISIONS.LAKE,true
	)
	
	
