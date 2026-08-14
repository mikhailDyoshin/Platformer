extends CharacterBody2D

@export var jump_velocity := -400.0
@export var horiz_speed := 200.0
@export var deceleration := 10.0
@export var acceleration := 10.0
@export var jump_charge_rate := 2.0

const MAX_JUMP_CHARGE := 2.0
const INIT_JUMP_CHARGE := 1.0
const MAX_WALKING_SPEED := 200.0

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
		return
	
	if not is_on_floor():
		fall()
		
func walking(delta):
	var direction := Input.get_axis("move_left", "move_right")
	
	if not direction:
		state = State.IDLE
		print_state()
		return
		
	accelerate_walk(direction)
	
	if Input.is_action_just_pressed("jump"):
		state = State.CHARGING
		jump_charge = INIT_JUMP_CHARGE
		print_state()
		
	if not is_on_floor():
		fall()
	
func jumping(delta: float):
	velocity += get_gravity() * delta
	var direction = Input.get_axis("move_left", "move_right")
	
	if direction:
		accelerate_walk(direction)
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
	var direction := Input.get_axis("move_left", "move_right")
	accelerate_walk(direction)
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
 
func accelerate_walk(direction):
	var data = {"v": velocity.x, "max_v": direction * MAX_WALKING_SPEED, "a": direction * acceleration}
	var text = "v: {v}\nmax_v: {max_v}\na: {a}".format(data)
	print(data)
	velocity.x = direction * move_toward(abs(velocity.x), MAX_WALKING_SPEED, acceleration)

func decelerate():
	velocity.x = move_toward(velocity.x, 0, deceleration)

func fall():
	state = State.JUMPING
	jump_charge = INIT_JUMP_CHARGE
	print_state()
	return
