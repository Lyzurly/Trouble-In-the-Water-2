class_name PlayerHead extends Node3D

static var ref: PlayerHead

const HEIGHT_DEFAULT: float = 1.7

func _init() -> void:
	ref = self
	
func _ready() -> void:
	global_position.y = HEIGHT_DEFAULT
