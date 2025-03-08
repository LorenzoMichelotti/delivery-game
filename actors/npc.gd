extends Actor

@onready var random_movement_module = $RandomMovementModule

func _process(delta):
	update_animation(velocity.normalized())

func update_animation(dir: Vector2):
	if abs(dir.x) > 0.5:
		sprite.flip_h = dir.x < 0
		sprite.frame = 0
		shadow.rotation_degrees = 0
		shadow.position.y = 0
	elif dir.y > 0.5:
		sprite.frame = 2
		shadow.rotation_degrees = 90
		shadow.position.y = -1
	else:
		sprite.frame = 1
		shadow.rotation_degrees = 90
		shadow.position.y = -1

	var tween = get_tree().create_tween().bind_node(self)
	tween.tween_property(sprite, "scale", Vector2(1.2 if abs(dir.x) > 0.5 else 1, 1.2 if abs(dir.y) > 0.5 else 1), 0.1)
	tween.finished.connect(tween.kill)
