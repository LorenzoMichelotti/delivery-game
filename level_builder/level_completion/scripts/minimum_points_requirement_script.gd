class_name MinimumPointsCompletionRequirementResource
extends CompletionRequirementResource

@export var minimum_points_for_completion = 5000

func _init():
	goal_description = "GOAL:" + str(minimum_points_for_completion) + "POINTS"

func apply_modifiers():
	pass

func verify_completion_requirement_met():
	return PlayerManager.current_level_points >= minimum_points_for_completion

func get_value() -> String:
	return str(PlayerManager.current_level_points) + "/" + str(minimum_points_for_completion)
