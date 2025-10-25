extends Node3D

const ANGLER_1 = preload("uid://6rycvarcb1q")



func _ready():
	var fish_mesh: MeshInstance3D = $angler_mesh/Cube
	var shader_material: ShaderMaterial = fish_mesh.mesh.surface_get_material(0) as ShaderMaterial
	
	shader_material.set_shader_parameter("hue_shift", ANGLER_1.hue_shift)
	
	
	#var fish_instance: Node = ANGLER_1.fish_scene.instantiate()
	#add_child(fish_instance)
	#var fish_mesh: MeshInstance3D = fish_instance.get_child(0)
	#var shader_material: ShaderMaterial = fish_mesh.mesh.surface_get_material(0) as ShaderMaterial
#
	#shader_material.set_shader_parameter("shader_parameter/shift_amount", ANGLER_1.hue_shift)
	
