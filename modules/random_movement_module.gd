class_name RandomMovementModule
extends Node2D

@export var pawn: CharacterBody2D
@onready var raycast = $RayCast2D

const SPEED = 50.0  
const DIRECTIONS = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]

var target_position: Vector2
var current_direction: Vector2 = Vector2.ZERO
var moving: bool = false

func _ready():
	target_position = pawn.global_position
	set_random_direction()

func _process(delta):
	if GameManager.is_game_paused() or pawn.alive_module.is_dead or pawn.alive_module.is_taking_damage:
		return

	pawn.global_position = pawn.global_position.move_toward(target_position, SPEED * delta)

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
		update_animation.call_deferred(current_direction)
	else:
		current_direction = Vector2.ZERO

func can_move(dir: Vector2) -> bool:
	raycast.target_position = dir * (GlobalConstants.GRID_SIZE + 2)
	raycast.force_raycast_update()
	return not raycast.is_colliding()

func update_animation(dir: Vector2):
	if dir.x != 0:
		pawn.sprite.flip_h = dir.x < 0
		pawn.sprite.frame = 0
	elif dir.y > 0:
		pawn.sprite.frame = 2
	else:
		pawn.sprite.frame = 1

	var tween = get_tree().create_tween().bind_node(self)
	moving = true
	tween.tween_property(pawn.sprite, "scale", Vector2(abs(dir.x) * 1.2 if abs(dir.x) > 0 else 1, abs(dir.y) * 1.2 if abs(dir.y) > 0 else 1), 0.05)
	tween.finished.connect(tween.kill)
