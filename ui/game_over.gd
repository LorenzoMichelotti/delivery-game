extends CanvasLayer

@onready var final_score_label = $GameOver/FinalScoreLabel
@onready var button = $GameOver/Button
@onready var title = $GameOver/Title
var start_over = true

func _ready():
	$AnimationPlayer.play("initialize")
	visibility_changed.connect(_update_points_label)
	_update_points_label()

func _on_button_pressed():
	_disappear()

func _input(event):
	if event.is_action_released("space"):
		_disappear()

func _restart_or_go_to_next_level():
	if start_over:
		GameManager.change_level(GameManager.current_level)
		return
	GameManager.next_level()

func _update_points_label():
	if visible:
		play()

func play():
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

func _disappear():
	if $AnimationPlayer.current_animation != "disappear":
		$AnimationPlayer.play("disappear")
