extends CanvasLayer

@onready var final_score_label = $Paused/FinalScoreLabel


func _ready():
	visibility_changed.connect(_update_points_label)
	_update_points_label()

func _process(delta):
	if visible and Input.is_action_just_pressed("ui_cancel"):
		_continue()

func _on_button_pressed():
	_continue()


func _continue():
	hide()
	GameManager.set_game_mode(GameManager.GAMEMODE.PLAYING)
	get_tree().paused = false
	

func _restart_level():
	get_tree().reload_current_scene()


func _update_points_label():
	if visible:
		$AnimationPlayer.play("appear")
		final_score_label.text = str(PlayerManager.points).pad_zeros(10)


func _on_button_3_pressed():
	GameManager.set_game_mode(GameManager.GAMEMODE.MENU)


func _on_button_4_pressed():
	hide()
	get_tree().paused = false
	GameManager.set_game_mode(GameManager.GAMEMODE.GAMEOVER)
