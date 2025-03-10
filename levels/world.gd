class_name World
extends Node2D

@export_group("Level")
@export var level: int = 1
@export var current_client: ActorResource = preload("res://assets/characters/actors/morgana/morgana.tres")
@export var completion_requirements: CompletionRequirementResource

@export_group("Cutscene")
@export var start_cutscene: CutsceneResource
@export var gameover_cutscene: CutsceneResource
@export var success_cutscene: CutsceneResource



func _ready():
	get_tree().paused = true

# ATTENTION: THE ORDER OF THE COMPONENTS BELOW IS IMPORTANT
func _on_map_generated():
	GameManager.current_level = level
	GameManager.current_client = current_client
	GameManager.current_completion_goal = completion_requirements
	GameManager.road = $Map/Tiles/Road
	
	PlayerManager.on_level_changed()
	completion_requirements.level_modifiers.apply_modifiers()
		
	GameManager.on_level_changed()
	CutsceneManager.on_level_changed()
	CutsceneManager.cutscene_player.play.call_deferred(start_cutscene, $CanvasLayer/LevelUI)
	
