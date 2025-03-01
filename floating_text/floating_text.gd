extends Node2D

@export var float_height: float = 25.0

func _ready():
	animate()

func animate():
	modulate.a = 0
	scale = Vector2.ZERO
	position.y -= float_height/2
	
	var tween = create_tween()
	
	tween.tween_property(self, "scale", Vector2.ONE, .1).set_ease(Tween.EASE_IN).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(self, "modulate:a", 1, .1).set_ease(Tween.EASE_IN).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(self, "position:y", position.y - float_height, .4).set_ease(Tween.EASE_OUT)
	
	tween.tween_property(self, "position:y", position.y + 100, .2).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(self, "modulate:a", 0, .2).set_ease(Tween.EASE_IN)
	
	await tween.finished
	hide()

func set_text(new_text: String):
	$Label.text = new_text
	$Label.pivot_offset = Vector2($Label.size / 2)
