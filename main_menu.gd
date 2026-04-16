class_name MainMenu
extends Control


@export var game_scene_path: String = "res://everything_jayden.tscn"
@onready var menu_buttons = $MenuButtons
@onready var options_panel = $OptionsPanel



static var chosen_sensitivity: float = 0.0014

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file(game_scene_path)

func _on_quit_button_pressed():
	get_tree().quit()
	
func _on_options_button_pressed() -> void:
	var tween = create_tween()
	tween.set_parallel(true)
	
	# 1. Fade out the main buttons
	tween.tween_property(menu_buttons, "modulate:a", 0.0, 0.2)
	
	# 2. Prepare and fade in the options panel
	options_panel.show()
	options_panel.modulate.a = 0
	tween.tween_property(options_panel, "modulate:a", 1.0, 0.2)
	
	# 3. This tells the tween: "When you are done, hide the buttons"
	tween.set_parallel(false) # Switch back to sequential for the final step
	tween.tween_callback(menu_buttons.hide)

func _on_back_button_pressed() -> void:
	var tween = create_tween()
	tween.set_parallel(true)
	
	# Fade out options, fade in menu
	tween.tween_property(options_panel, "modulate:a", 0.0, 0.2)
	
	menu_buttons.show()
	menu_buttons.modulate.a = 0
	tween.tween_property(menu_buttons, "modulate:a", 1.0, 0.2)
	
	tween.set_parallel(false)
	tween.tween_callback(options_panel.hide)


func _on_h_slider_value_changed(value: float) -> void:
	# value is usually 0.0 to 1.0 (if you set that in the slider inspector)
	# AudioServer needs decibels. linear_to_db converts 0-1 to proper volume levels.
	var bus_index = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))
	
	# Mute if the slider is at the bottom
	AudioServer.set_bus_mute(bus_index, value < 0.05)
	



func _on_h_slider_2_value_changed(value: float) -> void:
	var scaled = value * .35
	ProjectSettings.set_setting("game/sensitivity", scaled)
