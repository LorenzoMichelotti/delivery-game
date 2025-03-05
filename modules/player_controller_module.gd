class_name PlayerControllerModule
extends Node2D

# Actor
@export var pawn: Actor
@onready var speed = 100.0  

var target_position: Vector2
var current_direction: Vector2 = Vector2.ZERO  # Active movement direction
var input_queue: Array = []  # Tracks pressed keys in order
@onready var raycast := $RayCast2D
var moving: bool = false

func _ready():
	target_position = pawn.global_position 

func _process(delta):
	if pawn.alive_module.is_taking_damage:
		return
	
	pawn.global_position = pawn.global_position.move_toward(target_position, speed * delta)

	if pawn.global_position.is_equal_approx(target_position):
		pawn.global_position = target_position  

		# Stop moving if the current direction is blocked
		if not can_move(current_direction):
			current_direction = Vector2.ZERO
			var tween: Tween = get_tree().create_tween().bind_node(self)
			moving = false
			tween.tween_property(pawn.sprite, "scale", Vector2(1, 1), 0.05)
			tween.finished.connect(tween.kill)

		# Get the most recent valid direction
		var new_direction = get_valid_direction()
		if new_direction != Vector2.ZERO:
			current_direction = new_direction

		if current_direction != Vector2.ZERO:
			target_position += current_direction * GlobalConstants.GRID_SIZE

func _unhandled_input(event):
	if pawn.alive_module.is_taking_damage:
		return
		
	if event is InputEventKey:
		var input_dir = Vector2.ZERO
		if Input.is_action_just_pressed("ui_cancel"):
			GameManager.set_game_mode(GameManager.GAMEMODE.PAUSED)
		if event.keycode == KEY_W:
			input_dir = Vector2.UP
		elif event.keycode == KEY_S:
			input_dir = Vector2.DOWN
		elif event.keycode == KEY_A:
			input_dir = Vector2.LEFT
		elif event.keycode == KEY_D:
			input_dir = Vector2.RIGHT
		
		if event.is_pressed() and input_dir != Vector2.ZERO:
			if input_dir not in input_queue:
				input_queue.append(input_dir)  # Track pressed keys
			
		elif event.is_released():
			input_queue.erase(input_dir)  # Remove released key
			
			# Immediately switch to the next most recent key still held, if valid
			var new_direction = get_valid_direction()
			if new_direction != Vector2.ZERO:
				current_direction = new_direction

func get_valid_direction() -> Vector2:
	# Traverse the queue from latest to earliest pressed key
	for i in range(input_queue.size() - 1, -1, -1):
		var dir = input_queue[i]
		if can_move(dir):
			if dir.x != 0 :
				pawn.sprite.flip_h = dir.x < 0
				pawn.sprite.frame = 3
				pawn.shadow.rotation_degrees = 0
				pawn.shadow.position.y = 0
			elif dir.y > 0:
				pawn.sprite.frame = 5
				pawn.shadow.rotation_degrees = 90
				pawn.shadow.position.y = -1
			elif dir.y < 0:
				pawn.sprite.frame = 4
				pawn.shadow.rotation_degrees = 90
				pawn.shadow.position.y = -1
			var tween: Tween = get_tree().create_tween().bind_node(self)
			moving = true
			tween.tween_property(pawn.sprite, "scale", Vector2(abs(dir.x) * 1.2 if abs(dir.x) > 0 else 1, abs(dir.y) * 1.2 if abs(dir.y) > 0 else 1), 0.05)
			tween.finished.connect(tween.kill)
			return dir  # Follow the most recent valid direction
	return Vector2.ZERO  # Stop if no valid direction remains

func can_move(dir: Vector2) -> bool:
	raycast.target_position = dir * (GlobalConstants.GRID_SIZE + 2)
	raycast.force_raycast_update()
	return not raycast.is_colliding()
