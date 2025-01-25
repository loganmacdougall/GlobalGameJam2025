extends CharacterBody2D

const SPEED = 100.0
const JUMP_VELOCITY = -400.0
const FLUTTER_POWER = 100.0
const MIN_BUBBLE_POWER = 500
const MAX_BUBBLE_POWER = 900

const ANI_FLUTTER_LEFT = "going_left"
const ANI_FLUTTER_RIGHT = "going_right"
const ANI_BLOW_STANDING = "ready_to_blow"
const ANI_STANDING = "standing_still"

@onready var bubble : Bubble = %Bubble
@onready var sprite : AnimatedSprite2D = %AnimatedSprite2D

var previously_on_floor = true
var just_landed_on_floor : bool : 
	get():
		return is_on_floor() and not previously_on_floor
var blowing_bubble: bool:
	get():
		return bubble.blowing_bubble
	set(v):
		bubble.blowing_bubble = v
var bubble_size: float:
	get():
		return bubble.bubble_size

var base_gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var gravity: float:
	get():
		if bubble_size > 0:
			return base_gravity - lerpf(MIN_BUBBLE_POWER, MAX_BUBBLE_POWER, min(bubble_size, 1))
		else:
			return base_gravity

func _physics_process(delta: float) -> void:
	handle_bubble_blowing(delta)
	handle_jumping()
	
	if is_on_floor():
		handle_walking()
	else:
		handle_fluttering(delta)
		
		
	velocity.y = min(velocity.y + gravity * delta, gravity / 2)
	previously_on_floor = is_on_floor()
	
	move_and_slide()
	
func handle_bubble_blowing(delta: float):
	var just_pressed_jump = Input.is_action_just_pressed("Jump")
	var just_released_jump = Input.is_action_just_released("Jump")
	
	if is_on_floor() and just_pressed_jump:
		blowing_bubble = true
	elif just_released_jump:
		blowing_bubble = false
	
	if just_landed_on_floor:
		bubble.pop_bubble()
		
	if bubble_size > 0:
		gravity = base_gravity - lerpf(MIN_BUBBLE_POWER, MAX_BUBBLE_POWER, min(bubble_size, 1))
	else:
		gravity = base_gravity

func handle_jumping():
	var just_pressed_jump = Input.is_action_just_pressed("Jump")
	var just_released_jump = Input.is_action_just_released("Jump")
	var on_floor = is_on_floor()
	
	if just_released_jump and on_floor:
		print(gravity)
		velocity.y = JUMP_VELOCITY
	elif just_pressed_jump and not blowing_bubble and not on_floor and bubble_size > 0:
		bubble.pop_bubble()
	
	
func handle_fluttering(delta: float):	
	var direction = Input.get_axis("Left", "Right")
	
	velocity.x += direction * delta * FLUTTER_POWER
	
	if direction > 0:
		sprite.play(ANI_FLUTTER_RIGHT)
	elif direction < 0:
		sprite.play(ANI_FLUTTER_LEFT)
	elif velocity.x > 0:
		sprite.play(ANI_FLUTTER_RIGHT)
		sprite.stop()
	else:
		sprite.play(ANI_FLUTTER_LEFT)
		sprite.stop()
		

func handle_walking():
	var direction = Input.get_axis("Left", "Right")
	
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
