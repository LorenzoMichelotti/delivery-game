extends Node

const MINIMUM_POINTS_REQUIREMENT_RESOURCE = preload("res://level_builder/level_completion/minimum_points_requirement_resource.tres")
const MINIMUM_DELIVERIES_REQUIREMENT_RESOURCE = preload("res://level_builder/level_completion/minimum_deliveries_requirement_resource.tres")
const DESTROY_TANKS_REQUIREMENT_RESOURCE = preload("res://level_builder/level_completion/destroy_tanks_requirement_resource.tres")
const MINIMUM_MOBILE_DELIVERIES_REQUIREMENT_RESOURCE = preload("res://level_builder/level_completion/minimum_mobile_deliveries_requirement_resource.tres")

const WIN_SONG_STREAM: AudioStreamWAV = preload("res://assets/sounds/Level_Complete.wav")

const COMPLETION_REQUIREMENTS: Array[CompletionRequirementResource] = [
	MINIMUM_POINTS_REQUIREMENT_RESOURCE,
	MINIMUM_DELIVERIES_REQUIREMENT_RESOURCE,
	DESTROY_TANKS_REQUIREMENT_RESOURCE,
	MINIMUM_MOBILE_DELIVERIES_REQUIREMENT_RESOURCE
]

var current_completion_requirements: CompletionRequirementResource = MINIMUM_POINTS_REQUIREMENT_RESOURCE

var tile_map_layer: TileMapLayer
var road_positions: Array[Vector2i] = []
var acquired_targets = {}
var is_level_completed = false
var current_goal_achieved = false
var current_level: int = 0
var endless_mode = true
signal level_changed
signal level_completion_requirement_met

func _ready():
	_update_completion_requirements()

func complete_level(verify = true):
	if is_level_completed:
		return
	is_level_completed = LevelManager.verify_level_win_condition() if verify else true

func _update_completion_requirements(custom_requirement: CompletionRequirementResource = null):
	acquired_targets.clear()
	if custom_requirement != null:
		current_completion_requirements = custom_requirement
	current_completion_requirements = COMPLETION_REQUIREMENTS.pick_random()


func next_level():
	if PlayerManager.pawn.alive_module.is_dead:
		return
		
	current_goal_achieved = false
	current_level += 1
	_update_completion_requirements()
	get_tree().reload_current_scene()
	level_changed.emit()


func new_run():
	current_level = 0
	current_goal_achieved = false
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
