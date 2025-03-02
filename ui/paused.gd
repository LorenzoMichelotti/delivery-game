extends CanvasLayer

@onready var final_score_label = $Paused/FinalScoreLabel

func _ready():
	visibility_changed.connect(_update_points_label)
	_update_points_label()

func _on_button_pressed():
	hide()
	GameManager.set_game_mode(GameManager.GAMEMODE.PLAYING)

func _input(event):
	if event.is_action_released("space"):
		hide()
		GameManager.set_game_mode(GameManager.GAMEMODE.PLAYING)

func _update_points_label():
	if visible:
		$AnimationPlayer.play("appear")
		final_score_label.text = str(PlayerManager.points).pad_zeros(10)
