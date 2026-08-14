extends CharacterBody2D

@export var jump_velocity := -400.0
@export var horiz_speed := 300.0
@export var air_deceleration := 2.0
@export var floor_deceleration := 10.0
@export var walking_acceleration := 15.0
@export var running_acceleration := 30.0
@export var jump_charge_rate := 2.0

const MAX_JUMP_CHARGE := 2.0
const INIT_JUMP_CHARGE := 1.0
const MAX_WALKING_SPEED := 200.0
const MAX_RUNNING_SPEED := 600.0

var jump_charge := INIT_JUMP_CHARGE

enum State {
	IDLE,
	WALKING,
	CHARGING,
	JUMPING,
	RUNNING
}

var prev_state := State.IDLE
var state := State.IDLE

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
			
		State.RUNNING:
			running(delta)
	move_and_slide()
	

func idle(_delta):
	decelerate(floor_deceleration)
	
	var direction := Input.get_axis("move_left", "move_right")

	if direction:
		_change_state(State.WALKING)
		return
	
	if Input.is_action_just_pressed("jump"):
		_change_state(State.CHARGING)
		jump_charge = INIT_JUMP_CHARGE
		return
			
	if not is_on_floor():
		fall()
		
func walking(_delta):
	var direction := Input.get_axis("move_left", "move_right")
	
	if not direction:
		_change_state(State.IDLE)
		return
		

	accelerate(direction, MAX_WALKING_SPEED, walking_acceleration)
	
	if Input.is_action_just_pressed("jump"):
		_change_state(State.CHARGING)
		jump_charge = INIT_JUMP_CHARGE
		return
		
	if Input.is_action_just_pressed("run"):
		_change_state(State.RUNNING)
		return
		
	if not is_on_floor():
		fall()
	
func jumping(delta: float):
	velocity += get_gravity() * delta
	var direction = Input.get_axis("move_left", "move_right")

	decelerate(air_deceleration)
	
	if direction:
		accelerate(direction, MAX_WALKING_SPEED, walking_acceleration)
		
	if is_on_floor():
		if direction:
			_change_state(State.WALKING)
		else:
			_change_state(State.IDLE)

	
func charging(delta):
	var direction := Input.get_axis("move_left", "move_right")
	
	if prev_state == State.RUNNING:
		accelerate(direction, MAX_RUNNING_SPEED, running_acceleration)
	else:
		accelerate(direction, MAX_WALKING_SPEED, walking_acceleration)

	
	# Charge
	jump_charge += jump_charge_rate * delta
	jump_charge = min(jump_charge, MAX_JUMP_CHARGE)

	# Release
	if Input.is_action_just_released("jump"):
		velocity.y = jump_charge * jump_velocity
		_change_state(State.JUMPING)
		return

func get_state_name(state_var: State) -> String:
	return State.find_key(state_var)
	
func print_state() -> void:
	print(get_state_name(prev_state), "->", get_state_name(state))
 
	
func accelerate(direction, max_speed, acceleration):
	velocity.x = move_toward(velocity.x, direction * max_speed, acceleration)

func decelerate(deceleration):
	velocity.x = move_toward(velocity.x, 0, deceleration)

func fall():
	_change_state(State.JUMPING)
	return
	
func _change_state(new_state):
	prev_state = state
	state = new_state
	
	match state:
		State.CHARGING:
			jump_charge = INIT_JUMP_CHARGE
	
	print_state()

func running(_delta: float):
	var direction := Input.get_axis("move_left", "move_right")
	
	if not direction:
		_change_state(State.IDLE)
		return
		
	accelerate(direction, MAX_RUNNING_SPEED, running_acceleration)
	
	if Input.is_action_just_released("run"):
		_change_state(State.WALKING)
		return
	
	if Input.is_action_just_pressed("jump"):
		_change_state(State.CHARGING)
		return
		
	if not is_on_floor():
		fall()
