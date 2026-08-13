extends CharacterBody2D

@export var jump_velocity := -400.0
@export var horiz_speed := 200.0
@export var deceleration := 10.0
@export var jump_charge_rate := 4.0

const MAX_JUMP_CHARGE := 2.0
const INIT_JUMP_CHARGE := 1.0

var jump_charge := INIT_JUMP_CHARGE
var is_charging_jump := false


func _physics_process(delta: float) -> void:

	# Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Start charging
	if Input.is_action_just_pressed("jump") and is_on_floor():
		is_charging_jump = true
		jump_charge = INIT_JUMP_CHARGE
		

	# Charge
	if Input.is_action_pressed("jump") and is_charging_jump:
		jump_charge += jump_charge_rate * delta
		jump_charge = min(jump_charge, MAX_JUMP_CHARGE)

	# Release
	if Input.is_action_just_released("jump") and is_charging_jump:
		velocity.y = jump_charge * jump_velocity
		jump_charge = INIT_JUMP_CHARGE
		is_charging_jump = false

	# Horizontal movement
	var direction := Input.get_axis("move_left", "move_right")

	if direction:
		velocity.x = direction * horiz_speed
	else:
		velocity.x = move_toward(velocity.x, 0, deceleration)

	move_and_slide()
