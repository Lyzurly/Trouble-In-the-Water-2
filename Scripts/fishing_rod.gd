class_name FishingRod extends Node3D

var ref: FishingRod
@onready var player_full_body: Node3D = %player_full_body

#@onready var fishing_line: Node3D = %"fishing line"

@onready var line_attachment_point: Marker3D = %line_attachment_point

func _init() -> void:
	ref = self

#func _ready() -> void:
	#fishing_line.skeleton.physical_bones_start_simulation()
	
func _physics_process(_delta: float) -> void:
	player_full_body.root_bone.transform = line_attachment_point.global_transform
