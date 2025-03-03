extends Control

@onready var world = $"../.."

func _ready():
	$PointsControl/Goal.text = world.completion_requirements.goal_description
	$LevelName.text = str(GameManager.current_level).pad_zeros(2) + " - " + world.level_name
	$LevelName.modulate.a = 0
	_play_level_name_animation()

func _play_level_name_animation():
	$AnimationPlayer.play("fade_in_out")
