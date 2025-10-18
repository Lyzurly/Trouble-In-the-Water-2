extends Node2D

@onready var bar_node: Node = $CanvasLayer/ProgressBar
@onready var fish_pulling_placeholder = $CanvasLayer/FishPullingPlaceholder
@onready var player_pulling_placeholder = $CanvasLayer/PlayerPullingPlaceholder
@onready var fish_notifier = $CanvasLayer/FishNotifier
@onready var fish_notification_label = $CanvasLayer/FishNotifier/CenterContainer/VBoxContainer/FishNotificationLabel
@onready var fish_distance_placeholder = $CanvasLayer/FishDistancePlaceholder

const FISH_NOTIFICATION_TIME_SEC: float = 3.0

func _ready():
	FishingManager.ref.fishing_success.connect(_on_fishing_success)
	FishingManager.ref.fishing_failure_linebreak.connect(_on_fishing_failure_linebreak)
	FishingManager.ref.fishing_failure_escape.connect(_on_fishing_failure_escape)


func update_progress_bar():
	bar_node.value = FishingManager.ref.get_line_tension_percent()

func update_labels():
	fish_pulling_placeholder.visible = FishingManager.ref._is_fish_pulling
	player_pulling_placeholder.visible = Input.is_action_pressed("DebugFishing")
	fish_distance_placeholder.text = "dist:" +  str(roundf(FishingManager.ref._fish_distance))

func _on_fishing_success():
	fish_notifier.show()
	fish_notification_label.text = "You caught " + str(FishingManager.ref._current_fish.name)
	await get_tree().create_timer(FISH_NOTIFICATION_TIME_SEC).timeout
	fish_notifier.hide()

func _on_fishing_failure_linebreak():
	fish_notifier.show()
	fish_notification_label.text = "The fishing line broke!"
	await get_tree().create_timer(FISH_NOTIFICATION_TIME_SEC).timeout
	fish_notifier.hide()

func _on_fishing_failure_escape():
	fish_notifier.show()
	fish_notification_label.text = "The fish got away!"
	await get_tree().create_timer(FISH_NOTIFICATION_TIME_SEC).timeout
	fish_notifier.hide()

func _process(_delta):
	update_progress_bar()
	update_labels()
