extends Node2D

@onready var sprite = $SpritePivot/Sprite2D
var frame = 0
var is_open = false
var player_in_range = false

func _ready():
	sprite.frame = frame
	LevelManager.level_completion_requirement_met.connect(open)


func _process(delta):
	if player_in_range and LevelManager.current_goal_achieved:
		_next_level()


func _next_level():
	LevelManager.next_level.call_deferred()


func open():
	is_open = true
	

func _on_area_2d_body_entered(body):
	if is_open and body.is_in_group("player"):
		player_in_range = true


func _on_area_2d_body_exited(body):
	if is_open and body.is_in_group("player"):
		player_in_range = false
