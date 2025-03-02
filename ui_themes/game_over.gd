extends CanvasLayer

@onready var final_score_label = $GameOver/FinalScoreLabel
@onready var button = $GameOver/Button
@onready var title = $GameOver/Title
var start_over = true

func _ready():
	visibility_changed.connect(_update_points_label)
	_update_points_label()

func _on_button_pressed():
	if start_over:
		GameManager.change_level(GameManager.current_level)
		return
	GameManager.next_level()

func _update_points_label():
	if visible:
		$AnimationPlayer.play("appear")
		if GameManager.verify_level_win_condition():
			button.set_text("Next Level")
			title.set_text("LEVEL COMPLETE")
			start_over = false
		else:
			button.set_text("Start Over")
			title.set_text("OUT OF GAS")
			start_over = true
		final_score_label.text = str(PlayerManager.points).pad_zeros(10)
