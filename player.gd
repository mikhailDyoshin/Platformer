extends CharacterBody2D

@export var jump_velocity := -400.0
@export var horiz_speed := 200.0
@export var deceleration := 10.0
@export var jump_charge_rate := 4.0

const MAX_JUMP_CHARGE := 2.0
const INIT_JUMP_CHARGE := 1.0

var jump_charge := INIT_JUMP_CHARGE

enum State {
	IDLE,
	WALKING,
	CHARGING,
	JUMPING,
	RUNNING
}

var state := State.JUMPING

func _physics_process(delta: float) -> void:

	match state:
		State.IDLE:
			idle(delta)
			
		State.WALKING:
			walking(delta)
			
		State.CHARGING:
			charging(delta)

		State.JUMPING:
			jumping(delta)
	move_and_slide()
	

func idle(delta):
	velocity.x = move_toward(velocity.x, 0, deceleration)
	
	var direction := Input.get_axis("move_left", "move_right")

	if direction:
		state = State.WALKING
		print_state()
		return
	
	if Input.is_action_just_pressed("jump"):
		state = State.CHARGING
		jump_charge = INIT_JUMP_CHARGE
		print_state()
		
func walking(delta):
	var direction := Input.get_axis("move_left", "move_right")
	
	if not direction:
		state = State.IDLE
		print_state()
		return
		
	velocity.x = direction * horiz_speed
	
	if Input.is_action_just_pressed("jump"):
		state = State.CHARGING
		jump_charge = INIT_JUMP_CHARGE
		print_state()
	
func jumping(delta: float):
	velocity += get_gravity() * delta
	var direction = Input.get_axis("move_left", "move_right")
	
	if direction:
		velocity.x = direction * horiz_speed
	else:
		velocity.x = move_toward(velocity.x, 0, deceleration)
		
	if is_on_floor():
		if direction:
			state = State.WALKING
			print_state()
		else:
			state = State.IDLE
			print_state()
	
#func running(delta):
	#pass
	
func charging(delta):
	velocity.x = move_toward(velocity.x, 0, deceleration)
	# Charge
	jump_charge += jump_charge_rate * delta
	jump_charge = min(jump_charge, MAX_JUMP_CHARGE)

	# Release
	if Input.is_action_just_released("jump"):
		velocity.y = jump_charge * jump_velocity
		state = State.JUMPING
		print_state()

func get_state_name(state: State) -> String:
	return State.find_key(state)
	
func print_state():
	print(get_state_name(state))
