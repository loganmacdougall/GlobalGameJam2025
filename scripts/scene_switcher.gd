extends Area2D

enum NextSceneDirection {
	UP,
	DOWN,
	LEFT,
	RIGHT
}

@export var next_scene_direction: NextSceneDirection = NextSceneDirection.UP
@export var scene_number: int = 0

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("Player"):
		return

	match next_scene_direction:
		NextSceneDirection.UP:
			body.y -= Global.height
		NextSceneDirection.DOWN:
			body.y += Global.height
		NextSceneDirection.LEFT:
			body.x += Global.width
		NextSceneDirection.RIGHT:
			body.x -= Global.width
			
	Global.save_player(body)
