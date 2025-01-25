extends Node

var _player: Node2D = null

var width = ProjectSettings.get_setting("display/window/size/viewport_width")
var height = ProjectSettings.get_setting("display/window/size/viewport_height")
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func save_player(player: Node2D):
	_player = player
	
func get_player():
	return _player

func switch_scenes(num: int):
	var scene_start = "res://scenes/floors/floor_"
	var scene_end = ".tscn"
	var scene_num = ("0" if num < 10 else "") + str(num)
	var scene = scene_start + scene_num + scene_end
	
	get_tree().change_scene_to_file(scene)
