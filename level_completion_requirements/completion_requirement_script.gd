class_name CompletionRequirementResource
extends Resource

@export var goal_description: String
@export var level_modifiers: LevelModifierResource

func verify_completion_requirement_met():
	return false

func get_value() -> String:
	return ""
