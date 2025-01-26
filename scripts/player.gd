class_name Player
extends CharacterBody2D

const SPEED = 100.0
const JUMP_VELOCITY = -300.0
const FLUTTER_POWER = 100.0
const FLOOR_FRICTION = 200
const SLIDE_SPEED = 200
const MIN_BUBBLE_POWER = 500
const MAX_BUBBLE_POWER = 900

const ANI_FLUTTER_LEFT = "going_left"
const ANI_FLUTTER_RIGHT = "going_right"
const ANI_BLOW_STANDING = "ready_to_blow"
const ANI_BLOW_WALKING = "blowing_walking"
const ANI_STANDING = "standing_still"
const ANI_WALKING = "walking"
const ANI_FALLING_FORWARD = "falling_face_forward"
const ANI_FALLING_BACKWARD = "Falling_backwards"

@onready var bubble : Bubble = %Bubble
@onready var sprite : AnimatedSprite2D = %AnimatedSprite2D
@onready var jump_sound: AudioStreamPlayer2D = %JumpSoundEffect
@onready var slide_sound: AudioStreamPlayer2D = %SlidingSoundEffect

var vel = Vector2(0, 0)
var just_copied = false
var bubble_starting: Vector2
var player_sprite_starting: Vector2
var previously_on_floor: bool
var sliding = false
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

var base_gravity: float = Global.gravity
var gravity: float:
	get():
		if bubble_size > 0:
			return base_gravity - lerpf(MIN_BUBBLE_POWER, MAX_BUBBLE_POWER, min(bubble_size, 1))
		else:
			return base_gravity

func _ready() -> void:
	var player_data = Global.pop_player_data()
	if player_data != null:
		copy_struct(player_data)
		just_copied = true
	bubble_starting = bubble.position
	player_sprite_starting = sprite.position
	previously_on_floor = is_on_floor()

func create_struct() -> PlayerStruct:
	var struct: PlayerStruct = PlayerStruct.new()
	
	struct.position = position
	struct.velocity = velocity
	
	struct.vel = vel
	struct.sliding = sliding
	struct.bubble_size = bubble_size
	struct.blowing_bubble = blowing_bubble
	struct.flipped = sprite.flip_h
	struct.animation = sprite.animation
	
	return struct

func copy_struct(struct: PlayerStruct):
	position = struct.position
	velocity = struct.velocity
	
	vel = struct.vel
	sliding = struct.sliding
	bubble.bubble_size = struct.bubble_size
	bubble.blowing_bubble = struct.blowing_bubble
	sprite.flip_h = struct.flipped
	sprite.animation = struct.animation
	
	bubble.update()

func _physics_process(delta: float) -> void:
	if not is_on_floor() and not just_copied:
		vel = get_real_velocity()
		
	if just_landed_on_floor:
		if get_real_velocity().length_squared() >= SLIDE_SPEED * SLIDE_SPEED:
			sliding = true
			slide_sound.play(0)
		
	if sliding:
		if not just_copied:
			vel = get_real_velocity()
		vel.x = move_toward(vel.x, 0, delta * FLOOR_FRICTION)
		if vel.x == 0:
			vel.y = 0
			sliding = false
			slide_sound.stop()
		elif vel.x > 0 or (sprite.flip_h and vel.x < 0):
			sprite.play(ANI_FALLING_FORWARD)
		else:
			sprite.play(ANI_FALLING_BACKWARD)

		
	handle_bubble_blowing(delta)
	handle_jumping()

	if is_on_floor():
		handle_walking()
	else:
		handle_fluttering(delta)
	
	handle_sprite_offsets()
	vel.y = min(vel.y + gravity * delta, gravity / 2)
	previously_on_floor = is_on_floor()
	just_copied = false
	
	velocity = vel
	move_and_slide()
	
func handle_bubble_blowing(delta: float):
	var just_pressed_jump = Input.is_action_just_pressed("Jump")
	var just_released_jump = Input.is_action_just_released("Jump")
	
	if is_on_floor() and just_pressed_jump and not sliding:
		blowing_bubble = true
	elif just_released_jump:
		blowing_bubble = false
	
	if just_landed_on_floor:
		bubble.pop_bubble()
		
	if bubble_size > 0:
		gravity = base_gravity - lerpf(MIN_BUBBLE_POWER, MAX_BUBBLE_POWER, min(bubble_size, 1))
	else:
		gravity = base_gravity

func handle_sprite_offsets():
	const BUBBLE_BLOWING_OFFSET_Y = 7
	const BUBBLE_FLUTTER_LEFT_OFFSET_X = -4
	const BUBBLE_FLUTTER_RIGHT_OFFSET_X = 2
	const BUBBLE_FLIP_OFFSET = -21
	const FALLING_OFFSET_Y = 20
	
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
	
	var sprite_y = player_sprite_starting.y
	if sliding:
		sprite_y += FALLING_OFFSET_Y
		
	sprite.position.y = sprite_y
	

func handle_jumping():
	var just_pressed_jump = Input.is_action_just_pressed("Jump")
	var just_released_jump = Input.is_action_just_released("Jump")
	var on_floor = is_on_floor()
	
	if just_released_jump and on_floor and not sliding:
		vel.y = JUMP_VELOCITY
		jump_sound.play(0.3)
	elif just_pressed_jump and not blowing_bubble and not on_floor and bubble_size > 0:
		bubble.pop_bubble()
	
	
func handle_fluttering(delta: float):	
	var direction = Input.get_axis("Left", "Right")
	var flipped = sprite.flip_h
	
	vel.x += direction * delta * FLUTTER_POWER
	
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
	elif vel.x > 0:
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
	if sliding:
		return
		
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
		vel.x = direction * SPEED
	else:
		vel.x = move_toward(vel.x, 0, SPEED)
