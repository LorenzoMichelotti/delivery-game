class_name DestroyTanksCompletionRequirementResource
extends CompletionRequirementResource

@export var minimum_targets_for_completion = 3

func verify_completion_requirement_met():
	if not GameManager.acquired_targets.has(GlobalConstants.TARGET_TYPES.TANK):
		GameManager.acquired_targets[GlobalConstants.TARGET_TYPES.TANK] = 0
	return GameManager.acquired_targets[GlobalConstants.TARGET_TYPES.TANK] >= minimum_targets_for_completion

func get_value() -> String:
	if not GameManager.acquired_targets.has(GlobalConstants.TARGET_TYPES.TANK):
		GameManager.acquired_targets[GlobalConstants.TARGET_TYPES.TANK] = 0
	return str(GameManager.acquired_targets[GlobalConstants.TARGET_TYPES.TANK]) + "/" + str(minimum_targets_for_completion)
