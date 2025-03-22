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

func _restart():
	LevelManager.new_run()
	
func _go_to_upgrade_screen():
	GameManager.set_game_mode(GameManager.GAMEMODE.UPGRADING)

func _update_points_label():
	$GameOver/MoneyLabel.text = "$" + str(PlayerManager.money).pad_zeros(9)
	if visible:
		play()

func pause():
	get_tree().paused = true

func play():
	animation_tree.set("parameters/conditions/appear", true)
	animation_tree.set("parameters/conditions/disappear", false)
	animation_tree.set("parameters/conditions/disappear_no_restart", false)
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
	animation_tree.set("parameters/conditions/disappear_no_restart", false)
	animation_tree.set("parameters/conditions/disappear", true)

func _disappear_no_restart():
	CutsceneManager.cutscene_player.fade_to_color()
	animation_tree.set("parameters/conditions/disappear_no_restart", true)
	animation_tree.set("parameters/conditions/appear", false)
	animation_tree.set("parameters/conditions/disappear", false)

func _on_upgrade_button_pressed():
	_disappear_no_restart()
