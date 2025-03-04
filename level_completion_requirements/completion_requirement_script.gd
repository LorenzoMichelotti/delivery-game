class_name CompletionRequirementResource
extends Resource

@export var goal_description: String

func apply_modifiers():
	PlayerManager.gas_enabled = false
	GameManager.npc_count = 20

func verify_completion_requirement_met():
	return false

func get_value() -> String:
	return "IDC"
