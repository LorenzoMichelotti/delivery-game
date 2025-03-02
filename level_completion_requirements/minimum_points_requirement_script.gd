class_name MinimumPointsCompletionRequirementResource
extends CompletionRequirementResource

@export var minimum_points_for_completion = 5000

func _init():
	goal_description = "GOAL:" + str(minimum_points_for_completion) + "POINTS"
	
func verify_completion_requirement_met():
	return PlayerManager.points >= minimum_points_for_completion
