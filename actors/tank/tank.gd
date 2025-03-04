extends Actor

@onready var random_movement_module = $RandomMovementModule
@onready var animation_tree = $AnimationTree

func _ready():
	random_movement_module.current_direction_changed.connect(update_animation)
	update_animation(random_movement_module.current_direction)

func update_animation(dir: Vector2):
	animation_tree.set("parameters/BlendSpace2D/blend_position", dir)

	var tween = get_tree().create_tween().bind_node(self)
	tween.tween_property(sprite, "scale", Vector2(abs(dir.x) * 1.2 if abs(dir.x) > 0 else 1, abs(dir.y) * 1.2 if abs(dir.y) > 0 else 1), 0.05)
	tween.finished.connect(tween.kill)
