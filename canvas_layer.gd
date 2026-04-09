extends CanvasLayer

var timer = 50000


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	self.hide()
	get_tree().paused = false
# Called every frame. 'delta' is the elapsed time since the previous frame.
	
func _process(delta: float) -> void:
	if get_tree().paused == false:
		timer -= delta
		
	if timer <= 0:
		self.show()
		get_tree().paused = true
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		
func _on_retry_button_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_quit_button_2_pressed() -> void:
	get_tree().paused = false
	get_tree().quit()
