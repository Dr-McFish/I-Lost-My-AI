extends Control

var avalible_blocks
var block_buttons = []

onready var level = get_parent()
onready var BlockButton = preload("res://Resourses/BlockButton.tscn")


# Called when the node enters the scene tree for the first time.
func _ready():
	avalible_blocks = [level.avalibe_CCW_blocks, level.avalibe_CW_blocks, \
						level.avalibe_PAUSE_blocks, level.avalibe_PLAY_blocks, \
						level.avalibe_REPLICATE_blocks]
	
	for i in range(5):
		var block_button = BlockButton.instance()
		$HBoxContainer.add_child(block_button)
		block_button.set_type(i+1)
		block_button.update_count(avalible_blocks[i])
		if avalible_blocks[i] == 0:
			block_button.disable()
		block_button.connect("pressed", self, "_some_button_pressed", [block_button])
		block_buttons.append(block_button)

func _some_button_pressed(block_button):
	if block_button.pressed:
		level.selected_tile = block_button.type
		for us_button in block_buttons:
			if us_button != block_button:
				us_button.pressed = false
	else:
		level.selected_tile = null
		

func dec_block_count(type:int):
	avalible_blocks[type] -= 1
	block_buttons[type].update_count(avalible_blocks[type])
	if avalible_blocks[type] == 0:
		level.selected_tile = null

func _on_StartButton_pressed():
	level.start()
	visible = false
