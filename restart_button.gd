extends Button

# Adjust these to change the "feel"
var hover_scale = Vector2(1.05, 1.05)
var normal_scale = Vector2(1.0, 1.0)
var anim_speed = 0.2 # Slightly slower = smoother

func _ready() -> void:
	# Keep the pivot centered so it doesn't jitter
	pivot_offset = size / 2
	
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	button_down.connect(_on_button_down)

func _on_mouse_entered() -> void:
	var tween = create_tween()
	# Parallel lets Scale and Color happen together
	tween.set_parallel(true)
	
	# TRANS_CUBIC + EASE_OUT makes it "glide" into place
	tween.tween_property(self, "scale", hover_scale, anim_speed)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	
	# Subtle glow/brighten
	tween.tween_property(self, "modulate", Color(1.1, 1.1, 1.3), anim_speed)\
		.set_trans(Tween.TRANS_SINE)

func _on_mouse_exited() -> void:
	var tween = create_tween()
	tween.set_parallel(true)
	
	# Return to normal
	tween.tween_property(self, "scale", normal_scale, anim_speed)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	
	tween.tween_property(self, "modulate", Color(1, 1, 1), anim_speed)\
		.set_trans(Tween.TRANS_SINE)

func _on_button_down() -> void:
	# The "Click" feedback should be fast (0.05s) to feel responsive
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(0.95, 0.95), 0.05).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "scale", hover_scale, 0.1).set_trans(Tween.TRANS_CUBIC)
