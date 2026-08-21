extends CharacterBody2D

@export var jump_velocity := -250.0
@export var horiz_speed := 300.0
@export var air_deceleration := 0.1
@export var floor_deceleration := 10.0
@export var walking_acceleration := 15.0
@export var running_acceleration := 15.0
@export var jump_charge_rate := 2.0
@export var coyote_time := 0.2
@export var landing_time := 0.2
@export var air_acceleration := 3.0

const MAX_JUMP_CHARGE := 2.0
const INIT_JUMP_CHARGE := 1.0
const MAX_WALKING_SPEED := 50.0
const MAX_RUNNING_SPEED := 150.0
const MAX_AIR_SPEED := MAX_RUNNING_SPEED
const MAX_AIR_SPEED_ADDITION := 20.0

var jump_charge := INIT_JUMP_CHARGE

var coyote_timer := 0.0

var landing_timer := 0.0

enum State {
	IDLE,
	WALKING,
	CHARGING,
	JUMPING,
	RUNNING,
	FALLING,
	LANDING
}

var prev_state := State.IDLE
var state := State.IDLE

func _physics_process(delta: float) -> void:
	
	coyote_timer = max(coyote_timer - delta, 0.0)
	landing_timer = max(landing_timer - delta, 0.0)

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
			
		State.FALLING:
			falling(delta)
		
		State.LANDING:
			landing()
			
	move_and_slide()
	

func idle(_delta):
	decelerate(floor_deceleration)
		
	var direction := Input.get_axis("move_left", "move_right")

	if Input.is_action_pressed("run") and direction:
		_change_state(State.RUNNING)
		return

	if direction:
		_change_state(State.WALKING)
		return
	
	if Input.is_action_just_pressed("jump"):
		_change_state(State.CHARGING)
		return
		
			
	if not is_on_floor():
		_change_state(State.FALLING)
		return
		
func walking(_delta):
	var direction := Input.get_axis("move_left", "move_right")
	

	
	if direction:
		$AnimatedSprite2D.flip_h = direction < 0
	
	if not direction:
		_change_state(State.IDLE)
		return
		

	accelerate(direction, MAX_WALKING_SPEED, walking_acceleration)
	
	if Input.is_action_just_pressed("jump"):
		_change_state(State.CHARGING)
		return
		
	if Input.is_action_just_pressed("run"):
		_change_state(State.RUNNING)
		return
		
	if not is_on_floor():
		_change_state(State.FALLING)
		return
	
func jumping(delta: float):
	apply_gravity(delta)
	
	var direction := Input.get_axis("move_left", "move_right")
	
	air_movement()
	
	if velocity.y >= 0:
		_change_state(State.FALLING)
		return
		
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
		
	if not is_on_floor() and prev_state != State.FALLING:
		_change_state(State.FALLING)
		return

func get_state_name(state_var: State) -> String:
	return State.find_key(state_var)
	
func print_state() -> void:
	print(get_state_name(prev_state), "->", get_state_name(state))
 
	
func accelerate(direction, max_speed, acceleration):
	velocity.x = move_toward(velocity.x, direction * max_speed, acceleration)

func decelerate(deceleration):
	velocity.x = move_toward(velocity.x, 0, deceleration)

func falling(delta):
	apply_gravity(delta)
	
	air_movement()
	
	if Input.is_action_just_pressed("jump") and coyote_timer > 0:
		_change_state(State.CHARGING)
		return
		
	if is_on_floor():
		_change_state(State.LANDING)
	return
	
func apply_gravity(delta: float):
	velocity += get_gravity() * delta
	
func _change_state(new_state: State):
	
	$AnimatedSprite2D.stop()

	prev_state = state
	state = new_state
	print_state()
	_enter_state(state)


func _enter_state(entered_state: State):
	match entered_state:
		State.CHARGING:
			jump_charge = INIT_JUMP_CHARGE
			$AnimatedSprite2D.play("charging")
		State.FALLING:
			$AnimatedSprite2D.play("fall")
			if prev_state == State.WALKING or prev_state == State.RUNNING:
				coyote_timer = coyote_time
		State.WALKING:
			$AnimatedSprite2D.play("walk")
		State.IDLE:
			$AnimatedSprite2D.play("idle")
		State.LANDING:
			decelerate(floor_deceleration)
			$AnimatedSprite2D.play("landing")
			landing_timer = landing_time
		State.RUNNING:
			$AnimatedSprite2D.play("run")
	

func air_movement():
	var direction = Input.get_axis("move_left", "move_right")

	if direction:
		velocity.x = min(move_toward(velocity.x, direction * (abs(velocity.x) + MAX_AIR_SPEED_ADDITION), air_acceleration), MAX_AIR_SPEED)

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
		_change_state(State.FALLING)

func landing():
	if not is_on_floor():
		_change_state(State.FALLING)
	
	if landing_timer <= 0:
		var direction := Input.get_axis("move_left", "move_right")

		if direction:
			_change_state(State.WALKING)
		else:
			_change_state(State.IDLE)
