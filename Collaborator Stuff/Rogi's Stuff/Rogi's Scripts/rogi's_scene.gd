extends Node3D

const ANGLER_1 = preload("uid://6rycvarcb1q")

const FISH_DISPLAY_TIME: float = 1.0
const FISH_SIZE_SCALAR = 0.3

func _ready():
	FishingManager.ref.fishing_success.connect(_on_fishing_success)
	FishingManager.ref.fishing_failure_linebreak.connect(_on_fishing_failure_linebreak)
	FishingManager.ref.fishing_failure_escape.connect(_on_fishing_failure_escape)

func _on_fishing_success():
	#get fish resource
	var caught_fish: Fish = FishingManager.ref._current_fish
	
	#instance fish scene and add to tree
	var fish_instance: Node = caught_fish.fish_scene.instantiate()
	add_child(fish_instance)
	
	#set fish scale
	var fish_mesh: MeshInstance3D = fish_instance.get_child(0)
	fish_mesh.scale = (1.0 + caught_fish.size * FISH_SIZE_SCALAR) * Vector3.ONE
	
	#set fish hue shift
	var shader_material: ShaderMaterial = fish_mesh.get_surface_override_material(0) as ShaderMaterial
	shader_material.set_shader_parameter("shift_amount", caught_fish.hue_shift)
	
	#despawn caught fish
	await get_tree().create_timer(FISH_DISPLAY_TIME).timeout
	fish_instance.queue_free()

func _on_fishing_failure_linebreak():
	pass

func _on_fishing_failure_escape():
	pass
