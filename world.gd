class_name World
extends Node2D

@export var level: int = 1
@export var current_client: ActorResource = preload("res://assets/characters/actors/morgana/morgana.tres")
@export var completion_requirements: CompletionRequirementResource
@export var start_cutscene: CutsceneResource
@export var gameover_cutscene: CutsceneResource
@export var success_cutscene: CutsceneResource

@onready var game_ui: Control = $CanvasLayer/LevelUI

# Called when the node enters the scene tree for the first time.
func _ready():
	GameManager.current_level = level
	GameManager.current_client = current_client
	GameManager.current_completion_goal = completion_requirements
	PlayerManager.on_level_changed()
	completion_requirements.apply_modifiers()
	GameManager.on_level_changed()
	CutsceneManager.on_level_changed()
	CutsceneManager.cutscene_player.play.call_deferred(start_cutscene, game_ui)
