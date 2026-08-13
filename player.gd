extends CharacterBody2D



@export var jump_velocity = -400.0
@export var horiz_speed = 200.0
@export var deceleration = 10.0

const JUMP_POWER_LIMIT = 2.0
var jump_power = 0.0
@export var jump_power_step = 8

func _physics_process(delta: float) -> void:
	
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	#if Input.is_action_just_pressed("jump") and is_on_floor():
		#velocity.y = jump_velocity
		
	if Input.is_action_pressed("jump") and is_on_floor():
		jump_power += jump_power_step * delta 
		
		if jump_power > JUMP_POWER_LIMIT:
			jump_power = JUMP_POWER_LIMIT
		
		
		
	if Input.is_action_just_released("jump") and is_on_floor():
		print(jump_power)
		velocity.y = jump_power * jump_velocity
		jump_power = 0

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * horiz_speed
	else:
		velocity.x = move_toward(velocity.x, 0, deceleration)

	move_and_slide()
