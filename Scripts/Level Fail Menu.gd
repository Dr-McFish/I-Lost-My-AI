extends Control

func _ready():
	#$VBoxContainer/HBoxContainer/MainMenu.grab_focus()
	pass
	
func _on_Main_Menu_pressed():
	LevelManager.chnge_level(0)

func _on_Retry_pressed():
	RobotVariables.reset()
	get_tree().reload_current_scene()
