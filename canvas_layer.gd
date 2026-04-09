extends CanvasLayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	self.hide()
	get_tree().paused = false
		
func _on_retry_button_2_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()
	
func _on_quit_button_2_pressed() -> void:
	get_tree().paused = false
	get_tree().quit()
	
func trigger_game_over():
	self.show()
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	print("Game Over triggered by explosion!")
