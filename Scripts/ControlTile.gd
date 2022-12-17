extends Sprite

enum CONTROL_TILE{LEVEL_EXIT, TURN_CCW, TURN_CW, PAUSE, PLAY, REPLICATE}
var ct_type : int

func set_type(tile_type: int) :
	ct_type = tile_type
	frame = tile_type

