extends Node

var width = ProjectSettings.get_setting("display/window/size/viewport_width")
var height = ProjectSettings.get_setting("display/window/size/viewport_height")
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var player_struct: PlayerStruct = null

func push_player_data(player: PlayerStruct):
	player_struct = player

func pop_player_data() -> PlayerStruct:
	var p = player_struct
	player_struct = null
	return p

func switch_scene(scene_number:int):
	var scene_start = "res://scenes/floors/floor_"
	var scene_end = ".tscn"
	var scene_num = ("0" if scene_number < 10 else "") + str(scene_number)
	var scene = scene_start + scene_num + scene_end
	
	get_tree().change_scene_to_file(scene)
