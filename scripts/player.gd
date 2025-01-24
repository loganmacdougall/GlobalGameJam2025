extends CharacterBody2D

const SPEED = 100.0
const JUMP_VELOCITY = -400.0
const BLOW_RATE = 0.5

var blowing_bubble = false
var bubble_size = 0.0

func _physics_process(delta: float) -> void:
	var direction = Input.get_axis("Left", "Right")
	var pressing_jump = Input.is_action_pressed("Jump")
	var just_pressed_jump = Input.is_action_just_pressed("Jump")
	var just_released_jump = Input.is_action_just_released("Jump")
	var on_floor = is_on_floor()
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
	
func handle_blowing_bubble(delta: float):
	var just_pressed_jump = Input.is_action_just_pressed("Jump")
	var just_released_jump = Input.is_action_just_released("Jump")
	var on_floor = is_on_floor()
	
	if on_floor and just_pressed_jump:
		blowing_bubble = true
	elif just_released_jump:
		blowing_bubble = false
		
	if blowing_bubble:
		bubble_size += BLOW_RATE * delta
		
func handle_walking():
	pass
