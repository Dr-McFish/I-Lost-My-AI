extends KinematicBody2D

# Declare member variables here. Examples:
var anim_player
var direction : Vector2 = Vector2()
var velocity : Vector2 = Vector2()
var grid_cords :Vector2
var speed : float = 48.0
const MAX_SPEED : float = 48.0

var grid_type
var grid

var is_paused :bool = false
var is_moving :bool = false
var is_landing :bool = false
var exploding :bool = false

var target_pos : Vector2 = Vector2()
var target_dirrection : Vector2 = Vector2()

export var is_evil : bool
export(int, "North", "South", "East", "West") var DefaultDirection
var default_direction :Vector2

# Called when the node enters the scene tree for the first time.
func _ready():
	anim_player = $AnimationPlayer
	grid = get_parent()
	grid_type = grid.GRID_OBJ_TYPE.PLAYER
	anim_player.play("idle")
	RobotVariables.RobotInstanceList.append(self)
	
	if not is_evil:
		RobotVariables.good_bot_count += 1
	
	get_tree().current_scene.connect("start", self, "_start_robot")
	
	match DefaultDirection:
		0:
			default_direction = Vector2.UP
		1:
			default_direction = Vector2.DOWN
		2:
			default_direction = Vector2.LEFT
		3:
			default_direction = Vector2.RIGHT
	
	grid_cords = grid.world_to_map(position).snapped(Vector2(1,1))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _physics_process(delta):
	if not is_moving and direction != Vector2.ZERO and not is_paused :
		#check for blocks here
		target_dirrection = direction
		if grid.is_cell_vacant(position, target_dirrection):
			target_pos = grid.update_child_pos(self, direction)
			grid_cords = (grid.world_to_map(position) + direction).snapped(Vector2(1,1))
			is_moving = true
		else:
			grid.collision_explode(position, direction)
			explode()
			return
	elif is_moving:
		speed = MAX_SPEED
		velocity  = speed * target_dirrection * delta
		
		var distance_to_target = Vector2(abs(target_pos.x - position.x),
										 abs(target_pos.y - position.y))
		if abs(velocity.x) > distance_to_target.x :

			velocity.x = distance_to_target.x * target_dirrection.x
			is_landing = true
		if abs(velocity.y) > distance_to_target.y :
			velocity.y = distance_to_target.y * target_dirrection.y
			is_landing = true
		
		position += velocity
		var collision_info = false
		if collision_info:
			explode()
		elif is_landing:
			is_moving = false
			is_landing = false
			if exploding:
				explode()
				return
			#position = target_pos
			check_for_ctrl_cells()

func check_for_ctrl_cells():
	var control_command = grid.get_control(position, direction, is_evil)
	
	match control_command:
		RobotVariables.CONTROL_COMMAND.TURN_CCW:
			direction = direction.rotated(-PI/2).snapped(Vector2(1,1))
			update_animation()
			$rattle_sfx.play()
		RobotVariables.CONTROL_COMMAND.TURN_CW:
			direction = direction.rotated(PI/2).snapped(Vector2(1,1))
			update_animation()
			$rattle_sfx.play()
		RobotVariables.CONTROL_COMMAND.PAUSE:
			is_paused = true
			update_animation()
			$rattle_sfx.play()			
			return
		RobotVariables.CONTROL_COMMAND.EXPLODE:
			direction = Vector2.ZERO
			explode()
	

func update_animation():
	if direction == Vector2.UP:
		anim_player.play("walk_north")
	elif direction == Vector2.DOWN:
		anim_player.play("walk_south")
	elif direction == Vector2.LEFT:
		anim_player.play("walk_east")
	elif direction == Vector2.RIGHT:
		anim_player.play("walk_west")
	elif direction == Vector2.ZERO:
		anim_player.play("idle")
	
	if direction != Vector2.ZERO and not is_paused:
		$footsteps_sfx.playing = true
	else:
		$footsteps_sfx.playing = false
	
	if is_paused:
		anim_player.stop(false)

func un_pause():
	is_paused = false
	update_animation()

func pause():
	is_paused = true
	update_animation()

func explode():
	$footsteps_sfx.playing = false
	$explode_sfx.play()
	anim_player.play("explode")
	set_physics_process(false)
	RobotVariables.RobotInstanceList.erase(self)
	if not is_evil:
		RobotVariables.good_bot_count -= 1
		if RobotVariables.good_bot_count == 0:
			get_tree().current_scene.level_fail()
	grid.clear_obstacle(position)

func _on_AnimationPlayer_animation_finished(anim_name:String):
	if anim_name == "explode":
		grid.remove_child(self)

func _start_robot():
	direction = default_direction
	update_animation()
