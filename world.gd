extends Node2D

@export var level_name: String = "LEVEL NAME"
@export var completion_requirements: CompletionRequirementResource

# Called when the node enters the scene tree for the first time.
func _ready():
	GameManager.current_completion_goal = completion_requirements
	GameManager.on_level_changed()
	PlayerManager.on_level_changed()
	GameManager.set_game_mode(GameManager.GAMEMODE.PLAYING)
