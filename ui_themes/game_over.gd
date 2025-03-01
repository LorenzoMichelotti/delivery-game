extends CanvasLayer

@onready var final_score_label = $GameOver/Label/FinalScoreLabel

func _ready():
	final_score_label.text = str(PlayerManager.points)

func _on_button_pressed():
	hide()
	GameManager.set_game_mode(GameManager.GAMEMODE.PLAYING)
