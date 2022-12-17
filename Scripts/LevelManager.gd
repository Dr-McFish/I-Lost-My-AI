extends Node

var current_level_idx : int = 0
const LevelList =  ["res://Menus/Start Menu.tscn",
					"res://Levels/Level 1.tscn",
					"res://Levels/Level 2.tscn",
					"res://Levels/Level 3.tscn",
					"res://Levels/Level 4.tscn",
					"res://Levels/Level 5.tscn",
					"res://Levels/Level 6.tscn",
					"res://Levels/Level 7.tscn",
					"res://Levels/Level 8.tscn",
					"res://Cutscenes/cutscene 2.tscn",
					"res://Menus/Credits.tscn",
					"res://Levels/Test Level.tscn"]

func chnge_level(lvl_idx :int):
	current_level_idx = lvl_idx
	get_tree().change_scene(LevelList[lvl_idx])
	RobotVariables.reset()

func next_level():
	chnge_level(current_level_idx + 1)
