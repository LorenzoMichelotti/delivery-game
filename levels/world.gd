class_name World
extends Node2D

@export_group("Level")
@export var level: int = 1
@export var current_client: ActorResource = preload("res://assets/characters/actors/morgana/morgana.tres")

@export_group("Cutscene")
@export var start_cutscene: CutsceneResource
@export var gameover_cutscene: CutsceneResource
@export var success_cutscene: CutsceneResource

@onready var game_ui = $CanvasLayer/LevelUI

func _ready():
	get_tree().paused = true

# ATTENTION: THE ORDER OF THE COMPONENTS BELOW IS IMPORTANT
func _on_map_generated():
	LevelManager.tile_map_layer = $Map.road_tilemap_layer
	LevelManager.road_positions = $Map.road_positions
	
	if not GameManager.endless: # when in endless mode, the game manager manages the level count
		GameManager.current_level = level
	GameManager.current_client = current_client
	GameManager.road = $Map/Tiles/Road
	
	PlayerManager.on_level_changed()
		
	GameManager.on_level_changed()
	CutsceneManager.on_level_changed()
	CutsceneManager.cutscene_player.play.call_deferred(start_cutscene, game_ui)
	
