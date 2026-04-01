# ATTACH THIS TO ANY OBJECT YOU WANT TO GLOW AND MAKE IT ON LAYER TWO THE OBJECT

extends StaticBody3D

@onready var object = $Cube # NAME THIS THE OBJECT YOU ATTACH IT TO

# Allows us to use the shader material on this item and pre loads so game doesnt lag when looking at new items
var item_glow: Material = preload("res://glow_outline.tres") 

func toggle_glow(is_on: bool):
	print("Object received toggle: ", is_on) 
	if is_on: # If value inside is true then
		object.material_overlay = item_glow # Our objects overlay is changed to the glow outline
	else:
		object.material_overlay = null # If our object is not longer being looked at remove its glow
	
	
