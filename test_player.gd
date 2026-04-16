extends CharacterBody3D # Allows us to use the physics node for CharacterBody3D

@onready var win_screen=$CanvasLayer3
@onready var camera = $Camera3D # onready makes the script wait until whole scene is loaded, $ means look for children node named Camera3D
@onready var collision = $CollisionShape3D # allows us to use the collision shape child object of player
@onready var ceiling_check = $CrouchCheck #Allows us to use the child object of player which is raycast3d and we rename it ceiling_check

@onready var glow_outline = load("res://glow_outline.tres") # Allows us to use a glow outline texture found in the res folde
@onready var interact_check = $Camera3D/InteractCheck # Allows us to use the interact check raycast inside of the camera
var hovered_object = null # When starting the game the object we are looking at is nothing

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

func _ready():# Allow us to use ready function, letting us hide the mouse from the player while keeping it centered 
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED # Hides the mouse
	explode.visible = false
	
func _input(event): #allows for us to log if the player moves the mouse
	
	var sensitivity = .0014 # sensitivity of the cursor
	
	if event is InputEventMouseMotion: # Function only detects if mouse is moved not every other action or key pressed
		rotate_y(-event.relative.x * sensitivity) # Rotates the character left or right, relative is how many pixels the mouse moved
		
		
		pitch -= event.relative.y * sensitivity # Rotates only the camera up and down so player doesn't become flipped
		# Event is a log of if the action happened such as cursor moving 1 pixel or 50, relative to x or y is what axis we want to move on
		pitch = clamp(pitch, deg_to_rad(-89), deg_to_rad(89)) # Clams the camera from going above 90 or below -90 degrees preventing flipping of camera
		
		camera.rotation.x = pitch # allows cameras rotation to be the value of pitch
		

# Movement/Jump

# Allows us to use delta which is keeps everything consistent allowing movement to be seperated from framerate
func _physics_process(delta): # Multiplication by delta keeps things constant regardless of fps(Not used for movement move_and_slide() does that)
	
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
	velocity.x = direction.x * 5 # Speed Stat for up and down
	velocity.z = direction.z * 5 # Speed stat for left and right
	
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
	
	if hovered_object != null:
		hovered_object.toggle_glow(false)
		hovered_object = null
	
	if target.interaction_type == "Collect":
		inventory.append(target.item_name)
		print("Pickedf up:", target.item_name)
		target.queue_free() #Makes it dissapear
		hovered_object = null
		tasks_completed += 1
		check_win_condition()
	
	elif target.interaction_type == "Animate":
		var anim_player = null
		
		for child in target.get_children():
			if child is AnimationPlayer:
				anim_player = child
				break

		if anim_player != null:
			anim_player.play(target.animation_to_play)
			
			check_win_condition()
		else:
			print("Error: No AnimationPlayer node found inside " + target.name)
	
	elif target.interaction_type == "Explode":
		current_hold_time = 0.0
		
		interaction_bar.hide()
		$CanvasLayer2/InteractionUI/InteractionLabel.hide()
		
		explode.visible = true
		await get_tree().create_timer(1.0).timeout
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
	if tasks_completed >= 1  :
		get_tree().paused = true
		interaction_bar.hide()
		$CanvasLayer2/InteractionUI/InteractionLabel.hide()
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		if win_screen != null:
			win_screen.trigger_win_screen()
		else:
			print("Error: End Screen node not assigned in Player Inspector!")
