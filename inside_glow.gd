extends StaticBody3D

# This will now work even if the child isn't named "Cube"
func toggle_glow(is_on: bool):
	var item_glow = preload("res://glow_outline.tres")
	
	# This looks for ANY mesh child, no matter what it's named
	for child in get_children():
		if child is MeshInstance3D:
			if is_on:
				child.material_overlay = item_glow
			else:
				child.material_overlay = null
