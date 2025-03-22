extends Node2D

@onready var game_over_scene: PackedScene = preload("res://ui/GameOver.tscn")
@onready var pause_scene: PackedScene = preload("res://ui/Pause.tscn")
const GAME_SCENE = preload("res://levels/ProceduralLevel.tscn")
const MAIN_MENU = preload("res://ui/main_menu.tscn")
const UPGRADE_SCREEN = preload("res://upgrades/upgrade_screen.tscn")

var skip_cutscenes = true
var game_over_ui
var pause_ui
var upgrade_ui

enum GAMEMODE {
	INITIALIZING,
	MENU,
	PLAYING,
	GAMEOVER,
	PAUSED,
	UPGRADING,
	CUTSCENE
}

var current_game_mode = GAMEMODE.MENU
var previous_game_mode = GAMEMODE.MENU
var rng = RandomNumberGenerator.new()

func _ready():
	game_over_ui = game_over_scene.instantiate()
	add_child.call_deferred(game_over_ui)

func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		set_game_mode(GAMEMODE.PAUSED)

func is_game_paused():
	return current_game_mode != GAMEMODE.PLAYING

func set_game_mode(new_game_mode: GAMEMODE):
	if new_game_mode == current_game_mode:
		return
		
	previous_game_mode = current_game_mode
	current_game_mode = new_game_mode
	
	if current_game_mode == GAMEMODE.MENU:
		get_tree().change_scene_to_packed(MAIN_MENU)
	
	if previous_game_mode == GAMEMODE.MENU and current_game_mode == GAMEMODE.INITIALIZING:
		get_tree().change_scene_to_packed(GAME_SCENE)
	
	match current_game_mode:
		GAMEMODE.MENU:
			get_tree().paused = true
			return
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
		GAMEMODE.UPGRADING:
			get_tree().paused = true
			upgrade_screen()
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

func upgrade_screen():
	if upgrade_ui != null:
		upgrade_ui.show.call_deferred()
		return
	upgrade_ui = UPGRADE_SCREEN.instantiate()
	get_tree().current_scene.add_child.call_deferred(upgrade_ui)


func on_level_changed():
	pass
