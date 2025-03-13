extends CanvasLayer

@export var win_song: AudioStreamWAV = preload("res://assets/sounds/Level_Complete.wav")
@export var lose_song: AudioStreamWAV = preload("res://assets/sounds/Player_Died.wav")

@onready var final_score_label = $GameOver/FinalScoreLabel
@onready var button = $GameOver/Button
@onready var title = $GameOver/Title
@onready var animation_tree := $AnimationTree
@onready var audio_player = $AudioStreamPlayer
var start_over = true

func _ready():
	visibility_changed.connect(_update_points_label)

func _on_button_pressed():
	_disappear()

func _input(event):
	if visible and event.is_action_released("space"):
		_disappear()

func _restart_or_go_to_next_level():
	if start_over:
		if LevelManager.endless_mode:
			LevelManager.new_run()
		else:
			get_tree().reload_current_scene()
		return
	LevelManager.next_level()

func _update_points_label():
	if visible:
		play()

func pause():
	get_tree().paused = true

func play():
	animation_tree.set("parameters/conditions/appear", true)
	animation_tree.set("parameters/conditions/disappear", false)
	if LevelManager.verify_level_win_condition():
		audio_player.stream = win_song
		audio_player.play()
		button.set_text("Next Level")
		title.set_text("LEVEL COMPLETE")
		start_over = false
	else:
		audio_player.stream = lose_song
		audio_player.play()
		if PlayerManager.current_hp <= 0:
			title.set_text("YOU DIED")
		else:
			title.set_text("OUT OF GAS")
		button.set_text("Start Over")
		start_over = true
	final_score_label.text = str(PlayerManager.points).pad_zeros(10)

func _disappear():
	CutsceneManager.cutscene_player.fade_to_color()
	animation_tree.set("parameters/conditions/appear", false)
	animation_tree.set("parameters/conditions/disappear", true)
