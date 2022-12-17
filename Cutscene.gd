extends Node2D

export(Array, String) var dialogue

var state :int = 0
var animation_playback

onready var dialogueSFX = [$robot_talk_1, $robot_talk_2, $robot_talk_3]

func _ready():
	$Dialogue.text = dialogue[state]
	animation_playback = $Sprite/AnimationTree.get("parameters/playback")
	print(dialogueSFX)

func _input(event):
	if (event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed) \
			or event.is_action_pressed("ui_accept"):
		state += 1
		if state == dialogue.size():
			LevelManager.next_level()
		else:
			$Dialogue.text = dialogue[state]
			animation_playback.travel("talk")
			dialogueSFX[state % 3].play()

