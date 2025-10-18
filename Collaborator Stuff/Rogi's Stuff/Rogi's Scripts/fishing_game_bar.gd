extends Node2D
@onready var bar_node: Node = $CanvasLayer/ProgressBar
@onready var fish_pulling_placeholder = $FishPullingPlaceholder
@onready var player_pulling_placeholder = $PlayerPullingPlaceholder



func update_progress_bar():
	bar_node.value = FishingManager.ref.get_line_tension_percent()

func _process(_delta):
	update_progress_bar()
