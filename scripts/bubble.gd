extends Area2D

const BLOW_RATE = 0.5
const POP_SIZE = 1.25

@onready var sprite = %AnimatedSprite2D
var bubble_size = 0.0
var blowing_bubble = true

var bubble_frame : int : 
	get():
		return min(floor(bubble_size * 6), 5)

var grow_animation_name : String : 
	get():
		return "grow_" + str(bubble_frame)

var pop_animation_name : String : 
	get():
		return "pop_" + str(bubble_frame)	

func _process(delta: float):
	if blowing_bubble:
		bubble_size += BLOW_RATE * delta
		sprite.play(grow_animation_name)
		
func blow_bubble(value: bool):
	blowing_bubble = value
	
func pop_bubble():
	blowing_bubble = false
	sprite.play(pop_animation_name)
	bubble_size = 0
	
