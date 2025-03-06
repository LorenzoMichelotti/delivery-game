class_name RandomMovementModule
extends ControllerModuleResource

const DIRECTIONS = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]
signal current_direction_changed(current_direction)

func _ready():
	super()
	set_random_direction()

func _process(delta):
	if not enabled or GameManager.is_game_paused() or pawn.alive_module.is_dead or pawn.alive_module.is_taking_damage:
		return

	pawn.global_position = pawn.global_position.move_toward(target_position, speed * delta)

	if pawn.global_position.is_equal_approx(target_position):
		pawn.global_position = target_position

		if not can_move(current_direction):
			set_random_direction()

		if current_direction != Vector2.ZERO:
			target_position += current_direction * GlobalConstants.GRID_SIZE

func set_random_direction():
	var valid_directions = DIRECTIONS.filter(can_move)
	
	if valid_directions.size() > 0:
		current_direction = valid_directions[randi() % valid_directions.size()]
		current_direction_changed.emit(current_direction)
		moving = true
	else:
		current_direction = Vector2.ZERO

func can_move(dir: Vector2) -> bool:
	raycast.target_position = dir * (GlobalConstants.GRID_SIZE + 2)
	raycast.force_raycast_update()
	
	return not raycast.is_colliding()
