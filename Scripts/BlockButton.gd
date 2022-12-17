extends Button

enum CTRL_TILE_TYPE{TURN_CCW, TURN_CW, PAUSE, PLAY, REPLICATE}

var type

func _ready():
	add_to_group("block_buttons")

# Called when the node enters the scene tree for the first time.
func set_type(t :int):
	if t != 0:
		type = t
		$Sprite.frame = t

func update_count(count :int):
	$Label.text = String(count)
	disabled = count == 0

func enable():
	disabled = false
	visible = true
	$Sprite.visible = true
	$Label.visible = true

func disable():
	disabled = true
	visible = false
	$Sprite.visible = false
	$Label.visible = false
