extends Area2D

enum NextSceneDirection {
	UP,
	DOWN,
	LEFT,
	RIGHT
}

@export var next_scene_direction: NextSceneDirection = NextSceneDirection.UP
@export var scene_number: int = 0

var player: Player = null
var wait_for_exit = false

func _physics_process(_delta: float) -> void:
	if player == null:
		return
	
	match next_scene_direction:
		NextSceneDirection.UP:
			if player.position.y > 0:
				return
			player.position.y += Global.height
		NextSceneDirection.DOWN:
			if player.position.y < Global.height:
				return
			player.position.y -= Global.height
		NextSceneDirection.LEFT:
			if player.position.x > 0:
				return
			player.position.x += Global.width
		NextSceneDirection.RIGHT:
			if player.position.x < Global.width:
				return
			player.position.x -= Global.width
			
	Global.push_player_data(player.create_struct())
	Global.switch_scene(scene_number)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player = body


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player = null
