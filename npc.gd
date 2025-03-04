class_name Npc
extends CharacterBody2D

@onready var raycast = $RayCast2D
@onready var sprite_pivot = $SpritePivot
@onready var sprite = $SpritePivot/Sprite2D
@onready var alive_component = $AliveComponent

const SPEED = 50.0  
const GRID_SIZE = 8  
const DIRECTIONS = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]

var target_position: Vector2
var current_direction: Vector2 = Vector2.ZERO
var moving: bool = false

func _ready():
	target_position = global_position
	set_random_direction()

func _process(delta):
	if GameManager.is_game_paused() or alive_component.is_dead or alive_component.is_taking_damage:
		return

	global_position = global_position.move_toward(target_position, SPEED * delta)

	if global_position.is_equal_approx(target_position):
		global_position = target_position

		if not can_move(current_direction):
			set_random_direction()

		if current_direction != Vector2.ZERO:
			target_position += current_direction * GRID_SIZE

func set_random_direction():
	var valid_directions = DIRECTIONS.filter(can_move)
	if valid_directions.size() > 0:
		current_direction = valid_directions[randi() % valid_directions.size()]
		update_animation(current_direction)
	else:
		current_direction = Vector2.ZERO

func can_move(dir: Vector2) -> bool:
	raycast.target_position = dir * (GRID_SIZE + 1)
	raycast.force_raycast_update()
	return not raycast.is_colliding()

func update_animation(dir: Vector2):
	if dir.x != 0:
		sprite.flip_h = dir.x < 0
		sprite.frame = 0
	elif dir.y > 0:
		sprite.frame = 2
	else:
		sprite.frame = 1

	var tween = get_tree().create_tween().bind_node(self)
	moving = true
	tween.tween_property(sprite, "scale", Vector2(abs(dir.x) * 1.2 if abs(dir.x) > 0 else 1, abs(dir.y) * 1.2 if abs(dir.y) > 0 else 1), 0.05)
	tween.finished.connect(tween.kill)
