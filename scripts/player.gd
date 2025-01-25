extends CharacterBody2D

const SPEED = 100.0
const JUMP_VELOCITY = -300.0
const FLUTTER_POWER = 100.0
const MIN_BUBBLE_POWER = 500
const MAX_BUBBLE_POWER = 900

const ANI_FLUTTER_LEFT = "going_left"
const ANI_FLUTTER_RIGHT = "going_right"
const ANI_BLOW_STANDING = "ready_to_blow"
const ANI_BLOW_WALKING = "blowing_walking"
const ANI_STANDING = "standing_still"
const ANI_WALKING = "walking"

@onready var bubble : Bubble = %Bubble
@onready var sprite : AnimatedSprite2D = %AnimatedSprite2D

var bubble_starting: Vector2
var previously_on_floor: bool
var sprite_crouching: bool:
	get():
		return sprite.animation == ANI_BLOW_STANDING or \
			sprite.animation == ANI_BLOW_WALKING
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

func _ready() -> void:
	bubble_starting = bubble.position
	previously_on_floor = is_on_floor()

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity = get_real_velocity()
		
	handle_bubble_blowing(delta)
	handle_jumping()
	
	if is_on_floor():
		handle_walking()
	else:
		handle_fluttering(delta)
	
	handle_bubble_offsets()
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

func handle_bubble_offsets():
	const BUBBLE_BLOWING_OFFSET_Y = 7
	const BUBBLE_FLUTTER_LEFT_OFFSET_X = -4
	const BUBBLE_FLUTTER_RIGHT_OFFSET_X = 2
	const BUBBLE_FLIP_OFFSET = -21
	
	var x_offset: float = 0
	var y_offset: float = 0
	
	if sprite_crouching:
		y_offset += BUBBLE_BLOWING_OFFSET_Y
	 	
	if sprite.animation == ANI_FLUTTER_LEFT:
		x_offset += BUBBLE_FLUTTER_LEFT_OFFSET_X
	elif sprite.animation == ANI_FLUTTER_RIGHT:
		x_offset += BUBBLE_FLUTTER_RIGHT_OFFSET_X
			
	var y_pos = bubble_starting.y + y_offset
	var x_pos = 0.0
	if sprite.flip_h:
		x_pos = bubble_starting.x + BUBBLE_FLIP_OFFSET - x_offset
	else:
		x_pos = bubble_starting.x + x_offset
	
	bubble.position = Vector2(x_pos, y_pos)
	bubble.sprite.flip_h = sprite.flip_h

func handle_jumping():
	var just_pressed_jump = Input.is_action_just_pressed("Jump")
	var just_released_jump = Input.is_action_just_released("Jump")
	var on_floor = is_on_floor()
	
	if just_released_jump and on_floor:
		velocity.y = JUMP_VELOCITY
	elif just_pressed_jump and not blowing_bubble and not on_floor and bubble_size > 0:
		bubble.pop_bubble()
	
	
func handle_fluttering(delta: float):	
	var direction = Input.get_axis("Left", "Right")
	var flipped = sprite.flip_h
	
	velocity.x += direction * delta * FLUTTER_POWER
	
	if direction > 0:
		if flipped:
			sprite.play(ANI_FLUTTER_LEFT)
		else:
			sprite.play(ANI_FLUTTER_RIGHT)
	elif direction < 0:
		if flipped:
			sprite.play(ANI_FLUTTER_RIGHT)
		else:
			sprite.play(ANI_FLUTTER_LEFT)
	elif velocity.x > 0:
		if flipped:
			sprite.play(ANI_FLUTTER_LEFT)
		else:
			sprite.play(ANI_FLUTTER_RIGHT)
		sprite.stop()
	else:
		if flipped:
			sprite.play(ANI_FLUTTER_RIGHT)
		else:
			sprite.play(ANI_FLUTTER_LEFT)
		sprite.stop()
		

func handle_walking():
	var direction = Input.get_axis("Left", "Right")
	
	if blowing_bubble and direction == 0:
		sprite.play(ANI_BLOW_STANDING)
	elif blowing_bubble and direction != 0:
		sprite.play(ANI_BLOW_WALKING)
	elif not blowing_bubble and direction == 0:
		sprite.play(ANI_STANDING)
	elif not blowing_bubble and direction != 0:
		sprite.play(ANI_WALKING)
		
	if not sprite.flip_h:
		sprite.flip_h = direction < 0
	else:
		sprite.flip_h = direction <= 0
	
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
