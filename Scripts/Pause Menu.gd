extends Popup

func _input(event):
	if Input.is_action_just_pressed("ui_pause"):
		if not visible:
			popup()
			get_tree().paused = true
		else:
			visible = false
			get_tree().paused = false



func _on_MainMenu_pressed():
	get_tree().paused = false
	LevelManager.chnge_level(0)
	

func _on_Restart_pressed():
	get_tree().paused = false
	RobotVariables.reset()
	get_tree().reload_current_scene()
	

func _on_Resume_pressed():
	visible = false
	get_tree().paused = false
