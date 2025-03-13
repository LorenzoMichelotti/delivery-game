extends Node

const MINIMUM_POINTS_REQUIREMENT_RESOURCE = preload("res://level_builder/level_completion/minimum_points_requirement_resource.tres")
const MINIMUM_DELIVERIES_REQUIREMENT_RESOURCE = preload("res://level_builder/level_completion/minimum_deliveries_requirement_resource.tres")
const DESTROY_TANKS_REQUIREMENT_RESOURCE = preload("res://level_builder/level_completion/destroy_tanks_requirement_resource.tres")

const WIN_SONG_STREAM: AudioStreamWAV = preload("res://assets/sounds/Level_Complete.wav")

const COMPLETION_REQUIREMENTS: Array[CompletionRequirementResource] = [
	MINIMUM_POINTS_REQUIREMENT_RESOURCE,
	MINIMUM_DELIVERIES_REQUIREMENT_RESOURCE,
	DESTROY_TANKS_REQUIREMENT_RESOURCE
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

var current_completion_requirements: CompletionRequirementResource = MINIMUM_POINTS_REQUIREMENT_RESOURCE

var tile_map_layer: TileMapLayer
var road_positions: Array[Vector2i] = []
var acquired_targets = {}
var is_level_completed = false
var current_goal_achieved = false
var current_level: int = 0
var current_level_retries: int = 0
var endless_mode = true
signal level_changed
signal level_completion_requirement_met

func _ready():
	_update_completion_requirements()

func complete_level(verify = true):
	if is_level_completed:
		return
	is_level_completed = LevelManager.verify_level_win_condition() if verify else true
	if LevelManager.endless_mode:
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
	
func _update_completion_requirements(custom_requirement: CompletionRequirementResource = null):
	acquired_targets.clear()
	if custom_requirement != null:
		current_completion_requirements = custom_requirement
	current_completion_requirements = COMPLETION_REQUIREMENTS.pick_random()

func next_level():
	if PlayerManager.pawn.alive_module.is_dead:
		return
		
	if endless_mode:
		current_goal_achieved = false
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

func new_run():
	current_level = 0
	PlayerManager.reset_player(true)
	_update_completion_requirements()
	get_tree().reload_current_scene()
	level_changed.emit()
	return

func verify_level_win_condition():
	if current_completion_requirements:
		var requirement_is_met = current_completion_requirements.verify_completion_requirement_met()
		if requirement_is_met and not current_goal_achieved:
			current_goal_achieved = true 
			SfxManager.play_sfx(WIN_SONG_STREAM, SfxManager.CHANNEL_CONFIG.VOICES)
			level_completion_requirement_met.emit()
			get_tree().create_timer(2).timeout.connect(complete_level.bind(false))
		return requirement_is_met

func _on_acquire_target(target_type: GlobalConstants.TARGET_TYPES):
	if not acquired_targets.has(target_type):
		acquired_targets[target_type] = 0
	acquired_targets[target_type] += 1
