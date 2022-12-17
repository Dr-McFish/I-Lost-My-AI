extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	for button in get_tree().get_nodes_in_group("lvl_scelect_buttons"):
		button.connect("pressed", self, "_some_button_pressed", [button])
	
func _some_button_pressed(button):
	LevelManager.chnge_level(int(button.name))

func _on_BackButton_pressed():
	get_tree().change_scene("res://Menus/Start Menu.tscn")
