extends Node2D

@onready var label = %Label
var paused = false

func _process(delta: float) -> void:
	if not paused:
		var total_seconds = Time.get_ticks_msec() / 1000
		var minutes = floor(total_seconds / 60)
		var seconds = total_seconds - minutes * 60
		label.text = str(minutes) + ":" + ("0" if seconds < 10 else "") + str(seconds)
	
