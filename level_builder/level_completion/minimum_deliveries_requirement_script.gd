class_name MinimumDeliveriesCompletionRequirementResource
extends CompletionRequirementResource

@export var minimum_deliveries_for_completion = 3

func _init():
	goal_description = "GOAL: COMPLETE DELIVERIES"

func verify_completion_requirement_met():
	return PlayerManager.completed_deliveries >= minimum_deliveries_for_completion

func get_value() -> String:
	return str(PlayerManager.completed_deliveries) + "/" + str(minimum_deliveries_for_completion)
