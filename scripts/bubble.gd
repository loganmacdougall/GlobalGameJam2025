class_name Bubble
extends Area2D

const BLOW_RATE = 0.5
const POP_SIZE = 1.25

@onready var sprite = %AnimatedSprite2D
@onready var ColShape0: CollisionShape2D = %ColShape0
@onready var ColShape1: CollisionShape2D = %ColShape1
@onready var ColShape2: CollisionShape2D = %ColShape2
@onready var ColShape3: CollisionShape2D = %ColShape3
@onready var ColShape4: CollisionShape2D = %ColShape4
@onready var ColShape5: CollisionShape2D = %ColShape5

var bubble_size = 0.0
var blowing_bubble = false

var bubble_frame : int : 
	get():
		return min(floor(bubble_size * 5), 5)

var grow_animation_name : String : 
	get():
		return "grow_" + str(bubble_frame)

var pop_animation_name : String : 
	get():
		return "pop_" + str(bubble_frame)	

func _ready() -> void:
	activate_correct_collider()
	visible = false

func _process(delta: float):
	if blowing_bubble:
		bubble_size += BLOW_RATE * delta
		sprite.play(grow_animation_name)
		activate_correct_collider()
		
	if bubble_size > 0:
		visible = true
		
	if bubble_size >= POP_SIZE:
		pop_bubble()

func update():
	if bubble_size > 0:
		sprite.play(grow_animation_name)
	else:
		visible = false
	activate_correct_collider()

func activate_correct_collider():
	var CollisionList = [ColShape0, ColShape1, ColShape2, ColShape3, ColShape4, ColShape5]
	
	var current_bubble_frame = bubble_frame if bubble_size > 0 else -1
	for i in range(CollisionList.size()):
		var col: CollisionShape2D = CollisionList[i]
		var col_disabled = i != current_bubble_frame
		var needs_change = col.disabled != col_disabled
		if needs_change:
			col.set_deferred("disabled", col_disabled)

func pop_bubble():
	sprite.play(pop_animation_name)
	blowing_bubble = false
	bubble_size = 0
	activate_correct_collider()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		return
	
	pop_bubble()


func _on_animation_finished() -> void:
	visible = false
