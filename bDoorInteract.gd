extends StaticBody3D
class_name Interactable

@export_enum("Collect", "Animate", "Explode", "Task") var interaction_type: String = "Collect"
@export var interaction_time: float = 1.0
@export var item_name: String = "Item"

# ADD THIS LINE RIGHT HERE:
@export var animation_to_play: String = ""

var is_completed: bool = false
