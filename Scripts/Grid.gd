extends TileMap

var tile_size : Vector2 = get_cell_size()

var grid_size : Vector2 = Vector2(40, 32)
var grid = []
var ctrl_grid = []

var spike_cords : Array
var lever_cords : Array

const wall_tile_idxs = [1,2,3,4,5,6, 14]
const control_tile_idx = 13
const lever_idx = 11
const spike_idx = 7
const noctrl_idx = 16

enum GRID_OBJ_TYPE{PLAYER, OBSTACLE}
enum CTRL_TILE_TYPE{LEVEL_EXIT, TURN_CCW, TURN_CW, PAUSE, PLAY, REPLICATE, LEVER, SPIKES_ON, SPIKES_OFF, NO_CTRL}

onready var level = get_parent()
onready var RobotClone = preload("res://Resourses/Robot.tscn")
onready var EvilbotClone = preload("res://Resourses/EvilRobot.tscn")
onready var GridSFX = preload("res://Resourses/GridSFX.tscn")

signal level_compleated

func _ready():
	#var grid_sfx = GridSFX.instance()
	#add_child(GridSFX)
	
	for x in range(grid_size.x):
		grid.append([])
		ctrl_grid.append([])
		for y in range(grid_size.y):
			grid[x].append(null)
			ctrl_grid[x].append(null)
	
	var Player = get_node("Robot")
	var start_pos = update_child_pos(Player, Vector2.ZERO)
	Player.position = start_pos
	
	var wall_positions = []
	for n in wall_tile_idxs:
		wall_positions.append_array(get_used_cells_by_id(n))
	
	for pos in wall_positions:
		grid[pos.x][pos.y] = GRID_OBJ_TYPE.OBSTACLE;
	
	level.number_of_floppies = 0
	var ctrl_tile_positions = get_used_cells_by_id(control_tile_idx)
	for pos in ctrl_tile_positions:
		ctrl_grid[pos.x][pos.y] = get_cell_autotile_coord(pos.x, pos.y).y
		if ctrl_grid[pos.x][pos.y] == CTRL_TILE_TYPE.LEVEL_EXIT:
			level.number_of_floppies += 1
	
	ctrl_tile_positions = get_used_cells_by_id(lever_idx)
	for pos in ctrl_tile_positions:
		ctrl_grid[pos.x][pos.y] = CTRL_TILE_TYPE.LEVER
	lever_cords = ctrl_tile_positions
	
	ctrl_tile_positions = get_used_cells_by_id(noctrl_idx)
	for pos in ctrl_tile_positions:
		ctrl_grid[pos.x][pos.y] = CTRL_TILE_TYPE.NO_CTRL
	
	ctrl_tile_positions = get_used_cells_by_id(spike_idx)
	for pos in ctrl_tile_positions:
		if get_cell_autotile_coord(pos.x, pos.y).x == 0:
			ctrl_grid[pos.x][pos.y] = CTRL_TILE_TYPE.SPIKES_OFF
			#print(pos)
		else:
			ctrl_grid[pos.x][pos.y] = CTRL_TILE_TYPE.SPIKES_ON
	spike_cords = ctrl_tile_positions
	
	print(get_cell(0,0))


func _process(delta):
	var mouse_pos = get_viewport().get_mouse_position()/4
	if is_ctrl_cell_vacant(mouse_pos) and is_cell_vacant(mouse_pos, Vector2.ZERO) \
		and level.selected_tile != null and level.play_mode == level.PLAY_MODE.PLACE_BLOCKS:
		$mouse_indicator.visible = true
		$mouse_indicator.position = (mouse_pos - tile_size/2).snapped(tile_size) 
	else:
		$mouse_indicator.visible = false


func _input(event):
	if (event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed) \
	  and level.selected_tile != null and level.play_mode == level.PLAY_MODE.PLACE_BLOCKS:
		var mouse_pos = event.position/4
		if is_ctrl_cell_vacant(mouse_pos) and is_cell_vacant(mouse_pos, Vector2.ZERO):
			add_ctrl_tile(mouse_pos, level.selected_tile)
			level.dec_block_count()
	

func is_cell_vacant(current_pos :Vector2 , direction : Vector2):
	var grid_pos = world_to_map(current_pos) + direction
	
	return ( grid_pos.x < grid_size.x and grid_pos.x >= 0 \
	and grid_pos.y < grid_size.y and grid_pos.y >= 0 \
	and grid[grid_pos.x][grid_pos.y] == null)

func is_ctrl_cell_vacant(current_pos :Vector2):
	var grid_pos = world_to_map(current_pos)
	
	return ( grid_pos.x < grid_size.x and grid_pos.x >= 0 \
	and grid_pos.y < grid_size.y and grid_pos.y >= 0 \
	and ctrl_grid[grid_pos.x][grid_pos.y] == null)

func get_control(current_pos :Vector2, direction :Vector2, is_evil :bool):
	var grid_pos = world_to_map(current_pos)
	
	if (ctrl_grid[grid_pos.x][grid_pos.y] == null) :
		return null
	
	#this int cast lost me presious minutes of my time in a game jam that i will never get back
	var control_cell = int(ctrl_grid[grid_pos.x][grid_pos.y])
	if control_cell != null :
		match control_cell:
			CTRL_TILE_TYPE.NO_CTRL:
				return null
			CTRL_TILE_TYPE.LEVEL_EXIT:
				if not is_evil:
					level.number_of_floppies -= 1
					set_cellv(grid_pos, -1)
					ctrl_grid[grid_pos.x][grid_pos.y] = null
					if level.number_of_floppies == 0:
						emit_signal("level_compleated")
				return null
			CTRL_TILE_TYPE.TURN_CCW:
				return RobotVariables.CONTROL_COMMAND.TURN_CCW 
			CTRL_TILE_TYPE.TURN_CW:
				return RobotVariables.CONTROL_COMMAND.TURN_CW 
			CTRL_TILE_TYPE.PAUSE:
				return RobotVariables.CONTROL_COMMAND.PAUSE if not is_evil else null
			CTRL_TILE_TYPE.PLAY:
				$GridSFX/rattle_sfx.play()
				for robot in RobotVariables.RobotInstanceList:
					robot.un_pause()
			CTRL_TILE_TYPE.REPLICATE:
				$GridSFX/spring_sfx.play()
				var roboclone = EvilbotClone.instance() if is_evil else RobotClone.instance()
				roboclone.position = map_to_world(grid_pos) + (tile_size/2)
				roboclone.direction = direction.rotated(PI/2).snapped(Vector2(1,1))
				add_child(roboclone)
				roboclone.update_animation()
				return RobotVariables.CONTROL_COMMAND.TURN_CCW
			CTRL_TILE_TYPE.SPIKES_OFF:
				return null
			CTRL_TILE_TYPE.SPIKES_ON:
				return RobotVariables.CONTROL_COMMAND.EXPLODE
			CTRL_TILE_TYPE.LEVER:
				$GridSFX/click_sfx.play()
				for pos in lever_cords:
					if get_cell_autotile_coord(pos.x, pos.y).x == 0:
						set_cellv(pos, lever_idx, false, false, false, Vector2(1, 0))
					else:
						set_cellv(pos, lever_idx, false, false, false, Vector2(0, 0))
				togle_spikes()
				
				return null


func update_child_pos(child_node, direction: Vector2):
	var grid_pos = world_to_map(child_node.position)
	grid[grid_pos.x][grid_pos.y] = null
	
	var new_grid_pos = grid_pos + direction
	grid[new_grid_pos.x][new_grid_pos.y] = child_node.grid_type
	var target_pos = map_to_world(new_grid_pos) + (tile_size/2)
	return target_pos

func add_ctrl_tile(at: Vector2, type: int):
	var grid_pos :Vector2 = world_to_map(at)
	
	if is_ctrl_cell_vacant(at) and is_cell_vacant(at, Vector2.ZERO):
		ctrl_grid[grid_pos.x][grid_pos.y] = type
		set_cellv(grid_pos, control_tile_idx, false, false, false, Vector2(0, type))
		

func togle_spikes():
	print("hey")
	for spike in spike_cords:
		if ctrl_grid[spike.x][spike.y] == CTRL_TILE_TYPE.SPIKES_OFF:
			ctrl_grid[spike.x][spike.y] = CTRL_TILE_TYPE.SPIKES_ON
			set_cellv(spike, spike_idx, false, false, false, Vector2(3, 0))
		else:
			ctrl_grid[spike.x][spike.y] = CTRL_TILE_TYPE.SPIKES_OFF
			set_cellv(spike, spike_idx, false, false, false, Vector2(0, 0))
		#elif ctrl_grid[spike.x][spike.y] == CTRL_TILE_TYPE.SPIKES_ON:

func clear_obstacle(position:Vector2):
	var grid_cords = world_to_map(position)
	grid[grid_cords.x][grid_cords.y] = null

func collision_explode(colision_pos :Vector2 , direction : Vector2):
	var grid_pos = (world_to_map(colision_pos) + direction)#.snapped(Vector2(1,1))
	#if grid[grid_pos.x][grid_pos.y] == GRID_OBJ_TYPE.PLAYER:
	print("mycords:", grid_pos)
	print("other cords:")
	for robot in RobotVariables.RobotInstanceList:
		print(robot.grid_cords)
		if (robot.grid_cords - grid_pos).length() < 0.5:
			print("match")
			robot.exploding = true
