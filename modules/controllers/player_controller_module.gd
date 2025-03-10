class_name PlayerControllerModule
extends RaycastControllerModuleResource

var input_queue: Array = []  # Tracks pressed keys in order
var wanted_direction: Vector2 = Vector2.ZERO
var coyote_timer: Timer

func _ready():
	coyote_timer = Timer.new()
	add_child(coyote_timer)
	coyote_timer.one_shot = true
	coyote_timer.timeout.connect(func(): wanted_direction = Vector2.ZERO)
	super()

func _process(delta):
	if not enabled or pawn.alive_module.is_taking_damage or pawn.alive_module.is_dead:
		return
		
	await get_tree().physics_frame
		
	_observe_input_direction("up", Vector2.UP)
	_observe_input_direction("left", Vector2.LEFT)
	_observe_input_direction("right", Vector2.RIGHT)
	_observe_input_direction("down", Vector2.DOWN)
	
	pawn.global_position = pawn.global_position.move_toward(target_position, speed * delta)

	if pawn.global_position.is_equal_approx(target_position):
		pawn.global_position = target_position  

		if roundi(pawn.global_position.x) % 2 != 0 or roundi(pawn.global_position.y) % 2 != 0:
			print("cuca")
			return

		if input_queue.size() > 0:
			if can_move(input_queue[-1]) and wanted_direction != input_queue[-1]:
				print("sama")
				wanted_direction = input_queue[-1]
				current_direction = wanted_direction
				target_position += wanted_direction * GlobalConstants.GRID_SIZE
				_animate_movement(wanted_direction)
				return
			if input_queue.size() > 1 and abs(input_queue[-1]) - abs(input_queue[-2]) != Vector2.ZERO and can_move(input_queue[-2]):
				if input_queue.size() > 1 and can_move(input_queue[-2]):
					print("aba")
					wanted_direction = input_queue[-2]
					current_direction = wanted_direction
					target_position += wanted_direction * GlobalConstants.GRID_SIZE
					_animate_movement(wanted_direction)
					return

		# Stop moving if the current direction is blocked
		if current_direction != Vector2.ZERO and not can_move(current_direction):
			input_queue.clear()
			print("xebe")
			current_direction = Vector2.ZERO
			wanted_direction = Vector2.ZERO
			target_position = pawn.global_position
			var tween: Tween = get_tree().create_tween().bind_node(self)
			moving = false
			tween.tween_property(pawn.sprite, "scale", Vector2(1, 1), 0.05)
			tween.finished.connect(tween.kill)
		
		# fallback direction
		if current_direction != Vector2.ZERO:
			print("pipi")
			target_position += current_direction * GlobalConstants.GRID_SIZE
			_animate_movement(current_direction)
			

func _animate_movement(direction):
	if direction.x != 0 :
		pawn.sprite.flip_h = direction.x < 0
		pawn.sprite.frame = 3
		pawn.shadow.rotation_degrees = 0
		pawn.shadow.position.y = 0
	elif direction.y > 0:
		pawn.sprite.frame = 5
		pawn.shadow.rotation_degrees = 90
		pawn.shadow.position.y = -1
	elif direction.y < 0:
		pawn.sprite.frame = 4
		pawn.shadow.rotation_degrees = 90
		pawn.shadow.position.y = -1
	var tween: Tween = get_tree().create_tween().bind_node(self)
	moving = true
	tween.tween_property(pawn.sprite, "scale", Vector2(abs(direction.x) * 1.2 if abs(direction.x) > 0 else 1, abs(direction.y) * 1.2 if abs(direction.y) > 0 else 1), 0.05)
	tween.finished.connect(tween.kill)

func _observe_input_direction(input_action_name: String, direction: Vector2):
	if Input.is_action_pressed(input_action_name) and not input_queue.has(direction):
		input_queue.append(direction)
	if Input.is_action_just_released(input_action_name):
		input_queue.erase(direction)

func _unhandled_input(event):
	if Input.is_action_just_pressed("ui_cancel"):
		GameManager.set_game_mode(GameManager.GAMEMODE.PAUSED)

func can_move(dir: Vector2) -> bool:
	raycast.rotation = dir.angle()
	raycast.force_update_transform()
	raycast.force_raycast_update()
	return not raycast.is_colliding()
