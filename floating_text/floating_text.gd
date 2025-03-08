extends Label

@export var float_height: float = 8.0

func animate():
	show()
	var tween = create_tween().bind_node(self)
	modulate.a = 1
	tween.tween_property(self, "position:y", position.y - 8, 1)
	tween.tween_property(self, "position:y", position.y + 8, .2)
	tween.parallel().tween_property(self, "modulate:a", 0, .2)
	
	await tween.finished
	tween.kill()
	hide()
