extends CanvasLayer

@onready var main_menu = "res://main_menu.tscn"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	self.hide()
	get_tree().paused = false
		
func _on_retry_button_3_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()
	
func _on_main_menu_button_2_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(main_menu)
	
func trigger_win_screen():
	self.show()
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	print("Game Over triggered by explosion!")
