extends CharacterBody3D # Allows us to use the physics node for CharacterBody3D

@onready var camera = $Camera3D # onready makes the script wait until whole scene is loaded, $ means look for children node named Camera3D
@onready var collision = $CollisionShape3D # allows us to use the collision shape child object of player
@onready var ceiling_check = $CrouchCheck #Allows us to use the child object of player which is raycast3d and we rename it ceiling_check

var is_game_over: bool = false

@onready var gameplay_music = $GameplayMusic

@onready var pause_menu = $PauseMenu
@onready var pause_panel = $PauseMenu/PausePanel
@onready var options_panel = $PauseMenu/OptionsPanel

@onready var confetti = $Camera3D/Confetti
@onready var win_player = $WinPlayer

@onready var glow_outline = load("res://glow_outline.tres") # Allows us to use a glow outline texture found in the res folde
@onready var interact_check = $Camera3D/InteractCheck # Allows us to use the interact check raycast inside of the camera
var hovered_object = null # When starting the game the object we are looking at is nothing
var mouse_sensitivity: float = 0.0014
@onready var win_screen = $CanvasLayer3

@onready var footstep_player = $FootstepPlayer
var footstep_sounds = [
	load("res://Step1.WAV"),
	load("res://Step2.WAV"),
	load("res://Step3.WAV"),
	load("res://Step4.WAV"),
	load("res://Step5.WAV")
]

var footstep_timer = 0.0
var step_interval = 0.3 # Speed of footsteps playing

# Crouching Variables
var target_cam_y = 0.8 # The target position we want the camera to be when crouching
var target_col_h = 1.0 # The target collision box height we want when crouching
var target_col_y = .5 # The target collision position we want when crouching


# Interaction Variables
var current_hold_time: float = 0.0    # Tracks seconds held
var is_interacting: bool = false      # Are we currently holding E?
var tasks_completed: int = 0          # The Counter for tasks we need to complete.
var inventory: Array = []             # The list of collected items/tasks done
@onready var interaction_bar = $CanvasLayer2/InteractionUI/TextureProgressBar
@export var end_screen: CanvasLayer
@onready var explode = $Camera3D/Ending/Explode

var pitch = 0 # Variable pitch created, pitch determines how much the camera moves precisely instead of the camera doing said math

# Camera Controlls

func _ready():
	if ProjectSettings.has_setting("game/sensitivity"):
		mouse_sensitivity = ProjectSettings.get_setting("game/sensitivity")
	else:
		mouse_sensitivity = 0.0014
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
func _input(event):
	# 1. This part stays OUTSIDE the gate so you can always close the menu
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			if not is_game_over:
				toggle_pause()

	# 2. THE GATE: Only run camera rotation if the game is NOT paused
	if not get_tree().paused:
		if event is InputEventMouseMotion:
			rotate_y(-event.relative.x * mouse_sensitivity)
			pitch -= event.relative.y * mouse_sensitivity
			pitch = clamp(pitch, deg_to_rad(-89), deg_to_rad(89))
			camera.rotation.x = pitch
		

# Movement/Jump

# Allows us to use delta which is keeps everything consistent allowing movement to be seperated from framerate
func _physics_process(delta): # Multiplication by delta keeps things constant regardless of fps(Not used for movement move_and_slide() does that)
	
	if get_tree().paused:
		return
	
	# Makes X,Y,Z Zero
	var direction = Vector3.ZERO 
	var camera = $Camera3D
	# If D is pressed character moves right
	if Input.is_key_pressed(KEY_D):
		direction.x += 1
		
	# If A is pressed character moves left
	if Input.is_key_pressed(KEY_A):
		direction.x -= 1
		
	# If S is pressed character moves backward
	if Input.is_key_pressed(KEY_S):
		direction.z += 1
	
	# If W is pressed character moves forward
	if Input.is_key_pressed(KEY_W):
		direction.z -= 1
	
	# Checks if player is moving
	if direction != Vector3.ZERO:
		direction = direction.normalized() # If player is moving then no matter what their speed will be fixed
	
		
	if Input.is_key_pressed(KEY_S): # Example of lessening speed of any key, just check if its being pressed reduce its speed then apply velocity
		direction = direction * 0.6 # Smaller number slower, bigger number faster movement for said key
		
	direction = direction.rotated(Vector3.UP, rotation.y) #Allows rotation to be player specefied, instead of global causing the player to always go in the same direction no matter angle	 
		
	# Lets direction have value
	velocity.x = direction.x * 3 # Speed Stat for up and down
	velocity.z = direction.z * 3 # Speed stat for left and right
	
	if not is_on_floor(): # If the player is not touching the floor apply gravity
		velocity.y -= 15 * delta # Multiplies it by rate of gravity times delta to keep it constant
	else:
		velocity.y = 0 # if player touching floor keep their y = 0
		if Input.is_key_pressed(KEY_SPACE): # If the player presses space while on floor increase y value(Jumping)
			velocity.y += 5
			
		# If ctrl is pressed or the ceiling checker is touching an object the player crouches or stays crouches
		if Input.is_key_pressed(KEY_CTRL) or ceiling_check.is_colliding():
			
			target_cam_y = 0.8 # The target position we want the camera to be when crouching
			target_col_h = 1.0 # The target collision box height we want when crouching
			target_col_y = .5 # The target collision position we want when crouching
			
			camera.position.y = lerp(camera.position.y, target_cam_y, 10 * delta) # Slowly bring the thing we want to move to the point we chose, 10 is the nubmer it moves by
			collision.shape.height = lerp(collision.shape.height, target_col_h, 10 * delta) # Same as above
			collision.position.y = lerp(collision.position.y, target_col_y, 10 * delta) # Same as above
			
		else: # keeps the camera position the same
			target_cam_y = 1.5 # Allows us to use lerp for different values while still using target variable
			target_col_h = 2.0 # Same as above
			target_col_y = 1.0 # Same as above
			
			
			camera.position.y = lerp(camera.position.y, target_cam_y, 10 * delta) # Slowly bring the thing we want to move to the point we chose, 10 is the nubmer it moves by
			collision.shape.height = lerp(collision.shape.height, target_col_h, 10 * delta) # Same as above
			collision.position.y = lerp(collision.position.y, target_col_y, 10 * delta) # Same as above
			
			
	move_and_slide() # Moves the player while handling collisions, used at end to ensure every key input is rendered with this
	
	handle_glow(delta)# We put this here so it the glow check script runs over and over
	
	var horizontal_speed = Vector2(get_real_velocity().x, get_real_velocity().z).length()
	
	# Only play sounds if we are on floor AND actually moving faster than a tiny jitter (0.1)
	if is_on_floor() and horizontal_speed > 0.1:
		if footstep_timer == 0.0:
			play_footstep()
			
		footstep_timer += delta
		
		var current_interval = step_interval
		if Input.is_key_pressed(KEY_CTRL):
			current_interval = 0.7
		
		if footstep_timer >= current_interval:
			play_footstep()
			footstep_timer = 0.0001 
	else:
		footstep_timer = 0.0

func handle_glow(delta):
	if interact_check.is_colliding():
		var hit_collider = interact_check.get_collider()
		
		var glow_target = hit_collider 
		
		var data_target = hit_collider
		while data_target != null and not data_target is Interactable:
			data_target = data_target.get_parent()

		# --- THE FIX: Cast the data_target to the Interactable class ---
		var interactable_data = data_target as Interactable

		if glow_target != hovered_object:
			if hovered_object != null:
				hovered_object.toggle_glow(false)
		
			if glow_target.has_method("toggle_glow"):
				if interactable_data != null and interactable_data.is_completed == false:
					glow_target.toggle_glow(true)
					hovered_object = glow_target
				else:
					hovered_object = null
		
		# We check interactable_data now instead of data_target
		if interactable_data != null and interactable_data.is_completed == false:
			interaction_bar.show()
			$CanvasLayer2/InteractionUI/InteractionLabel.show()
			
			if Input.is_key_pressed(KEY_E):
				current_hold_time += delta
				# Access variables through the casted 'interactable_data'
				interaction_bar.value = (current_hold_time / interactable_data.interaction_time) * 100
				
				if current_hold_time >= interactable_data.interaction_time:
					execute_interaction(interactable_data)
					current_hold_time = 0.0
			else:
				current_hold_time = 0.0
				interaction_bar.value = 0
		else:
			# Hide UI if object is already completed or not interactable
			interaction_bar.hide()
			$CanvasLayer2/InteractionUI/InteractionLabel.hide()
				
	else:
		# If raycast hits nothing, turn off glow and hide UI
		if hovered_object != null:
			hovered_object.toggle_glow(false)
			hovered_object = null
		
		interaction_bar.hide()
		$CanvasLayer2/InteractionUI/InteractionLabel.hide()
		current_hold_time = 0.0

func execute_interaction(target):
	target.is_completed = true
	
	var generic_sfx = target.get_node_or_null("InteractionSFX")
	var loop_sfx = target.get_node_or_null("AudioStreamPlayer3D")
	
	if generic_sfx != null:
		if loop_sfx != null:
			loop_sfx.stop()
			generic_sfx.play()
		else:
			generic_sfx.play()
	
	if hovered_object != null:
		hovered_object.toggle_glow(false)
		hovered_object = null
	
	if target.interaction_type == "Collect":
		inventory.append(target.item_name)
		print("Pickedf up:", target.item_name)
		
		target.visible = false
		
		var target_collision = target.get_node_or_null("CollisionShape3D")
		if target_collision:
			target_collision.disabled = true
		
		tasks_completed += 1
		check_win_condition()
		
		if generic_sfx != null and generic_sfx.playing:
			await generic_sfx.finished
			target.queue_free()
		
		else:
			target.queue_free() #Makes it dissapear

		hovered_object = null
		
	elif target.interaction_type == "Animate":
		if target.name == "doorfixed_living":
			if tasks_completed >= 6:
				is_game_over = true
				if gameplay_music:
					gameplay_music.stop()
					
				if win_player: win_player.play()
				if confetti: confetti.emitting = true
				
				get_tree().paused = true
				interaction_bar.hide()
				$CanvasLayer2/InteractionUI/InteractionLabel.hide()
				Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
				if win_screen != null:
					win_screen.trigger_win_screen()
				return
			else:
				execute_interaction_type_explode() 
				return
		
		var anim_player = null
		
		for child in target.get_children():
			if child is AnimationPlayer:
				anim_player = child
				break

		if anim_player != null:
			anim_player.play(target.animation_to_play)
			
			var door_sfx = target.get_node_or_null("AudioStreamPlayer3D")
			if door_sfx != null:
				door_sfx.play()
			
			check_win_condition()
		else:
			print("Error: No AnimationPlayer node found inside " + target.name)
	
	elif target.interaction_type == "Explode":
		current_hold_time = 0.0
		
		interaction_bar.hide()
		$CanvasLayer2/InteractionUI/InteractionLabel.hide()
		
		if $ExplosionPlayer:
			$ExplosionPlayer.play()
		
		explode.visible = true
		await get_tree().create_timer(.7).timeout
		explode.visible = false
		
		if end_screen != null:
			end_screen.trigger_game_over()
		else:
			print("Error: End Screen node not assigned in Player Inspector!")
	
	elif target.interaction_type == "Task":
		print("Task Finished:", target.item_name)
		tasks_completed += 1
		check_win_condition()
		
				
				
func check_win_condition():
	# This function should now ONLY track progress.
	# The actual WIN happens inside execute_interaction() when the door is opened.
	print("Tasks completed: ", tasks_completed)
	if tasks_completed >= 6:
		print("Ready to leave! Go to the Front Door.")
		
func play_footstep():
	if footstep_player.playing:
		return
	
	var random_sound = footstep_sounds.pick_random()
	footstep_player.stream = random_sound
	
	# Keep the pitch randomization for variety
	footstep_player.pitch_scale = randf_range(0.8, 1.2)
	
	footstep_player.play()
	
func execute_interaction_type_explode():
	is_game_over = true
	if gameplay_music:
		gameplay_music.stop()
		
	current_hold_time = 0.0
	interaction_bar.hide()
	$CanvasLayer2/InteractionUI/InteractionLabel.hide()
	
	if $ExplosionPlayer:
		$ExplosionPlayer.play()
	
	explode.visible = true
	# Give them a moment to see the flash before the menu pops up
	await get_tree().create_timer(.7).timeout
	explode.visible = false
	
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if end_screen != null:
		end_screen.trigger_game_over()
		

func toggle_pause():
	var is_paused = !get_tree().paused
	get_tree().paused = is_paused
	
	if is_paused:
		pause_menu.show()
		pause_panel.show()      # Show Main Pause buttons
		options_panel.hide()     # Hide Sliders initially
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		pause_menu.hide()
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

# --- BUTTON CONNECTIONS ---
# Connect these in the editor to your actual buttons

func _on_options_pressed():
	pause_panel.hide()
	options_panel.show()

func _on_back_button_pressed():
	options_panel.hide()
	pause_panel.show()

func _on_retry_pressed():
	get_tree().paused = false # MUST unpause or the game stays frozen
	get_tree().reload_current_scene()

func _on_main_menu_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://main_menu.tscn") # Verify this path!


func _on_h_slider_value_changed(value: float) -> void:
	var bus_index = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))
	AudioServer.set_bus_mute(bus_index, value < 0.01)

func _on_h_slider_2_value_changed(value: float) -> void:
	# 1. Update the 'Static' variable so it saves for next time
	MainMenu.chosen_sensitivity = value
	# 2. Update the Player's current speed IMMEDIATELY
	mouse_sensitivity = value
