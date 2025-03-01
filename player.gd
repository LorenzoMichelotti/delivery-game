extends CharacterBody2D

const SPEED = 100.0  
const GRID_SIZE = 8  

var target_position: Vector2
var current_direction: Vector2 = Vector2.ZERO  # Active movement direction
var input_queue: Array = []  # Tracks pressed keys in order
@onready var raycast := $RayCast2D
@export var gas_bar: Panel
@export var gas_bar_backdrop: Panel
@export var gas_label: Label
var moving: bool = false

func _ready():
	target_position = global_position 

func _process(delta):
	if GameManager.is_game_paused():
		return
		
	global_position = global_position.move_toward(target_position, SPEED * delta)

	if global_position.is_equal_approx(target_position):
		global_position = target_position  

		# Stop moving if the current direction is blocked
		if not can_move(current_direction):
			current_direction = Vector2.ZERO
			var tween: Tween = get_tree().create_tween().bind_node(self)
			moving = false
			tween.tween_property($SpritePivot/Sprite2D, "scale", Vector2(1, 1), 0.05)
			tween.finished.connect(tween.kill)

		# Get the most recent valid direction
		var new_direction = get_valid_direction()
		if new_direction != Vector2.ZERO:
			current_direction = new_direction

		if current_direction != Vector2.ZERO:
			target_position += current_direction * GRID_SIZE

func _unhandled_input(event):
	if GameManager.is_game_paused():
		return
		
	if event is InputEventKey:
		var input_dir = Vector2.ZERO
		if event.keycode == KEY_W:
			input_dir = Vector2.UP
		elif event.keycode == KEY_S:
			input_dir = Vector2.DOWN
		elif event.keycode == KEY_A:
			input_dir = Vector2.LEFT
		elif event.keycode == KEY_D:
			input_dir = Vector2.RIGHT
		
		if event.is_pressed():
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
				$SpritePivot/Sprite2D.flip_h = dir.x < 0
				$SpritePivot/Sprite2D.frame = 3
			elif dir.y > 0:
				$SpritePivot/Sprite2D.frame = 5
			else:
				$SpritePivot/Sprite2D.frame = 4
			
			var tween: Tween = get_tree().create_tween().bind_node(self)
			moving = true
			tween.tween_property($SpritePivot/Sprite2D, "scale", Vector2(abs(dir.x) * 1.2 if abs(dir.x) > 0 else 1, abs(dir.y) * 1.2 if abs(dir.y) > 0 else 1), 0.05)
			tween.finished.connect(tween.kill)
			return dir  # Follow the most recent valid direction

	return Vector2.ZERO  # Stop if no valid direction remains

func can_move(dir: Vector2) -> bool:
	raycast.target_position = dir * (GRID_SIZE + 1)
	raycast.force_raycast_update()
	return not raycast.is_colliding()
