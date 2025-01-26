extends Area2D

var player: Player = null

func _process(delta: float) -> void:
	if player == null:
		return
		
	if player.sliding or not player.is_on_floor():
		return
		
	Global.game_won()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player = body


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player = null
