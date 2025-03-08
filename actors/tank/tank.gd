extends Actor

@onready var random_movement_module = $RandomMovementModule
@onready var animation_tree = $AnimationTree

func _ready():
	update_animation(velocity.normalized())

func update_animation(dir: Vector2):
	animation_tree.set("parameters/BlendSpace2D/blend_position", dir)

	var tween = get_tree().create_tween().bind_node(self)
	tween.tween_property(sprite, "scale", Vector2(1.2 if abs(dir.x) > 0.5 else 1, 1.2 if abs(dir.y) > 0.5 else 1), 0.1)
	tween.finished.connect(tween.kill)
