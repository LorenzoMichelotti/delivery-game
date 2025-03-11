extends Node2D

@onready var sprite = $SpritePivot/Sprite2D
var frame = 0
var is_open = false

func _ready():
	sprite.frame = frame
	LevelManager.level_completion_requirement_met.connect(open)

func _next_level():
	LevelManager.next_level.call_deferred()

func _on_area_2d_body_entered(body):
	if is_open and body.is_in_group("player"):
		_next_level()

func open():
	is_open = true
	
