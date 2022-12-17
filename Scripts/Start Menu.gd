extends Control

func _ready():
	$VBoxContainer/StartButton.grab_focus()

func _on_StartButton_pressed():
	get_tree().change_scene("res://Cutscenes/cutscene 1.tscn")
	#LevelManager.next_level()
	print("hello")

func _on_OptionButton_pressed():
	pass # TODO add options menu

func _on_QuitButon_pressed():
	get_tree().quit()

func _on_LeveSellectButton_pressed():
	get_tree().change_scene("res://Menus/Level Select Menu.tscn")
	
