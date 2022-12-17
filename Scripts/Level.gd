extends Node2D

export var avalibe_CCW_blocks :int
export var avalibe_CW_blocks :int
export var avalibe_PAUSE_blocks :int
export var avalibe_PLAY_blocks :int
export var avalibe_REPLICATE_blocks :int

enum PLAY_MODE{PLACE_BLOCKS, WATCH_ROBOT}
var play_mode

var selected_tile = null
var number_of_floppies

signal start

func _ready():
	play_mode = PLAY_MODE.PLACE_BLOCKS
	
	var pause_menu = load("res://Menus/Pause Menu.tscn").instance()
	add_child(pause_menu)

func _on_WallMap_level_compleated():
	for robot in RobotVariables.RobotInstanceList:
		robot.pause()
	
	var lvl_end_menu = load("res://Menus/Level End Menu.tscn").instance()
	get_tree().current_scene.add_child(lvl_end_menu)
	lvl_end_menu.popup()

func level_fail():
	var lvl_fail_menu = load("res://Menus/Fail Menu.tscn").instance()
	get_tree().current_scene.add_child(lvl_fail_menu)
	lvl_fail_menu.popup()

func start():
	play_mode = PLAY_MODE.WATCH_ROBOT
	emit_signal("start")

func dec_block_count():
	$"Place Blocks UI".dec_block_count(selected_tile-1)

