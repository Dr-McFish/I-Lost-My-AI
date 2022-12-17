extends Node

var RobotInstanceList = []
var good_bot_count = 0
enum CONTROL_COMMAND{TURN_CCW, TURN_CW, PAUSE, PLAY, EXPLODE}

func reset():
	RobotInstanceList = []
	good_bot_count = 0
