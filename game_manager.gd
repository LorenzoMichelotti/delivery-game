extends Node2D

@onready var game_over_scene: PackedScene = preload("res://ui/GameOver.tscn")
@onready var pause_scene: PackedScene = preload("res://ui/Pause.tscn")

var skip_cutscenes = true
var game_over_ui
var pause_ui

enum GAMEMODE {
	INITIALIZING,
	MENU,
	PLAYING,
	GAMEOVER,
	PAUSED,
	CUTSCENE
}

var current_game_mode = GAMEMODE.INITIALIZING
var previous_game_mode = GAMEMODE.INITIALIZING
var rng = RandomNumberGenerator.new()

func _ready():
	game_over_ui = game_over_scene.instantiate()
	add_child.call_deferred(game_over_ui)

func _unhandled_input(event):
	if Input.is_action_just_pressed("ui_cancel"):
		GameManager.set_game_mode(GameManager.GAMEMODE.PAUSED)

func is_game_paused():
	return current_game_mode != GAMEMODE.PLAYING

func set_game_mode(new_game_mode: GAMEMODE):
	if new_game_mode == current_game_mode:
		return
		
	previous_game_mode = current_game_mode
	current_game_mode = new_game_mode
	
	match current_game_mode:
		GAMEMODE.INITIALIZING:
			get_tree().paused = true
			return
		GAMEMODE.GAMEOVER:
			get_tree().paused = true
			gameover()
			return
		GAMEMODE.PAUSED:
			get_tree().paused = true
			pause_screen()
			return
		GAMEMODE.CUTSCENE:
			return
		GAMEMODE.PLAYING:
			get_tree().paused = false

func gameover():
	game_over_ui.play.call_deferred()
	
func pause_screen():
	if pause_ui != null:
		pause_ui.show.call_deferred()
		return
	pause_ui = pause_scene.instantiate()
	get_tree().current_scene.add_child.call_deferred(pause_ui)

func on_level_changed():
	pass
