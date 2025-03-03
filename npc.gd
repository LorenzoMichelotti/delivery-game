class_name Npc
extends CharacterBody2D

@export var hit_sfx_stream = preload("res://assets/sounds/Hit.wav")
@export var explosion_sfx_stream = preload("res://assets/sounds/Explode.wav")

const SPEED = 50.0  
const GRID_SIZE = 8  
const DIRECTIONS = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]

var target_position: Vector2
var current_direction: Vector2 = Vector2.ZERO
@onready var raycast = $RayCast2D
@onready var hitbox = $Area2D
var moving: bool = false
var is_dead: bool = false
var points: int = 100

func _ready():
	target_position = global_position
	set_random_direction()
	hitbox.body_entered.connect(_on_body_entered)

func _process(delta):
	if GameManager.is_game_paused() or is_dead:
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
		$SpritePivot/Sprite2D.flip_h = dir.x < 0
		$SpritePivot/Sprite2D.frame = 3
	elif dir.y > 0:
		$SpritePivot/Sprite2D.frame = 5
	else:
		$SpritePivot/Sprite2D.frame = 4

	var tween = get_tree().create_tween().bind_node(self)
	moving = true
	tween.tween_property($SpritePivot/Sprite2D, "scale", Vector2(abs(dir.x) * 1.2 if abs(dir.x) > 0 else 1, abs(dir.y) * 1.2 if abs(dir.y) > 0 else 1), 0.05)
	tween.finished.connect(tween.kill)

# Handle when the NPC is hit by the player
func _on_body_entered(body):
	if body.is_in_group("player"):  # Make sure to match your player node's name
		die()

func die():
	is_dead = true
	
	VfxManager.display_explosion_effect(global_position)
	SfxManager.play_sfx(hit_sfx_stream, SfxManager.CHANNEL_CONFIG.HITS)
	
	var tween = get_tree().create_tween().bind_node(self)
	tween.tween_property($SpritePivot, "global_position", Vector2(global_position.x + randi_range(-8, 8), global_position.y - 10), 0.2)
	tween.parallel().tween_property($SpritePivot, "rotation", TAU/2, 0.3)
	tween.chain().tween_property($SpritePivot, "global_position:y", randi_range(global_position.y + 8, global_position.y -8), 0.1)
	
	await tween.finished
	
	SfxManager.play_sfx(explosion_sfx_stream, SfxManager.CHANNEL_CONFIG.EXPLOSIONS)
	VfxManager.display_explosion_effect(global_position)
	
	VfxManager.display_number(str(points), global_position)
	PlayerManager.add_points(points)
	
	tween = get_tree().create_tween().bind_node(self)
	tween.tween_property($SpritePivot, "modulate", Color.BLACK, 0.1)
	tween.parallel().tween_property($SpritePivot, "modulate:a", 0, 0.6)  # Fade out effect
	
	tween.finished.connect(queue_free)  # Remove NPC after fade
