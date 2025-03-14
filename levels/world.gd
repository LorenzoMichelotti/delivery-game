class_name World
extends Node2D

@export_group("Level")
@export var level: int = 1
@export var current_client: ActorResource = preload("res://assets/characters/actors/morgana/morgana.tres")
@export var custom_completion_requirement: CompletionRequirementResource

@export_group("Cutscene")
@export var start_cutscene: CutsceneResource
@export var gameover_cutscene: CutsceneResource
@export var success_cutscene: CutsceneResource

@onready var game_ui = $CanvasLayer/LevelUI
@onready var map = $Map

func _ready():
	get_tree().paused = true
	LevelManager._update_completion_requirements(custom_completion_requirement)
	map.generate()

# ATTENTION: THE ORDER OF THE COMPONENTS BELOW IS IMPORTANT
func _on_map_generated():
	if not LevelManager.endless_mode: # when in endless mode, the game manager manages the level count
		LevelManager.current_level = level
	
	PlayerManager.on_level_changed()
	LevelManager.current_completion_requirements.level_modifiers.apply_modifiers()
		
	GameManager.on_level_changed()
	CutsceneManager.on_level_changed()
	CutsceneManager.cutscene_player.play.call_deferred(start_cutscene, game_ui)
