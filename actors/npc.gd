extends Actor

@onready var random_movement_module = $RandomMovementModule

func _ready():
	random_movement_module.current_direction_changed.connect(update_animation)
	update_animation(random_movement_module.current_direction)

func update_animation(dir: Vector2):
	if dir.x != 0:
		sprite.flip_h = dir.x < 0
		sprite.frame = 0
		shadow.rotation_degrees = 0
		shadow.position.y = 0
	elif dir.y > 0:
		sprite.frame = 2
		shadow.rotation_degrees = 90
		shadow.position.y = -1
	else:
		sprite.frame = 1
		shadow.rotation_degrees = 90
		shadow.position.y = -1

	var tween = get_tree().create_tween().bind_node(self)
	tween.tween_property(sprite, "scale", Vector2(abs(dir.x) * 1.2 if abs(dir.x) > 0 else 1, abs(dir.y) * 1.2 if abs(dir.y) > 0 else 1), 0.05)
	tween.finished.connect(tween.kill)
