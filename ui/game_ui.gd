extends Control

func _ready():
	_play_level_name_animation()

func _play_level_name_animation():
	$AnimationPlayer.play("fade_in_out")
