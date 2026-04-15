extends AnimatedSprite3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false
	frame = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if visible == true:
		play("EXPLODE")
	else:
		play("default")
