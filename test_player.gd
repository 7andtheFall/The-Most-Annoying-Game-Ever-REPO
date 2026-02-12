extends CharacterBody3D # Allows us to use the physics node for CharacterBody3D

@onready var camera = $Camera3D # onready makes the script wait until whole scene is loaded, $ means look for children node named Camera3D

var pitch = 0 # Variable pitch created, pitch determines how much the camera moves precisely instead of the camera doing said math

# Camera Controlls

func _ready():# Allow us to use ready function, letting us hide the mouse from the player while keeping it centered 
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED # Hides the mouse
	
	
func _input(event): #allows for us to log if the player moves the mouse
	
	var sensitivity = .0026 # sensitivity of the cursor
	
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
			
	move_and_slide() # Moves the player while handling collisions, used at end to ensure every key input is rendered with this
