extends Node

const MINIMUM_POINTS_REQUIREMENT_RESOURCE = preload("res://level_builder/level_completion/minimum_points_requirement_resource.tres")
const MINIMUM_DELIVERIES_REQUIREMENT_RESOURCE = preload("res://level_builder/level_completion/minimum_deliveries_requirement_resource.tres")

const WIN_SONG_STREAM: AudioStreamWAV = preload("res://assets/sounds/Level_Complete.wav")

const COMPLETION_REQUIREMENTS: Array[CompletionRequirementResource] = [
	#MINIMUM_POINTS_REQUIREMENT_RESOURCE,
	MINIMUM_DELIVERIES_REQUIREMENT_RESOURCE
]

const levels = {
	1: {
		"scene": preload("res://levels/01.tscn"),
	},
	2: {
		"scene": preload("res://levels/02.tscn"),
	},
	3: {
		"scene": preload("res://levels/03.tscn"),
	},
	4: {
		"scene": preload("res://levels/04.tscn"),
	}
}

var current_completion_requirements: CompletionRequirementResource
var tile_map_layer: TileMapLayer
var road_positions: Array[Vector2i] = []
var is_level_completed = false
var current_level: int = 0
var current_level_retries: int = 0
var endless_mode = true
signal level_changed
signal level_completion_requirement_met

func _ready():
	_update_completion_requirements()

func complete_level():
	if is_level_completed:
		return
	is_level_completed = LevelManager.verify_level_win_condition()
	if GameManager.endless:
		return
	var current_scene = get_tree().current_scene
	if not is_level_completed and current_scene.gameover_cutscene != null:
		CutsceneManager.cutscene_player.play.call_deferred(current_scene.gameover_cutscene, current_scene.game_ui)
		return 
	if is_level_completed and current_scene.success_cutscene != null:
		CutsceneManager.cutscene_player.play.call_deferred(current_scene.success_cutscene, current_scene.game_ui)
		return 
	GameManager.set_game_mode(GameManager.GAMEMODE.GAMEOVER)

func change_level(level: int):
	GameManager.set_game_mode(GameManager.GAMEMODE.INITIALIZING)
	if level != current_level:
		current_level = level
		current_level_retries = 0
	else:
		current_level_retries += 1
	var level_data = levels[level]
	_update_completion_requirements()
	get_tree().change_scene_to_packed.call_deferred(level_data.scene)
	
func _update_completion_requirements():
	current_completion_requirements = COMPLETION_REQUIREMENTS.pick_random()

func next_level():
	if endless_mode:
		current_level += 1
		_update_completion_requirements()
		get_tree().reload_current_scene()
		level_changed.emit()
		return
	
	var next_level_number = current_level + 1
	if next_level_number > levels.size():
		next_level_number = 1
	level_changed.emit()
	change_level(next_level_number)
	return

func verify_level_win_condition():
	if current_completion_requirements:
		var requirement_is_met = current_completion_requirements.verify_completion_requirement_met()
		if requirement_is_met: 
			level_completion_requirement_met.emit()
			SfxManager.play_sfx(WIN_SONG_STREAM, SfxManager.CHANNEL_CONFIG.VOICES)
			get_tree().create_timer(1).timeout.connect(complete_level)
		return requirement_is_met
