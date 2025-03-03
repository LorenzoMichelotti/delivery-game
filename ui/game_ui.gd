extends Control

@onready var world = $"../.."

func _ready():
	$PointsControl/Goal.text = world.completion_requirements.goal_description
	$LevelName.text = "DAY " + str(GameManager.current_day).pad_zeros(2)
	$LevelName.modulate.a = 0
	_play_level_name_animation()

func _play_level_name_animation():
	$AnimationPlayer.play("fade_in_out")
