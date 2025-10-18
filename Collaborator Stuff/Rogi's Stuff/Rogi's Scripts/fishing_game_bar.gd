extends Node2D
@onready var bar_node: Node = $CanvasLayer/ProgressBar

func update_progress_bar():
	bar_node.value = FishingManager.ref.get_line_tension_percent()

func _process(_delta):
	update_progress_bar()
