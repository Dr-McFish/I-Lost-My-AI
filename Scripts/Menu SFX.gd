extends Node

# Called when the node enters the scene tree for the first time.
func _ready():
	for button in get_tree().get_nodes_in_group("menu_buttons"):
		button.connect("button_up", self, "_some_button_pressed", [button]) 

func _some_button_pressed(button):
	print("click")
	$Click.playing = true
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
