extends Node2D

@onready var card = %Card
@onready var label = %Label

var starting_y: float
var x = 0.1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	starting_y = card.position.y
	label.text = "Time: " + Global.time_beaten

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	x += delta * 0.5
	if x < 4.6:
		card.position.y = starting_y + ((1/x) * cos(x)) * 50
	else:
		card.position.y = starting_y
